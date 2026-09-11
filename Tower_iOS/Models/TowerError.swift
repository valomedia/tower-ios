//
//  TowerError.swift
//  tower-ios
//
//  Copyright (c) 2023-2025 valo.media GmbH. All rights reserved.
//

import Foundation


// MARK: TowerError

/// An error representing an issue while communicating with the service.
///
enum TowerError: Error, Equatable, LocalizedError, CustomStringConvertible {

    /// The requested endpoint is not a valid url.
    ///
    case invalidEndpoint

    /// There are no credentials to authenticate to the api.
    ///
    case missingCredentials

    /// The server responded with a 400-response.
    ///
    case badRequest

    /// The credentials are wrong.
    ///
    case badCredentials

    /// The server responded with a 404-response.
    ///
    case notFound

    /// The server responded that the registered user does not exist.
    ///
    case userNotFound

    /// The server responded with a 5XX-response.
    ///
    case serverError

    /// The server responded with a status code other than 200, 400, 401, 404, or 5XX for whatever reason.
    ///
    case unexpectedError

    public var description: String {
        switch self {
        case .invalidEndpoint:
            return "Server-URL invalid"
        case .missingCredentials:
            return "Credentials are missing"
        case .badRequest:
            return "Client error"
        case .badCredentials:
            return "Credentials are invalid"
        case .notFound:
            return "Requested resource not found"
        case .userNotFound:
            return "User account not found"
        case .serverError:
            return "Server error"
        case .unexpectedError:
            return "Unexpected error"
        }
    }

    public var errorDescription: String? {
        switch self {
        case .invalidEndpoint:
            return "Server-URL ungültig"
        case .missingCredentials:
            return "Zugangsdaten fehlen"
        case .badRequest:
            return "Clientfehler"
        case .badCredentials:
            return "Zugangsdaten falsch"
        case .notFound:
            return "Angeforderte Ressource nicht gefunden"
        case .userNotFound:
            return "Benutzerkonto nicht gefunden"
        case .serverError:
            return "Serverfehler"
        case .unexpectedError:
            return "Unerwarteter Fehler"
        }
    }

    // MARK: - Methods

    /// Return the error represented by an HTTP response, or `nil` for a successful response.
    ///
    /// A generic 404 must not be interpreted as a missing user: proxies and older API deployments can return the same
    /// status for an unavailable route. Only the backend's explicit machine-readable code (or its current legacy
    /// message) identifies a missing registration.
    ///
    static func responseError(statusCode: Int, data: Data? = nil) -> TowerError? {
        switch statusCode {
        case 200..<300:
            return nil
        case 400:
            return .badRequest
        case 401:
            return .badCredentials
        case 404:
            guard let data,
                  let response = try? JSONDecoder.shared.decode(ErrorResponse.self, from: data),
                  response.code == "USER_NOT_FOUND" || response.error == "User not found"
            else { return .notFound }
            return .userNotFound
        case 500...599:
            return .serverError
        default:
            return .unexpectedError
        }
    }

    // MARK: - Types

    private struct ErrorResponse: Decodable {
        let code: String?
        let error: String?
    }

}
