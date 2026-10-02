//
// Copyright (c) 2024-2026 valo.media GmbH
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


// MARK: CameraError

/// An error representing an issue with accessing the camera.
///
enum CameraError: Error, LocalizedError, CustomStringConvertible {
    case unavailable
    case unauthorized
    case configurationFailure
    case codecUnavailable
    case exportFailed
    case unexpectedError

    public var description: String {
        switch self {
        case .unavailable:
            return "Camera unavailable"
        case .unauthorized:
            return "Camera access not authorized"
        case .configurationFailure:
            return "Camera configuration failure"
        case .codecUnavailable:
            return "Codec unavailable"
        case .exportFailed:
            return "Export failed"
        case .unexpectedError:
            return "Unexpected error"
        }
    }

    public var errorDescription: String? {
        switch self {
        case .unavailable:
            return "Kamera nicht verfügbar"
        case .unauthorized:
            return "Kamerazugriff nicht authorisiert"
        case .configurationFailure:
            return "Kamerakonfiguration fehlgeschlagen"
        case .codecUnavailable:
            return "Codec nicht verfügbar"
        case .exportFailed:
            return "Export fehlgeschlagen"
        case .unexpectedError:
            return "Unerwarteter Fehler"
        }
    }

}
