//
//  CallController.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2023-04-20.
//
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
    
    static let durableDataChannelId: Int32 = 1000;
    
    static let lossyDataChannelId: Int32 = 1010;
    
    static let durableDataChannelBandwidthKbps: Int32 = 32;
    
    static let lossyDataChannelBandwidthKbps: Int32 = 512;
    
    static let lossyDataChannelChunkedMessageDelay = 1.0;
    
    static let dataChannelRetrySendDelay = 2.0;
    
    static let dataChannelEstablishDelay = 1.0;

    // MARK: - Properties

    /// The life-cycle state of the current session.
    ///
    @Published fileprivate(set) var sessionState: AssistanceSessionState = .none {
        didSet {
            UIAccessibility.post(notification: .announcement, argument: sessionState.localizedDescription)
        }
    }

    fileprivate let cameraController = CameraController()
    fileprivate let locationManager = CLLocationManager()

    fileprivate var dataChannelSender: DataChannelSender? = nil
    fileprivate var dataChannelSenderLossy: DataChannelSender? = nil
    fileprivate var rawOutgoingVideoStream: VirtualOutgoingVideoStream?

    private let audioSession = AVAudioSession.sharedInstance()

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

    func startSession(onCallEnd: @escaping (() -> Void), onCallError: @escaping ((Error) -> Void)) {
        playRingbackTone()
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

    func endSession() {
        stopRingbackTone()
        playEndTone()

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


    func pauseVideo() {
        guard let call, let rawOutgoingVideoStream else { return }
        Task {
            do {
                try await call.stopVideo(stream: rawOutgoingVideoStream)
            } catch {
                print("Pausing video failed: \(error)")
                sendMessage(ErrorMessage.errorEvent(error: "\(error)"))
            }
        }
    }

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
        stopRingbackTone()
        playErrorTone()
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
        DispatchQueue.main.asyncAfter(deadline: .now() + CallController.dataChannelEstablishDelay) { [weak self] in
            guard let self else { return }

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
            self.videoHandler?.updateOrientation()
        }
    }

    fileprivate func playRingbackTone() {
        AVPlayer.callRingbackTone.seek(to: CMTime.zero)
        AVPlayer.callRingbackTone.play()
    }

    fileprivate func stopRingbackTone() {
        AVPlayer.callRingbackTone.pause()
    }

    fileprivate func playErrorTone() {
        AVPlayer.callErrorTone.seek(to: CMTime.zero)
        AVPlayer.callErrorTone.play()
    }

    fileprivate func playStartTone() {
        AVPlayer.callStartTone.seek(to: CMTime.zero)
        AVPlayer.callStartTone.play()
    }

    fileprivate func playEndTone() {
        AVPlayer.callEndTone.seek(to: CMTime.zero)
        AVPlayer.callEndTone.play()
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
                try await TowerApi.awaitAssistance()
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

class CallHandler: NSObject, CallDelegate, CallAgentDelegate {

    // MARK: - Properties

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
            callController.stopRingbackTone()
            Task { await callController.answerIncomingCall(incomingCall) }
        }
    }

    private func handleCallConnected(_ call: Call) {
        DispatchQueue.main.async { [weak self] in
            guard let callController = self?.callController else { return }
            callController.sessionState = .connected
            callController.playStartTone()
            callController.establishDataChannel(for: call)
        }
    }

    private func handleCallDisconnected() {
        callController?.disposeSession()
    }

}

// MARK: VideoHandler

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
            let imageBuffer = sampleBuffer.imageBuffer,
            let virtualOutgoingVideoStream = callController?.rawOutgoingVideoStream,
            virtualOutgoingVideoStream.state == .started
        else { return }

        let videoFrameBuffer = RawVideoFrameBuffer()
        videoFrameBuffer.buffer = imageBuffer
        videoFrameBuffer.streamFormat = virtualOutgoingVideoStream.format
        virtualOutgoingVideoStream.send(frame: videoFrameBuffer) { error in
            guard let error else { return }
            print(error)
        }
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

}

// MARK: LocationHandler

/// The controller for location services.
///
/// This contains all the application logic around retrieving locations.
///
class LocationHandler: NSObject, CLLocationManagerDelegate {

    // MARK: - Properties

    /// The call controller to use to send location messages.
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

class DataHandler: NSObject, DataChannelCallFeatureDelegate, DataChannelReceiverDelegate {
    
    // MARK: - Properties
    
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
        case .switchCameraRequest: handleSwitchCameraRequest()
        case .toggleTorchRequest: handleToggleTorchRequest()
        case .locationRequest: handleLocationRequest()
        case .capturePhotoRequest: handleCapturePhotoRequest()
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

    private func handleCapturePhotoRequest() {
        Task {
            guard let callController else { return }
            do {
                let photoData = try await callController.cameraController.takePhoto()
                print("Captured photo with a filesize of \(photoData.imageData.count / 1024) kB")

                let uuid = UUID()
                let encodedData = photoData.imageData.base64EncodedString()
                let chunkSize = try CallController.dataMessageMaxSize
                    - JSONEncoder
                        .shared
                        .encode(
                            DataMessage.photoDataEvent(
                                imageData: "",
                                imageSize: photoData.imageSize,
                                chunkingInfo: DataMessage.ImageChunkingInfo(
                                    index: CallController.dataMessageMaxBurstCount,
                                    count: CallController.dataMessageMaxBurstCount,
                                    uuid: uuid)))
                        .count
                let chunks = stride(from: 0, to: encodedData.count, by: chunkSize).map {
                    let start = encodedData.index(encodedData.startIndex, offsetBy: $0)
                    let end = encodedData.index(start, offsetBy: chunkSize, limitedBy: encodedData.endIndex)
                        ?? encodedData.endIndex
                    return String(encodedData[start..<end])
                }
                for (index, imageData) in chunks.enumerated() {
                    callController.sendMessageLossy(
                        DataMessage.photoDataEvent(
                            imageData: imageData,
                            imageSize: photoData.imageSize,
                            chunkingInfo: DataMessage.ImageChunkingInfo(
                                index: index,
                                count: chunks.count,
                                uuid: uuid)))
                    try await Task.sleep(for: .seconds(CallController.lossyDataChannelChunkedMessageDelay))
                }
                callController.sendMessage(DataMessage.capturePhotoResponse(uuid: uuid))
            } catch {
                print("Photo capture failed: \(error)")
                callController.sendMessage(ErrorMessage.capturePhotoResponse(error: "\(error)"))
            }
        }
    }
    
    private func handleHoldEvent() {
        guard let callController else { return }
        callController.sessionState = .onHold
        callController.playRingbackTone()
    }
    
    private func handleResumeEvent() {
        guard let callController else { return }
        callController.sessionState = .connected
        callController.stopRingbackTone()
        callController.playStartTone()
    }

}
