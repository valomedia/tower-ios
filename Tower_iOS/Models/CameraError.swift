//
//  CameraError.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2024-08-01.
//  Copyright (c) 2024-2025 valo.media GmbH. All rights reserved.
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
