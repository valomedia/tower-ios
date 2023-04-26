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
                return "Nicht verbunden"
            case .notConnected:
                return "Nicht verbunden"
            case .connecting:
                return "Verbinden…"
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
        session = DefaultMeetingSession(configuration: configuration, logger: logger)
        state = .notConnected
        session?.audioVideo.addAudioVideoObserver(observer: self)
        session?.audioVideo.addRealtimeObserver(observer: self)
        try session?.audioVideo.start()
        try session?.audioVideo.startLocalVideo()
    }

    /// End the meeting.
    ///
    /// This disconnects from the meeting. The meeting will not automatically be ended on the server. Use the
    /// corresponding function in TowerApi to make the call to the server to end the meeting there.
    ///
    func end() {
        session?.audioVideo.stop()
        state = .disconnected
    }

    func audioSessionDidStartConnecting(reconnecting: Bool) {
        logger.info(msg: "audioSessionDidStartConnecting")

        // When reestablishing the connection, move to reconnecting state only if the assistant was already in the call.
        state = state.isConnected && reconnecting ? .reconnecting : .connecting
    }

    func audioSessionDidStart(reconnecting: Bool) {
        logger.info(msg: "audioSessionDidStart")
        state = state == .connecting ? .waiting : .connected
    }

    func audioSessionDidDrop() {
        logger.info(msg: "audioSessionDidDrop")
        state = .connectionLost
    }

    func audioSessionDidStopWithStatus(sessionStatus: AmazonChimeSDK.MeetingSessionStatus) {
        logger.info(msg: "audioSessionDidStopWithStatus")
        state = .none
        session = nil
        onCallEnd?(sessionStatus)
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
        state = .connected
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

}
