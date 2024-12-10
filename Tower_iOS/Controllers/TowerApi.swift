//
//  TowerApi.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2023-04-20.
//
//

import Foundation
import AmazonChimeSDK


// MARK: TowerApi

/// The implementation of the api for the backend.
///
/// This implements a function call for each endpoint the backend has.  Currently this is completely stateless, so it
/// is just a collection of class methods, but this is intended to become a singleton in the future that views can
/// depend on by declaring it as an @EnvironmentObject.
///
class TowerApi {

    // MARK: - Class methods

    /// Make a request to the index endpoint.
    ///
    /// The index endpoint will return return a JSON-Object with a single field called message, that contains the
    /// string “success”, if the request is successful.  It is useful to verify that the credentials and api endpoint
    /// are set correctly in the settings.  Since the return value isn't used for anything, this function doesn't
    /// bother with parsing it and instead just returns Void.
    ///
    /// - Throws:
    ///
    class func index() async throws -> Void {
        try await request()
    }

    /// Make a request for an assistance session.
    /// 
    /// This will retrieve an access token for Azure Communication Services from the backend and add the user to the
    /// queue of users waiting for an assistant.
    ///
    /// - Returns: The RequestAssistanceResponse with the UserToken.
    /// - Throws:
    /// 
    class func requestAssistance() async throws -> RequestAssistanceResponse {
        try JSONDecoder.shared.decode(
            RequestAssistanceResponse.self,
            from: await request ("POST", "/requestAssistance"))
    }

    /// Signal to the backend, that the caller is still waiting.
    /// 
    /// This will inform the backend, that the caller is still on the line, so the assistance request doesn't time out.
    /// 
    /// - Throws:
    /// 
    class func awaitAssistance() async throws -> Void {
        try await request ("POST", "/awaitAssistance")
    }

    /// Signal to the backend, that the caller has given up on waiting.
    /// 
    /// This will inform the backend, that the caller has cancelled the assistance request and no assistant needs to
    /// respond anymore.
    /// 
    /// - Throws:
    /// 
    class func cancelAssistance() async throws -> Void {
        try await request("POST", "/cancelAssistance")
    }

    /// Make a request to the start endpoint.
    ///
    /// The start endpoint will create both the room and the attendee.
    ///
    /// - Returns: A MeetingSessionConfiguration with the new meeting and attendee already configured in it.
    /// - Throws:
    ///
    class func start() async throws -> MeetingSessionConfiguration {
        let data = try await request("POST", "/start");
        let joinResponse = try JSONDecoder.shared.decode(JoinResponse.self, from: data)
        let meeting = joinResponse.joinInfo.meetingResponse.meeting
        let attendee = joinResponse.joinInfo.attendeeResponse.attendee

        return MeetingSessionConfiguration(
                createMeetingResponse: CreateMeetingResponse(
                        meeting: Meeting(
                                externalMeetingId: meeting.externalMeetingId,
                                mediaPlacement: MediaPlacement(
                                        audioFallbackUrl: meeting.mediaPlacement.audioFallbackUrl ?? "",
                                        audioHostUrl: meeting.mediaPlacement.audioHostUrl,
                                        signalingUrl: meeting.mediaPlacement.signalingUrl,
                                        turnControlUrl: meeting.mediaPlacement.turnControlUrl ?? "",
                                        eventIngestionUrl: meeting.mediaPlacement.eventIngestionUrl),
                                mediaRegion: meeting.mediaRegion,
                                meetingId: meeting.meetingId
                        )
                ),
                createAttendeeResponse: CreateAttendeeResponse(
                        attendee: Attendee(
                                attendeeId: attendee.attendeeId,
                                externalUserId: attendee.externalUserId,
                                joinToken: attendee.joinToken)
                )
        )
    }

    /// Make a request to the end endpoint.
    ///
    /// The end endpoint will remove the meeting, causing all attendee connections to hang up.
    ///
    /// - Throws:
    ///
    class func end(sessionConfiguration: MeetingSessionConfiguration) async throws -> Void {
        try await request("POST", "/end?meetingId=" + sessionConfiguration.meetingId);
    }

    @discardableResult
    private class func request(_ method: String = "GET", _ path: String = "/") async throws -> Data {
        let user = Settings.usernamePreference
        let pass = Settings.passwordPreference
        guard user != "" && pass != "" else { throw TowerError.missingCredentials }

        let auth = (user + ":" + pass).data(using: .utf8)?.base64EncodedString()
        guard let auth else { throw TowerError.badCredentials }

        let url = URL(string: Settings.endpointPreference + path)
        guard let url else { throw TowerError.invalidEndpoint }

        var request = URLRequest(url: url)
        request.setValue("Basic " + auth, forHTTPHeaderField: "Authorization")
        request.httpMethod = method

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse else { throw TowerError.invalidEndpoint }

        switch response.statusCode {
        case 200:
            return data
        case 401:
            throw TowerError.badCredentials
        case 404:
            throw TowerError.notFound
        case 500...599:
            throw TowerError.serverError
        default:
            throw TowerError.unexpectedError
        }
    }

}
