//
//  JoinResponse.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2023-04-20.
//
//

import Foundation


// MARK: JoinResponse

/// The response from the join-endpoint.
///
struct JoinResponse: Codable {

    enum CodingKeys: String, CodingKey {
        case meeting = "Meeting"
        case attendee = "Attendee"
    }

    // MARK: - Properties

    /// The information needed to construct a Meeting.
    ///
    var meeting: MeetingInfo

    /// The information needed to construct an Attendee.
    ///
    var attendee: AttendeeInfo

}


// MARK: MeetingInfo

/// The information needed to construct a Meeting.
///
struct MeetingInfo: Codable {

    enum CodingKeys: String, CodingKey {
        case externalMeetingId = "ExternalMeetingId"
        case primaryMeetingId = "PrimaryMeetingId"
        case mediaPlacement = "MediaPlacement"
        case mediaRegion = "MediaRegion"
        case meetingId = "MeetingId"
    }

    // MARK: - Properties

    /// Tower meeting id.
    ///
    var externalMeetingId: String?

    /// Unused.
    ///
    var primaryMeetingId: String?

    /// Media URLs.
    ///
    var mediaPlacement: MediaPlacementInfo

    /// The AWS region being used.
    ///
    var mediaRegion: String

    /// Chime meeting id.
    ///
    var meetingId: String

}


// MARK: AttendeeInfo

/// The information needed to construct an Attendee.
///
struct AttendeeInfo: Codable {

    enum CodingKeys: String, CodingKey {
        case attendeeId = "AttendeeId"
        case externalUserId = "ExternalUserId"
        case joinToken = "JoinToken"
    }

    // MARK: - Properties

    /// Chime attendee id.
    ///
    var attendeeId: String

    /// Tower attendee id.
    ///
    var externalUserId: String

    /// Access token.
    ///
    var joinToken: String

}


// MARK: MediaPlacementInfo

/// The URLs for the media in the meeting.
///
struct MediaPlacementInfo: Codable {

    enum CodingKeys: String, CodingKey {
        case audioFallbackUrl = "AudioFallbackUrl"
        case audioHostUrl = "AudioHostUrl"
        case signalingUrl = "SignalingUrl"
        case turnControlUrl = "TurnControlUrl"
        case eventIngestionUrl = "EventIngestionUrl"
    }

    // MARK: - Properties

    /// The audio fallback URL.
    ///
    var audioFallbackUrl: String?

    /// The audio host URL.
    ///
    var audioHostUrl: String

    /// The signaling URL.
    ///
    var signalingUrl: String

    /// The turn control URL.
    ///
    var turnControlUrl: String?

    /// The event ingestion URL.
    ///
    var eventIngestionUrl: String?

}
