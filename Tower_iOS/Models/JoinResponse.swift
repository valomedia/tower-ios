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
        case joinInfo = "joinInfo"
    }

    // MARK: - Properties

    /// The information needed to join the meeting.
    ///
    var joinInfo: JoinInfo

}


// MARK: JoinInfo

/// The information needed to join the meeting.
///
struct JoinInfo: Codable {

    enum CodingKeys: String, CodingKey {
        case meetingResponse = "meetingResponse"
        case attendeeResponse = "attendeeResponse"
    }

    // MARK: - Properties

    /// The response from the createMeeting API action.
    ///
    var meetingResponse: MeetingResponse

    /// The response from the createAttendee API action.
    ///
    var attendeeResponse: AttendeeResponse

}


// MARK: MeetingResponse

/// The response from the createMeeting API action.
///
struct MeetingResponse: Codable {

    enum CodingKeys: String, CodingKey {
        case meeting = "Meeting"
    }

    // MARK: - Properties

    /// The information needed to construct the Meeting.
    ///
    var meeting: MeetingInfo

}

// MARK: AttendeeResponse

/// The response from the createAttendee API action.
///
struct AttendeeResponse: Codable {

    enum CodingKeys: String, CodingKey {
        case attendee = "Attendee"
    }

    // MARK: - Properties

    /// The information needed to construct the Attendee.
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
