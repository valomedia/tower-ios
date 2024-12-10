//
//  AssistanceSessionState.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2024-12-10.
//  Copyright (c) 2024 valo.media GmbH. All rights reserved.
//

import Foundation

// MARK: AssistanceSessionState

/// An enum representing the lifecycle of an assistance session.
///
enum AssistanceSessionState {
    case none
    case initializing
    case waiting
    case connecting
    case connected
    case disconnected

    /// A description of the state in English.
    /// 
    var description: String {
        switch self {
        case .none: return ""
        case .initializing: return "Establishing session…"
        case .waiting: return "Warten auf Assistenz…"
        case .connecting: return "Connecting call…"
        case .connected: return "Connected"
        case .disconnected: return "Call ended"
        }
    }

    /// A description of the state in German.
    ///
    var localizedDescription: String {
        switch self {
        case .none: return ""
        case .initializing: return "Verbindung herstellen…"
        case .waiting: return "Warten auf Assistenz…"
        case .connecting: return "Anrufaufbau…"
        case .connected: return "Verbunden"
        case .disconnected: return "Verbindung getrennt"
        }
    }

}
