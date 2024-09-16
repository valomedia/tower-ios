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
                return "Anruf startet…"
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

    // MARK: - Life cycle methods

    /// Constructor.
    ///
    init() { }

    // MARK: - Properties

    /// The life-cycle state of the current session.
    ///
    @Published var state: CallState = .none

    /// The MeetingSession this CallController is attached to.
    ///
    @Published var session: MeetingSession? = nil

    private var locationController: LocationController? = nil

    private let logger = ConsoleLogger(name: "CallController")
    private let localVideoConfig = LocalVideoConfiguration(maxBitRateKbps: 2500)
    private let cameraController = CameraController()

    // MARK: - Methods

    /// Callback to invoke when the call ends.
    ///
    var onCallEnd: ((MeetingSessionStatus) -> Void)? = nil

    /// Join a meeting with a given configuration.
    ///
    /// This takes the configuration returned by the start endpoint and connects to the meeting with audio and video.
    ///
    /// - Parameter configuration: The MeetingSessionConfiguration
    /// - Throws:
    ///
    func join(configuration: MeetingSessionConfiguration) throws {
        let session = DefaultMeetingSession(configuration: configuration, logger: logger)
        self.session = session
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

        session.audioVideo.startLocalVideo(source: cameraController, config: localVideoConfig)

        // Default to loudspeaker for now.
        let device = audioDevices
                .filter {
                    $0.type == .audioBuiltInSpeaker
                }
                .first
        device.map(session.audioVideo.chooseAudioDevice(mediaDevice:))
        try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)

        locationController = LocationController()
        locationController?.callController = self
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
        logger.info(msg: "audioSessionDidStopWithStatus")
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
        logger.info(msg: "videoSessionDidStartWithStatus")
    }

    func videoSessionDidStopWithStatus(sessionStatus: AmazonChimeSDK.MeetingSessionStatus) {
        logger.info(msg: "videoSessionDidStopWithStatus")
        state = .disconnected
        AVPlayer.callRingbackTone.pause()
        AVPlayer.callEndTone.seek(to: CMTime.zero)
        AVPlayer.callEndTone.play()
        onCallEnd?(sessionStatus)
        end()
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

    /// End the meeting.
    ///
    /// This disconnects from the meeting. This is called after onCallEnd() to end the connection as far as the Chime
    /// SDK is concerned. This does not affect the meeting on the server, which should have already ended when this is
    /// called.
    ///
    private func end() {
        session?.audioVideo.stop()
        cameraController.stop()
        cameraController.torchEnabled = false
        state = .none
        session = nil
        locationController = nil
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
