//
//  TowerApi.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2023-04-20.
//  Copyright (c) 2023-2025 valo.media GmbH. All rights reserved.
//

import Foundation

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
    class func index() async throws -> IndexResponse {
        try JSONDecoder.shared.decode(IndexResponse.self, from: await request())
    }

    /// Make a request to create an identity for this instance of the app.
    ///
    /// This will create an identity on the tower backend under a random UUID, along with an asssociated identity in
    /// Azure Communication Services. The UUID of this lightweight user will be supplied with all following requests
    /// to allow the backend to associate all requests coming from the same instance of the app.
    ///
    /// - Returns: The RegisterUserResponse with the UUID.
    /// - Throws:
    ///
    class func registerUser() async throws -> RegisterUserResponse {
        try JSONDecoder.shared.decode(
            RegisterUserResponse.self,
            from: await request("POST", "/registerUser"))
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
