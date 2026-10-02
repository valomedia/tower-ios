//
// Copyright (c) 2023-2026 valo.media GmbH
// All rights reserved.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
