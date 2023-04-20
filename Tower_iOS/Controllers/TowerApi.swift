//
//  TowerApi.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2023-04-20.
//
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
    /// are set correctly in the settings.
    ///
    /// - Returns:
    /// - Throws:
    ///
    @discardableResult class func index() async throws -> [String: String] {
        let url = URL(string: Settings.endpointPreference)
        guard let url else { throw TowerError.invalidEndpoint }

        let data = try await request(url: url)

        let result = try JSONSerialization.jsonObject(with: data) as? [String: String]
        guard let result else { throw TowerError.unexpectedError }

        return result
    }

    private class func request(url: URL) async throws -> Data {
        let user = Settings.usernamePreference
        let pass = Settings.passwordPreference
        guard user != "" && pass != "" else { throw TowerError.missingCredentials }

        let auth = (user + ":" + pass).data(using: .utf8)?.base64EncodedString()
        guard let auth else { throw TowerError.badCredentials }

        var request = URLRequest(url: url)
        request.setValue("Basic " + auth, forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse else { throw TowerError.invalidEndpoint }

        switch response.statusCode {
        case 200:
            return data
        case 401:
            throw TowerError.badCredentials
        case 500...599:
            throw TowerError.serverError
        default:
            throw TowerError.unexpectedError
        }
    }

}
