//
//  TowerError.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2023-04-19.
//  Copyright (c) 2023-2025 valo.media GmbH. All rights reserved.
//

import Foundation


// MARK: TowerError

/// An error representing an issue while communicating with the service.
///
enum TowerError: Error, LocalizedError, CustomStringConvertible {
    case invalidEndpoint
    case missingCredentials
    case badCredentials
    case notFound
    case serverError
    case unexpectedError

    public var description: String {
        switch self {
        case .invalidEndpoint:
            return "Server-URL invalid"
        case .missingCredentials:
            return "Credentials are missing"
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
