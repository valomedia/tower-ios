//
//  CameraError.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2024-08-01.
//
//

import Foundation


// MARK: CameraError

/// An error representing an issue with accessing the camera.
///
enum CameraError: Error, LocalizedError, CustomStringConvertible {
    case codecUnavailable
    case unexpectedError

    public var description: String {
        switch self {
        case .codecUnavailable:
            return "Codec unavailable"
        case .unexpectedError:
            return "Unexpected error"
        }
    }

    public var errorDescription: String? {
        switch self {
        case .codecUnavailable:
            return "Codec nicht verfügbar"
        case .unexpectedError:
            return "Unerwarteter Fehler"
        }
    }

}
