//
//  CallController.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2023-04-20.
//
//

import Foundation
import AmazonChimeSDK
import CoreLocation
import AVFoundation
import SwiftUI


// MARK: CallController

/// The controller for the call.
///
/// This contains for the application logic for the actual chime SDK itself.
///
class CallController: ObservableObject, AudioVideoObserver, RealtimeObserver, DataMessageObserver {

    /// The life cycle of the call.
    ///
    enum CallState: CustomStringConvertible {
        case none
        case notConnected
        case connecting
        case reconnecting
        case waiting
        case connected
        case poorConnection
        case connectionLost
        case failed
        case disconnected

        var description: String {
            switch self {
            case .none:
                return "Verbindung herstellen…"
            case .notConnected:
                return "Verbindung herstellen…"
            case .connecting:
                return "Anrufaufbau…"
            case .reconnecting:
                return "Neu verbinden…"
            case .waiting:
                return "Warten auf Assistenz…"
            case .connected:
                return "Verbunden"
            case .poorConnection:
                return "Schlechte Verbindung!"
            case .connectionLost:
                return "Verbindungsabbruch!"
            case .failed:
                return "Verbindung fehlgeschlagen!"
            case .disconnected:
                return "Verbindung getrennt"
            }
        }

        /// Whether the user is currently able to talk to the assistant.
        ///
        var isConnected: Bool {
            self == .connected || self == .poorConnection
        }

    }

    // MARK: - Static properties

    /// How long the data messages are valid.
    ///
    /// Since the messages are always transmitted to the user in real time (there is no situation where messages are
    /// sent for an assistant that isn't on the call yet), the messages are usually delivered immediately.  The
    /// messages still have a lifetime of ten seconds however, in order to account for users who may be experiencing
    /// brief intermittent interruptions in their connection, due to a spotty network.
    ///
    /// If the message does not reach the assistant within ten seconds, the message will be quietly discarded.  This
    /// will currently result in actions in the ui becoming disabled for the duration of the call.  The inherent
    /// assumption being, that if the call hangs completely for more than ten seconds at a time, assistance will
    /// become impossible anyway, and there is no reasonable way to gracefully recover.
    ///
    private static let dataMessageLifetimeMs: Int32 = 10_000;
    
    /// The maximum allowable size for the data in the realtime data messages.
    ///
    private static let dataMessageMaxSize = 2048;
    
    /// The maximum number of realtime data messages to send in one burst.
    ///
    private static let dataMessageMaxBurstCount = 500;
    
    /// How often to retry a connection that fails before an assistant picks up.
    ///
    /// Sometimes the call will immediately fail, before an assistant even joins the call. In this case, the call can
    /// be retried without the user even noticing, since the user is still waiting for the call to connect anyways.
    /// This parameter controls the number of retries that will be made in this particular case.
    ///
    private static let maxRetriesOnEarlyFailure = 3;
    
    /// How many seconds to wait before retrying the connection, when it fails before an assistant picks up.
    ///
    private static let earlyRetryWaitTimeSeconds: Double = 2;

    // MARK: - Life cycle methods

    /// Constructor.
    ///
    init() { }

    // MARK: - Properties

    /// The life-cycle state of the current session.
    ///
    @Published var state: CallState = .none {
        didSet {
            UIAccessibility.post(notification: .announcement, argument: state.description)
        }
    }

    /// The MeetingSession this CallController is attached to.
    ///
    @Published var session: MeetingSession? = nil
    
    /// Whether the video is currently paused.
    ///
    /// This indicates whether the video is stopped because the user has stopped the video through an action taken on
    /// their device. Currenlty this means that the user has sent the app to the background (or locked their device).
    ///
    @Published private(set) var isVideoPaused: Bool = false
    
    private var earlyFailureRetryCount = 0;

    private var locationController: LocationController? = nil
    
    private var shouldRetryConnection: Bool {
        !state.isConnected && earlyFailureRetryCount <= CallController.maxRetriesOnEarlyFailure
    }

    private let logger = ConsoleLogger(name: "CallController")
    private let localVideoConfig = LocalVideoConfiguration(maxBitRateKbps: 2500)
    private let cameraController = CameraController()

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
    
    /// Start a new call.
    ///
    /// This will register a new call with the backend, then join the call.
    ///
    /// - Parameters:
    ///     - onCallEnd: A closure to call when the call ends, no matter why.
    ///     - onCallError: A closure to call when the call ends because of a fatal Error during the initial connection.
    ///
    func startCall(onCallEnd: @escaping (() -> Void), onCallError: @escaping ((Error) -> Void)) {
        self.onCallEnd = onCallEnd
        self.onCallError = onCallError
        join()
    }
    
    /// End the call.
    ///
    /// This will hang up the call and unregister it from the backend.
    ///
    func endCall() {
        if let configuration = session?.configuration {
            Task { try? await TowerApi.end(sessionConfiguration: configuration) }
        }
        
        state = .disconnected
        AVPlayer.callRingbackTone.pause()
        AVPlayer.callEndTone.seek(to: CMTime.zero)
        AVPlayer.callEndTone.play()
        
        onCallEnd?()
        leave()
        
        earlyFailureRetryCount = 0
    }
    
    /// Pause the video feed.
    ///
    /// This will pause the video feed, if it is not paused already. This means, that the video will be stopped and
    /// `isVideoPaused` will be set to `true`, indicating that the video has been manually stopped.
    ///
    func pauseVideo() {
        guard !isVideoPaused else { return }
        stopVideo()
        isVideoPaused = true
    }
    
    /// Resume the video feed.
    ///
    /// This will resume the video feed, if it is currenlty paused. If the video feed has been previously paused using
    /// `pauseVideo()`, this will restart the video and set `isVideoPaused` back to `false`.
    ///
    /// If the video isn't paused when this is called, this will be a no-op. This function will only resume the video
    /// if it is paused. If the video is stopped, but there hasn't been a call to `pauseVideo()`, this will not
    /// attempt to restart the video.
    ///
    func resumeVideo() {
        guard isVideoPaused else { return }
        restartVideo()
        isVideoPaused = false
    }

    func audioSessionDidStartConnecting(reconnecting: Bool) {
        logger.info(msg: "audioSessionDidStartConnecting")

        // When reestablishing the connection, move to reconnecting state only if the assistant was already in the call.
        state = state.isConnected && reconnecting ? .reconnecting : .connecting
        
        AVPlayer.callRingbackTone.seek(to: CMTime.zero)
        AVPlayer.callRingbackTone.play()
    }

    func audioSessionDidStart(reconnecting: Bool) {
        logger.info(msg: "audioSessionDidStart")
    }

    func audioSessionDidDrop() {
        logger.info(msg: "audioSessionDidDrop")
        state = .connectionLost
        AVPlayer.callRingbackTone.pause()
        AVPlayer.callErrorTone.seek(to: CMTime.zero)
        AVPlayer.callErrorTone.play()
    }

    func audioSessionDidStopWithStatus(sessionStatus: AmazonChimeSDK.MeetingSessionStatus) {
        logger.info(msg: "audioSessionDidStopWithStatus \(sessionStatus.statusCode)")
    }

    func audioSessionDidCancelReconnect() {
        logger.info(msg: "audioSessionDidCancelReconnect")
        state = .failed
        AVPlayer.callRingbackTone.pause()
        AVPlayer.callErrorTone.seek(to: CMTime.zero)
        AVPlayer.callErrorTone.play()
    }

    func connectionDidRecover() {
        logger.info(msg: "connectionDidRecover")
        if (state.isConnected) {
            state = .connected
        }
    }

    func connectionDidBecomePoor() {
        logger.info(msg: "connectionDidBecomePoor")
        if (state.isConnected) {
            state = .poorConnection
        }
    }

    func videoSessionDidStartConnecting() {
        logger.info(msg: "videoSessionDidStartConnecting")
    }

    func videoSessionDidStartWithStatus(sessionStatus: AmazonChimeSDK.MeetingSessionStatus) {
        logger.info(msg: "videoSessionDidStartWithStatus \(sessionStatus.statusCode)")
    }

    func videoSessionDidStopWithStatus(sessionStatus: AmazonChimeSDK.MeetingSessionStatus) {
        logger.info(msg: "videoSessionDidStopWithStatus \(sessionStatus.statusCode)")
        
        if state != .none && state != .disconnected {
            if shouldRetryConnection, let configuration = session?.configuration {
                retryConnection(sessionConfiguration: configuration)
            } else {
                endCall()
            }
        }
    }

    func remoteVideoSourcesDidBecomeAvailable(sources: [AmazonChimeSDK.RemoteVideoSource]) {
        logger.info(msg: "remoteVideoSourcesDidBecomeAvailable")
    }

    func remoteVideoSourcesDidBecomeUnavailable(sources: [AmazonChimeSDK.RemoteVideoSource]) {
        logger.info(msg: "remoteVideoSourcesDidBecomeUnavailable")
    }

    func cameraSendAvailabilityDidChange(available: Bool) {
        logger.info(msg: "cameraSendAvailabilityDidChange")
    }

    func volumeDidChange(volumeUpdates: [AmazonChimeSDK.VolumeUpdate]) {}

    func signalStrengthDidChange(signalUpdates: [AmazonChimeSDK.SignalUpdate]) {
        logger.info(msg: "signalStrengthDidChange")
    }

    func attendeesDidJoin(attendeeInfo: [AmazonChimeSDK.AttendeeInfo]) {
        logger.info(msg: "attendeesDidJoin")
        if (state != .connected) {
            state = state == .connecting ? .waiting : .connected
        }
        if (state == .connected) {
            AVPlayer.callRingbackTone.pause()
            AVPlayer.callStartTone.seek(to: CMTime.zero)
            AVPlayer.callStartTone.play()
        }
    }

    func attendeesDidLeave(attendeeInfo: [AmazonChimeSDK.AttendeeInfo]) {
        logger.info(msg: "attendeesDidLeave")
    }

    func attendeesDidDrop(attendeeInfo: [AmazonChimeSDK.AttendeeInfo]) {
        logger.info(msg: "attendeesDidDrop")
    }

    func attendeesDidMute(attendeeInfo: [AmazonChimeSDK.AttendeeInfo]) {
        logger.info(msg: "attendeesDidMute")
    }

    func attendeesDidUnmute(attendeeInfo: [AmazonChimeSDK.AttendeeInfo]) {
        logger.info(msg: "attendeesDidUnmute")
    }

    func dataMessageDidReceived(dataMessage: AmazonChimeSDK.DataMessage) {
        logger.info(msg: "dataMessageDidReceived \(dataMessage.timestampMs) \(dataMessage.topic) \(dataMessage.senderAttendeeId)");

        switch dataMessage.topic {
        case DataMessageTopic.switchCameraRequest.rawValue:
            handleSwitchCameraRequest()
            break
        case DataMessageTopic.toggleTorchRequest.rawValue:
            handleToggleTorchRequest()
            break
        case DataMessageTopic.locationRequest.rawValue:
            handleLocationRequest()
            break
        case DataMessageTopic.capturePhotoRequest.rawValue:
            handleCapturePhotoRequest()
            break
        default:
            break
        }
    }

    func sendDataMessage(_ topic: DataMessageTopic, data: Data? = nil) {
        do {
            try session?.audioVideo.realtimeSendDataMessage(
                    topic: topic.rawValue,
                    data: data ?? "{}".data(using: .utf8) as Any,
                    lifetimeMs: CallController.dataMessageLifetimeMs)
        } catch let err as SendDataMessageError {
            switch err {
            case SendDataMessageError.invalidDataLength:
                logger.error(msg: "Message too long, was \(data?.count ?? 0) bytes!")
                break
            default:
                logger.error(msg: "Failed to send message! \(err)")
                break
            }
        } catch {
            logger.error(msg: "Unknown error \(error.localizedDescription)")
        }
    }
    
    /// Join a meeting with a given configuration.
    ///
    /// This takes the configuration returned by the start endpoint and connects to the meeting with audio and video.
    ///
    /// - Parameter configuration: The MeetingSessionConfiguration
    /// - Throws:
    ///
    private func join(configuration: MeetingSessionConfiguration? = nil) {
        Task { @MainActor in
            do {
                let session = try DefaultMeetingSession(
                    configuration: configuration != nil ? configuration! : await TowerApi.start(),
                    logger: logger)
                self.session = session
                
                if (state == .disconnected) {
                    // The user killed the call while we were still waiting for a config from the backend. Just bail
                    // at this point.
                    Task { try? await TowerApi.end(sessionConfiguration: session.configuration) }
                    return
                }
                
                state = .notConnected
                session.audioVideo.addAudioVideoObserver(observer: self)
                session.audioVideo.addRealtimeObserver(observer: self)
                session.audioVideo.addRealtimeDataMessageObserver(
                        topic: DataMessageTopic.capturePhotoRequest.rawValue,
                        observer: self)
                session.audioVideo.addRealtimeDataMessageObserver(
                        topic: DataMessageTopic.switchCameraRequest.rawValue,
                        observer: self)
                session.audioVideo.addRealtimeDataMessageObserver(
                        topic: DataMessageTopic.toggleTorchRequest.rawValue,
                        observer: self)
                session.audioVideo.addRealtimeDataMessageObserver(
                        topic: DataMessageTopic.locationRequest.rawValue,
                        observer: self)

                let audioDevices = session.audioVideo.listAudioDevices()
                for device in audioDevices {
                    logger.info(msg: "Device type: \(device.type), label: \(device.label)");
                }

                try session.audioVideo.start()

                // Start the capture
                cameraController.start()

                startVideo()
                
                // If no external devices are attached, switch to the loudspeaker.
                if (
                    audioDevices
                        .filter { $0.type != .audioBuiltInSpeaker && $0.type != .audioHandset }
                        .isEmpty
                ) {
                    let device = audioDevices
                        .filter {
                            $0.type == .audioBuiltInSpeaker
                        }
                        .first
                    device.map(session.audioVideo.chooseAudioDevice(mediaDevice:))
                    try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
                }

                locationController = LocationController()
                locationController?.callController = self
            } catch {
                if shouldRetryConnection, let configuration = session?.configuration {
                    retryConnection(sessionConfiguration: configuration)
                } else {
                    endCall()
                    onCallError?(error)
                }
            }
        }
    }
    
    /// End the meeting.
    ///
    /// This disconnects from the meeting. This is called after onCallEnd() to end the connection as far as the Chime
    /// SDK is concerned. This does not affect the meeting on the server, which should have already ended when this is
    /// called.
    ///
    private func leave() {
        session?.audioVideo.stop()
        cameraController.stop()
        cameraController.torchEnabled = false
        state = .none
        session = nil
        locationController = nil
    }
    
    private func startVideo() {
        session?.audioVideo.startLocalVideo(source: cameraController, config: localVideoConfig)
    }
    
    private func stopVideo() {
        session?.audioVideo.stopLocalVideo()
    }
    
    private func restartVideo() {
        session?.audioVideo.startLocalVideo(source: cameraController)
    }
    
    private func retryConnection(sessionConfiguration: MeetingSessionConfiguration) {
        state = .none
        earlyFailureRetryCount += 1
        leave()
        DispatchQueue.main.asyncAfter(deadline: .now() + CallController.earlyRetryWaitTimeSeconds) { [weak self] in
            self?.join(configuration: sessionConfiguration)
        }
    }

    private func handleSwitchCameraRequest() {
        cameraController.switchCamera()
        sendDataMessage(.switchCameraResponse)
    }
    
    private func handleToggleTorchRequest() {
        cameraController.torchEnabled.toggle();
        sendDataMessage(.toggleTorchResponse)
    }
    
    private func handleLocationRequest() {
        do {
            try locationController?.requestLocation()
            sendDataMessage(.locationResponse)
        } catch {
            sendDataMessage(.locationResponse, data: try! JSONEncoder.shared.encode(["message": "\(error)"]))
        }
    }

    private func handleCapturePhotoRequest() {
        Task {
            do {
                let photoData = try await cameraController.takePhoto()
                logger.info(msg: "Captured photo with a filesize of \(photoData.imageData.count / 1024) kB")
                
                let uuid = UUID()
                let encodedData = photoData.imageData.base64EncodedString()
                let chunkSize = try CallController.dataMessageMaxSize
                    - JSONEncoder
                        .shared
                        .encode(
                            CapturePhotoResponseData(
                                photoData: PhotoDataChunk(
                                    imageData: "",
                                    imageSize: photoData.imageSize,
                                    chunkingInfo: ChunkingInfo(
                                        index: CallController.dataMessageMaxBurstCount,
                                        count: CallController.dataMessageMaxBurstCount,
                                        uuid: uuid))))
                        .count
                let chunks = stride(from: 0, to: encodedData.count, by: chunkSize).map {
                    let start = encodedData.index(encodedData.startIndex, offsetBy: $0)
                    let end = encodedData.index(start, offsetBy: chunkSize, limitedBy: encodedData.endIndex)
                        ?? encodedData.endIndex
                    return String(encodedData[start..<end])
                }
                for (index, imageData) in chunks.enumerated() {
                    sendDataMessage(
                        .capturePhotoResponse,
                        data: try! JSONEncoder.shared.encode(
                                CapturePhotoResponseData(
                                photoData: PhotoDataChunk(
                                    imageData: imageData,
                                    imageSize: photoData.imageSize,
                                    chunkingInfo: ChunkingInfo(
                                        index: index,
                                        count: chunks.count,
                                        uuid: uuid)))))
                }
            } catch {
                sendDataMessage(
                    .capturePhotoResponse,
                    data: try! JSONEncoder.shared.encode(CapturePhotoResponseData(message: "\(error)")))
            }
        }
    }
}
