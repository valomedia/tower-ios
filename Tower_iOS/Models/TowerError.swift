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
enum TowerError: Error, LocalizedError, CustomStringConvertible {

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
            return "Assistance request not found"
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
            return "Hilfegesuch nicht gefunden"
        case .serverError:
            return "Serverfehler"
        case .unexpectedError:
            return "Unerwarteter Fehler"
        }
    }

}
