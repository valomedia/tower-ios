//
//  CallController.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2023-04-20.
//  Copyright (c) 2023-2025 valo.media GmbH. All rights reserved.
//

import Foundation
import CoreLocation
import AVFoundation
import SwiftUI
import AzureCommunicationCalling

// MARK: CallController

/// The controller for the call.
///
/// This contains for the application logic for the actual chime SDK itself.
///
class CallController: NSObject, ObservableObject {

    // MARK: - Static properties

    /// The maximum allowable size for the data in the realtime data messages.
    ///
    static let dataMessageMaxSize = 32_000;

    /// The maximum number of realtime data messages to send in one burst.
    ///
    static let dataMessageMaxBurstCount = 99;

    /// The id for the data channel everything except photos is transmitted over.
    ///
    static let durableDataChannelId: Int32 = 1000;

    /// The id for the data channel the photos are transmitted over.
    ///
    static let lossyDataChannelId: Int32 = 1010;

    /// The bandwith for the data channel everything except photos is transmitted over.
    ///
    static let durableDataChannelBandwidthKbps: Int32 = 32;

    /// The bandwidth for the data channel the photos are transmitted over.
    ///
    static let lossyDataChannelBandwidthKbps: Int32 = 512;

    /// The delay between large messages on the lossy data channel in seconds.
    ///
    /// In theory this should be calculatable from `dataMessageMaxSize` and `lossyDataChannelBandwidthKbps`, which
    /// would result in a delay of half a second, but for some reason this results in bandwidth exceeded exceptions,
    /// so it's just fixed at one second for now.
    ///
    static let lossyDataChannelChunkedMessageDelay: Double = 1.0;

    /// How long to wait before resending a message that failed to send.
    ///
    /// We will only retry sending messages on the durable data channel. Those will be resent on a loop until it
    /// finally works. Since the messages are too small, it's unlikely the resends would ever accumulate to the point
    /// where that becomes a problem, and if it does, other issues have rendered the call unrecoverably broken before
    /// then anyways.
    ///
    static let dataChannelRetrySendDelay: Double = 2.0;

    /// How long to wait before establishing the data channel after the call connects.
    ///
    /// For some reason, establishing the data channel immediately sometimes throws NSExceptions, so we add a little
    /// bit of a delay.
    ///
    static let dataChannelEstablishDelay: Double = 1.0;

    /// How long to wait between messages when sending multiple messages through the durable data channel.
    ///
    /// When the data channel is established, multiple messages are sent out immediately. Because the data channel
    /// implementation on iOS is a little bit brittle, we add a small delay between messages, to reduce the likelyhood
    /// of ACS freaking out and starting to throw NSExceptions our way.
    ///
    static let dataChannelMessageBurstDelay: Double = 1.0;

    // MARK: - Properties

    /// The life-cycle state of the current session.
    ///
    @Published fileprivate(set) var sessionState: AssistanceSessionState = .none

    /// The zero-indexed position of the user in the queue, if known.
    ///
    @Published fileprivate(set) var queuePosition: Int?

    @Published fileprivate(set) var viewfinderImage: Image?

    fileprivate let cameraController = CameraController()
    fileprivate let locationManager = CLLocationManager()

    fileprivate var dataChannelSender: DataChannelSender? = nil
    fileprivate var dataChannelSenderLossy: DataChannelSender? = nil
    fileprivate var rawOutgoingVideoStream: VirtualOutgoingVideoStream?

    private let audioSession = AVAudioSession.sharedInstance()
    private let callTonePlayer = AVPlayer()

    private var callClient: CallClient?
    private var callAgent: CallAgent?
    private var call: Call?
    private var dataChannelCallFeature: DataChannelCallFeature?
    private var callHandler: CallHandler?
    private var videoHandler: VideoHandler?
    private var locationHandler: LocationHandler?
    private var dataHandler: DataHandler?

    // MARK: - Methods

    /// Callback to invoke when the call ends.
    ///
    /// This will be called whenever the call ends, no matter the reason.
    ///
    var onCallEnd: (() -> Void)? = nil

    /// Callback to invoke when the call ends because of a fata Error during the initial connection.
    ///
    /// This will be called when the call fails because of an Error received while establishing the call, that the
    /// call cannot automatically recover from. This is only called if the call fails, before it has even begun.
    /// Something like the caller losing the connection while talking to an assistant will not cause this callback to
    /// run, since this doesn't require specific handling outside of the call itself (such as showing an error message
    /// to the user).
    ///
    var onCallError: ((Error) -> Void)? = nil

    /// Start a new assistance session.
    ///
    /// This will make a request to the /requestAssistance-endpoint, connect to ACS using the token returned by the
    /// endpoint and wait for an incoming call from an assistant.
    ///
    func startSession(onCallEnd: @escaping (() -> Void), onCallError: @escaping ((Error) -> Void)) {
        playCallTone(AVPlayerItem.callRingbackTone, repeating: true)
        sessionState = .initializing

        let callHandler = CallHandler()
        callHandler.callController = self
        self.callHandler = callHandler

        let videoHandler = VideoHandler()
        videoHandler.callController = self
        self.videoHandler = videoHandler

        let locationHandler = LocationHandler()
        locationHandler.callController = self
        self.locationHandler = locationHandler

        let dataHandler = DataHandler()
        dataHandler.callController = self
        self.dataHandler = dataHandler

        self.onCallEnd = onCallEnd
        self.onCallError = onCallError

        Task {
            do {
                try await createAgent(credential: try await createSession()).delegate = callHandler
                DispatchQueue.main.async { self.sessionState = .waiting }
            } catch {
                handleSessionError(error)
            }
        }
    }

    /// End the current assistance session.
    ///
    /// If the caller is still waiting for an assistant, the request will be cancelled, if the assistant is already on
    /// the line, the call will be hung up.
    ///
    func endSession() {
        playCallTone(AVPlayerItem.callEndTone)

        Task {
            do {
                try await hangUp()
            } catch {
                if sessionState == .waiting {
                    // Tell the backend we're gone. It's ok if this fails, the backend will notice on its own eventually.
                    Task { try? await TowerApi.cancelAssistance() }
                }

                disposeSession()
            }
        }
    }

    /// Pause the outgoing video stream.
    ///
    /// This will cleanly stop the outgoing video stream, so tower-staff can tell the difference between a video that
    /// cuts off because of a bad connection, and a video that is stopped on purpose. Currently, this is only used when
    /// the app goes into the background (and thus loses access to the camera).
    ///
    func pauseVideo() {
        guard let call, let rawOutgoingVideoStream else { return }
        viewfinderImage = nil
        Task {
            do {
                try await call.stopVideo(stream: rawOutgoingVideoStream)
            } catch {
                print("Pausing video failed: \(error)")
                sendMessage(ErrorMessage.errorEvent(error: "\(error)"))
            }
        }
    }

    /// Resume the outgoing video stream.
    ///
    /// This will resume the video after a call to `pauseVideo()`.
    ///
    func resumeVideo() {
        guard let call, let rawOutgoingVideoStream else { return }
        Task {
            do {
                try await call.startVideo(stream: rawOutgoingVideoStream)
            } catch {
                print("Resuming video failed: \(error)")
                sendMessage(ErrorMessage.errorEvent(error: "\(error)"))
            }
        }
    }

    /// Send a Message through a data channel.
    ///
    /// This will send a given Message through a data channel. The DataChannelSender to be used and whether to retry on
    /// failure can be optionally specified.
    ///
    /// - Parameters:
    ///   - message: The Message to send.
    ///   - dataChannelSender: The DataChannelSender to use, defaults to using the durable data channel.
    ///   - retryOnFailure: Whether to retry if sending fails, defaults to true.
    ///
    func sendMessage(_ message: Message, dataChannelSender: DataChannelSender? = nil, retryOnFailure: Bool = true) {
        do {
            sendMessage(
                try JSONEncoder.shared.encode(message),
                dataChannelSender: dataChannelSender,
                retryOnFailure: retryOnFailure)
        } catch {
            print("Encoding data message failed: \(error)")
            sendMessage(
                try! JSONEncoder.shared.encode(ErrorMessage.errorEvent(error: "\(error)")),
                dataChannelSender: dataChannelSender,
                retryOnFailure: false)
        }
    }

    /// Send Data through a data channel.
    ///
    /// This will send the given Data through a data channel. The DataChannelSender to be used an whether to retry on
    /// failure can be optionally specified.
    ///
    /// - Parameters:
    ///   - data: The Data to send.
    ///   - dataChannelSender: The DataChannelSender to use, defaults to using the durable data channel.
    ///   - retryOnFailure: Whether to retry if sending fails, defaults to true.
    ///
    func sendMessage(_ data: Data, dataChannelSender: DataChannelSender? = nil, retryOnFailure: Bool = true) {
        guard let sender = dataChannelSender ?? self.dataChannelSender else { return }
        do {
            try ObjC.catchException { sender.sendMessage(data: data) }
        } catch let error as NSError {
            print("Data message failed to send: \(error.localizedDescription)")
            if (retryOnFailure) {
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + CallController.dataChannelRetrySendDelay
                ) { [weak self] in
                    print("Retrying…")
                    self?.sendMessage(data, dataChannelSender: dataChannelSender)
                }
            }
        }
    }

    /// Send a Message through the lossy data channel.
    ///
    /// This will send a given message through the lossy data channel. It will not retry if sending fails.
    ///
    func sendMessageLossy(_ message: Message) {
        sendMessage(message, dataChannelSender: dataChannelSenderLossy, retryOnFailure: false)
    }

    fileprivate func answerIncomingCall(_ incomingCall: IncomingCall) async {
        let rawOutgoingVideoStreamOptions = RawOutgoingVideoStreamOptions()
        rawOutgoingVideoStreamOptions.formats = CallQualityLevel
            .allCases
            .filter { cameraController.universallySupportedResolutions.contains($0.resolution.dimensions) }
            .map(\.videoStreamFormat)
        let rawOutgoingVideoStream = VirtualOutgoingVideoStream(videoStreamOptions: rawOutgoingVideoStreamOptions)
        rawOutgoingVideoStream.delegate = videoHandler
        self.rawOutgoingVideoStream = rawOutgoingVideoStream

        let outgoingVideoOptions = OutgoingVideoOptions()
        outgoingVideoOptions.streams = [rawOutgoingVideoStream]

        let acceptCallOptions = AcceptCallOptions()
        acceptCallOptions.outgoingVideoOptions = outgoingVideoOptions

        do {
            let call = try await incomingCall.accept(options: acceptCallOptions)
            call.delegate = callHandler
            self.call = call

        } catch {
            try? await incomingCall.reject()
            handleSessionError(error)
        }

        // If no external devices are attached, switch to the loudspeaker.
        if (
            audioSession
                .currentRoute
                .outputs
                .filter { $0.portType != .builtInReceiver && $0.portType != .builtInSpeaker }
                .isEmpty
        ) {
            try? audioSession.overrideOutputAudioPort(.speaker)
        }
    }

    fileprivate func handleSessionError(_ error: Error) {
        playCallTone(AVPlayerItem.callErrorTone)
        disposeSession()
        DispatchQueue.main.async { self.onCallError?(error) }
    }

    fileprivate func disposeSession() {
        try? AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)

        cameraController.stop()
        cameraController.torchEnabled = false

        DispatchQueue.main.async {
            self.callClient = nil
            self.callAgent = nil
            self.call = nil
            self.rawOutgoingVideoStream = nil
            self.dataChannelCallFeature = nil
            self.dataChannelSender = nil
            self.dataChannelSenderLossy = nil
            self.callHandler = nil
            self.videoHandler = nil
            self.locationHandler = nil
            self.dataHandler = nil

            self.onCallEnd?()
            self.onCallEnd = nil
            self.queuePosition = nil
            self.sessionState = .disconnected
        }
    }

    fileprivate func hangUp() async throws {
        let options = HangUpOptions()
        options.forEveryone = true
        try await (call.!?).hangUp(options: options)
    }

    /// Start updating the location.
    ///
    /// - Throws: CLError
    ///
    fileprivate func startSendingLocation() throws {
        locationManager.delegate = locationHandler
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
        case .restricted, .denied:
            throw CLError(.denied)
        case .notDetermined:
            print("Requesting location permissions")
            locationManager.requestWhenInUseAuthorization()
            break
        default:
            break
        }
    }

    fileprivate func establishDataChannel(for call: Call) {
        let dataChannelCallFeature = call.feature(Features.dataChannel)
        dataChannelCallFeature.delegate = self.dataHandler
        self.dataChannelCallFeature = dataChannelCallFeature

        let durableDataChannelSenderOptions = DataChannelSenderOptions()
        durableDataChannelSenderOptions.channelId = CallController.durableDataChannelId
        durableDataChannelSenderOptions.bitrateInKbps = CallController.durableDataChannelBandwidthKbps
        durableDataChannelSenderOptions.priority = .high
        durableDataChannelSenderOptions.reliability = .durable

        let dataChannelSender
            = dataChannelCallFeature.getDataChannelSender(options: durableDataChannelSenderOptions)
        dataChannelSender.setParticipants(participants: call.remoteParticipants.map(\.identifier))

        let lossyDataChannelSenderOptions = DataChannelSenderOptions()
        lossyDataChannelSenderOptions.channelId = CallController.lossyDataChannelId
        lossyDataChannelSenderOptions.bitrateInKbps = CallController.lossyDataChannelBandwidthKbps
        lossyDataChannelSenderOptions.priority = .normal
        lossyDataChannelSenderOptions.reliability = .lossy

        let dataChannelSenderLossy
            = dataChannelCallFeature.getDataChannelSender(options: lossyDataChannelSenderOptions)
        dataChannelSenderLossy.setParticipants(participants: call.remoteParticipants.map(\.identifier))

        self.dataChannelSender = dataChannelSender
        self.dataChannelSenderLossy = dataChannelSenderLossy

        DispatchQueue.main.asyncAfter(deadline: .now() + CallController.dataChannelMessageBurstDelay) { [weak self] in
            self?.videoHandler?.updateOrientation()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2 * CallController.dataChannelMessageBurstDelay) { [weak self] in
            self?.sendMessage(DataMessage.userHelloEvent(clientInfo: ClientInfo(), userProfile: UserProfile()))
        }
    }

    fileprivate func playCallTone(_ callTone: AVPlayerItem, repeating: Bool = false) {
        callTonePlayer.replaceCurrentItem(with: callTone)
        callTonePlayer.seek(to: .zero)
        callTonePlayer.play()
        if repeating {
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: callTonePlayer.currentItem,
                queue: .main) { [weak self] _ in
                    self?.callTonePlayer.seek(to: CMTime.zero)
                    self?.callTonePlayer.play()
                }
        }
    }

    fileprivate func stopCallTone() {
        callTonePlayer.replaceCurrentItem(with: nil)
    }

    private func createSession() async throws -> CommunicationTokenCredential {
        let requestAssistanceResponse = try await TowerApi.requestAssistance()
        _ = requestAssistanceResponse.keepaliveInterval.map { keepaliveInterval in
            Task { await sendKeepalives(keepaliveInterval) }
        }
        return try CommunicationTokenCredential(token: requestAssistanceResponse.userToken.token)
    }

    private func sendKeepalives(_ keepaliveInterval: Int) async {
        do { try await Task.sleep(for: .seconds(keepaliveInterval)) } catch { return }
        repeat {
            do { try await Task.sleep(for: .seconds(keepaliveInterval)) } catch { return }
            do {
                queuePosition = (try await TowerApi.awaitAssistance()).position
            } catch {
                // Got an error updating the request. This might be because the assistant has already the request
                // and is in the process of picking up though, so give it a little time.
                do { try await Task.sleep(for: .seconds(keepaliveInterval)) } catch { return }
                if sessionState == .waiting {
                    // If we still haven't heard from the assistant by now, we probably have a connection issue.
                    handleSessionError(error)
                }
            }
        } while sessionState == .waiting
    }

    private func createAgent(credential: CommunicationTokenCredential) async throws -> CallAgent {
        let callClient = CallClient()
        let callAgent = try await callClient.createCallAgent(userCredential: credential)

        self.callClient = callClient
        self.callAgent = callAgent

        return callAgent
    }

}

// MARK: CallHandler

/// Handler for things related to the call itself.
///
/// This contains methods for handling incoming calls and changes to the incoming call's state.
///
class CallHandler: NSObject, CallDelegate, CallAgentDelegate {

    // MARK: - Properties

    /// The CallController this CallHandler is attached to.
    ///
    weak var callController: CallController?

    // MARK: - Methods

    func callAgent(_ callAgent: CallAgent, didRecieveIncomingCall incomingCall: IncomingCall) {
        handleIncomingCall(incomingCall)
    }

    func call(_ call: Call, didChangeState args: PropertyChangedEventArgs) {
        if call.state == .connected { handleCallConnected(call) }
        if call.state == .disconnected { handleCallDisconnected() }
    }

    private func handleIncomingCall(_ incomingCall: IncomingCall) {
        DispatchQueue.main.async { [weak self] in 
            guard let callController = self?.callController else { return }
            callController.sessionState = .connecting
            callController.queuePosition = nil
            callController.stopCallTone()
            Task { await callController.answerIncomingCall(incomingCall) }
        }
    }

    private func handleCallConnected(_ call: Call) {
        DispatchQueue.main.async { [weak self] in
            guard let callController = self?.callController else { return }
            callController.sessionState = .connected
            callController.playCallTone(AVPlayerItem.callStartTone)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + CallController.dataChannelEstablishDelay) { [weak self] in
            self?.callController?.establishDataChannel(for: call)
        }
    }

    private func handleCallDisconnected() {
        callController?.playCallTone(AVPlayerItem.callEndTone)
        callController?.disposeSession()
    }

}

// MARK: VideoHandler

/// Handler for things related to the video stream.
///
/// This contains methods for handling changes to the state and format of the video stream in ACS, handling orientation
/// changes, as well as sending out the actual video frames as they come in, and adding them to the viewfinder.
///
class VideoHandler: NSObject, VirtualOutgoingVideoStreamDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {

    // MARK: - Static properties

    private static let portraitRotationAngle = 90.0
    private static let portraitUpsideDownRotationAngle = 270.0
    private static let landscapeLeftRotationAngle = 0.0
    private static let landscapeRightRotationAngle = 180.0
    private static let defaultRotationAngle = 90.0

    // MARK: - Life cycle methods

    override init() {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deviceOrientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Properties

    /// The CallController this VideoHandler is attached to.
    ///
    weak var callController: CallController?

    weak private var virtualOutgoingVideoStream: VirtualOutgoingVideoStream?

    // MARK: - Methods

    func virtualOutgoingVideoStream(
        _ virtualOutgoingVideoStream: VirtualOutgoingVideoStream,
        didChangeState args: VideoStreamStateChangedEventArgs
    ) {
        if args.stream.state == .available { handleVideoStreamAvailable(virtualOutgoingVideoStream) }
        if args.stream.state == .started { handleVideoStreamStarted(virtualOutgoingVideoStream) }
        if args.stream.state == .stopped { handleVideoStreamStopped() }
    }

    func virtualOutgoingVideoStream(
        _ virtualOutgoingVideoStream: VirtualOutgoingVideoStream,
        didChangeFormat args: VideoStreamFormatChangedEventArgs
    ) {
        handleFrameRateChanged(virtualOutgoingVideoStream)
        handleDimensionsChanged(virtualOutgoingVideoStream)
    }

    func captureOutput(_: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from _: AVCaptureConnection) {
        guard
            let callController,
            let imageBuffer = sampleBuffer.imageBuffer,
            let virtualOutgoingVideoStream = callController.rawOutgoingVideoStream,
            virtualOutgoingVideoStream.state == .started
        else { return }

        // Send frame to video stream
        let videoFrameBuffer = RawVideoFrameBuffer()
        videoFrameBuffer.buffer = imageBuffer
        videoFrameBuffer.streamFormat = virtualOutgoingVideoStream.format
        virtualOutgoingVideoStream.send(frame: videoFrameBuffer) { error in
            guard let error else { return }
            print(error)
        }

        // Show frame in preview
        callController.viewfinderImage = CIImage(cvImageBuffer: imageBuffer)
            .oriented(cgImagePropertyOrientation(for: UIDevice.current.orientation))
            .image
    }

    @objc func deviceOrientationDidChange(notification: NSNotification) {
        updateOrientation()
    }
    
    func updateOrientation() {
        callController?.sendMessage(
            DataMessage.orientationEvent(rotationAngle: videoRotationAngle(for: UIDevice.current.orientation)))
    }

    private func handleVideoStreamAvailable(_ virtualOutgoingVideoStream: VirtualOutgoingVideoStream) {
        callController?.cameraController.delegate = self
    }

    private func handleVideoStreamStarted(_ virtualOutgoingVideoStream: VirtualOutgoingVideoStream) {
        callController?.cameraController.start { [weak self] error in
            Task {
                guard let self else { return }
                try? await self.callController?.hangUp()
                self.callController?.handleSessionError(error)
            }
        }
    }

    private func handleVideoStreamStopped() {
        callController?.cameraController.stop()
    }

    private func handleFrameRateChanged(_ virtualOutgoingVideoStream: VirtualOutgoingVideoStream) {
        guard let cameraController = callController?.cameraController else { return }
        cameraController.captureFrameRate = Float64(virtualOutgoingVideoStream.format.framesPerSecond)
    }

    private func handleDimensionsChanged(_ virtualOutgoingVideoStream: VirtualOutgoingVideoStream) {
        guard let cameraController = callController?.cameraController else { return }
        cameraController.captureDimensions = virtualOutgoingVideoStream.format.resolution.dimensions
    }

    private func videoRotationAngle(for deviceOrientation: UIDeviceOrientation) -> Double {
        switch deviceOrientation {
        case .portrait: return VideoHandler.portraitRotationAngle
        case .portraitUpsideDown: return VideoHandler.portraitUpsideDownRotationAngle
        case .landscapeLeft: return VideoHandler.landscapeLeftRotationAngle
        case .landscapeRight: return VideoHandler.landscapeRightRotationAngle
        default: return VideoHandler.defaultRotationAngle
        }
    }

    private func cgImagePropertyOrientation(for deviceOrientation: UIDeviceOrientation) -> CGImagePropertyOrientation {
        switch deviceOrientation {
        case .portrait: return .right
        case .portraitUpsideDown: return .left
        case .landscapeLeft: return .up
        case .landscapeRight: return .down
        default: return .right
        }
    }

}

// MARK: LocationHandler

/// Handler for location data and location permissions.
///
/// This contains methods for handling changes to the location permissions granted by the user, and for sending out the
/// actual location data when it becomes available.
///
class LocationHandler: NSObject, CLLocationManagerDelegate {

    // MARK: - Properties

    /// The CallController this LocationHandler is attached to.
    ///
    weak var callController: CallController?

    // MARK: - Methods

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            print("User allowed access to location.");
            manager.startUpdatingLocation()
            break
        case .restricted, .denied:
            print("User denied access to location.")
            callController?.sendMessage(ErrorMessage.locationEvent(error: "\(CLError(.denied))"))
            break
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations
            .last
            .map(Location.init)
            .flatMap(DataMessage.init)
            .map { message in callController?.sendMessage(message) }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location access failed: \(error)")
        callController?.sendMessage(ErrorMessage.locationEvent(error: "\(error)"))
    }

}

// MARK: DataHandler

/// Handler for things related to the data channels.
///
/// This contains methods for subscribing to a data channel when it gets established, and for handling the various
/// messages as they come in.
///
class DataHandler: NSObject, DataChannelCallFeatureDelegate, DataChannelReceiverDelegate {

    // MARK: - Properties

    /// The CallController this Data Handler is attached to.
    ///
    weak var callController: CallController?

    // MARK: - Methods

    func dataChannelCallFeature(
        _ dataChannelCallFeature: DataChannelCallFeature,
        didCreateReceiver args: DataChannelReceiverCreatedEventArgs
    ) {
        args.receiver.delegate = self
    }

    func dataChannelReceiver(
        _ dataChannelReceiver: DataChannelReceiver,
        didReceiveMessage args: PropertyChangedEventArgs
    ) {
        // Make sure that we have data and that the data is a DataMessage. The tower-staff app currently doesn't send
        // ErrorMessages, but if it does, we wanna ignore them here.
        guard
            let data = dataChannelReceiver.receiveMessage()?.data,
            let message = try? JSONDecoder.shared.decode(DataMessage.self, from: data)
        else { return }
        
        switch message {
        case let .capturePhotoRequest(uploadUrl, key):
            handleCapturePhotoRequest(uploadUrl: uploadUrl, key: key)
        case .switchCameraRequest: handleSwitchCameraRequest()
        case .toggleTorchRequest: handleToggleTorchRequest()
        case .locationRequest: handleLocationRequest()
        case .holdEvent: handleHoldEvent()
        case .resumeEvent: handleResumeEvent()
        default: ()
        }
    }

    private func handleSwitchCameraRequest() {
        guard let callController else { return }
        callController.cameraController.switchCamera()
        callController.sendMessage(DataMessage.switchCameraResponse)
    }

    private func handleToggleTorchRequest() {
        guard let callController else { return }
        callController.cameraController.torchEnabled.toggle();
        callController.sendMessage(DataMessage.toggleTorchResponse)
    }

    private func handleLocationRequest() {
        guard let callController else { return }
        do {
            try callController.startSendingLocation()
            callController.sendMessage(DataMessage.locationResponse)
        } catch {
            print("User denied access to location.")
            callController.sendMessage(ErrorMessage.locationResponse(error: "\(error)"))
        }
    }

    private func handleCapturePhotoRequest(
        uploadUrl: URL,
        key:       String
    ) {
        Task {
            guard let callController else { return }
            do {
                // 1. Capture photo
                let photo = try await callController.cameraController.takePhoto()
                print("Captured photo with a filesize of \(photo.imageData.count / 1024) kB")
                // 2. Upload via TowerApi
                try await TowerApi.uploadPhotoData(photo.imageData, to: uploadUrl)
                // 3. Notify assistant
                callController.sendMessage(DataMessage.capturePhotoResponse(key: key))
            } catch {
                print("Photo capture failed: \(error)")
                callController.sendMessage(ErrorMessage.capturePhotoResponse(error: "\(error)"))
            }
        }
    }
    
    private func handleHoldEvent() {
        guard let callController else { return }
        callController.sessionState = .onHold
        callController.playCallTone(AVPlayerItem.callRingbackTone, repeating: true)
    }
    
    private func handleResumeEvent() {
        guard let callController else { return }
        callController.sessionState = .connected
        callController.playCallTone(AVPlayerItem.callStartTone)
    }

}
