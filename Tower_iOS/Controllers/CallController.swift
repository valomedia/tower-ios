//
//  CallController.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2023-04-20.
//
//

import Foundation
import AmazonChimeSDK


// MARK: CallController

/// The controller for the call.
///
/// This contains for the application logic for the actual chime SDK itself.
///
class CallController: ObservableObject, AudioVideoObserver, RealtimeObserver {

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
                return "Tower anfunken…"
            case .notConnected:
                return "Verbindung herstellen…"
            case .connecting:
                return "Anrufaufbau…"
            case .reconnecting:
                return "Neu verbinden…"
            case .waiting:
                return "Warten of Lotsen…"
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

    // MARK: - Properties

    /// The life-cycle state of the current session.
    ///
    @Published var state: CallState = .none

    private var session: MeetingSession? = nil

    private let logger = ConsoleLogger(name: "CallController")

    // MARK: - Methods

    /// Callback to invoke when the call ends.
    ///
    var onCallEnd: ((MeetingSessionStatus) -> Void)? = nil

    /// Join a meeting with a given configuration.
    ///
    /// This takes the configuration returned by the join endpoint and connects to the meeting with audio and video.
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

        let audioDevices = session.audioVideo.listAudioDevices()
        for device in audioDevices {
            logger.info(msg: "Device type: \(device.type), label: \(device.label)");
        }

        try session.audioVideo.start()
        try session.audioVideo.startLocalVideo()

        // Default to loudspeaker for now.
        let device = audioDevices
                .filter {
                    $0.type == .audioBuiltInSpeaker
                }
                .first
        device.map(session.audioVideo.chooseAudioDevice(mediaDevice:))
    }

    func audioSessionDidStartConnecting(reconnecting: Bool) {
        logger.info(msg: "audioSessionDidStartConnecting")

        // When reestablishing the connection, move to reconnecting state only if the assistant was already in the call.
        state = state.isConnected && reconnecting ? .reconnecting : .connecting
    }

    func audioSessionDidStart(reconnecting: Bool) {
        logger.info(msg: "audioSessionDidStart")
    }

    func audioSessionDidDrop() {
        logger.info(msg: "audioSessionDidDrop")
        state = .connectionLost
    }

    func audioSessionDidStopWithStatus(sessionStatus: AmazonChimeSDK.MeetingSessionStatus) {
        logger.info(msg: "audioSessionDidStopWithStatus")
    }

    func audioSessionDidCancelReconnect() {
        logger.info(msg: "audioSessionDidCancelReconnect")
        state = .failed
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

    func volumeDidChange(volumeUpdates: [AmazonChimeSDK.VolumeUpdate]) {
        logger.info(msg: "volumeDidChange")
    }

    func signalStrengthDidChange(signalUpdates: [AmazonChimeSDK.SignalUpdate]) {
        logger.info(msg: "signalStrengthDidChange")
    }

    func attendeesDidJoin(attendeeInfo: [AmazonChimeSDK.AttendeeInfo]) {
        logger.info(msg: "attendeesDidJoin")
        state = state == .connecting ? .waiting : .connected

        if (state == .connected) {
            // Switch to the back camera after two seconds.
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.session?.audioVideo.switchCamera()
            }
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

    /// End the meeting.
    ///
    /// This disconnects from the meeting. This is called after onCallEnd() to end the connection as far as the Chime
    /// SDK is concerned. This does not affect the meeting on the server, which should have already ended when this is
    /// called.
    ///
    private func end() {
        session?.audioVideo.stop()
        state = .none
        session = nil
    }
}
