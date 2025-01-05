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
enum AssistanceSessionState: CustomStringConvertible {

    /// No session has been started.
    ///
    case none

    /// The app is registering an assistance reuest with the backend and connecting to ACS.
    ///
    case initializing

    /// The app is waiting for an assistant to respond to the assistance reuest.
    ///
    case waiting

    /// An assistant has accepted the request and is being connected to the user.
    ///
    case connecting

    /// The user is currently speaking to the assistant.
    ///
    case connected

    /// The assistant has put the user on hold.
    ///
    case onHold

    /// The assistance session has ended.
    ///
    case disconnected

    /// A description of the state in English.
    /// 
    var description: String {
        switch self {
        case .none: return ""
        case .initializing: return "Establishing session…"
        case .waiting: return "Waiting for assistance…"
        case .connecting: return "Connecting call…"
        case .connected: return "Connected"
        case .onHold: return "On hold…"
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
        case .onHold: return "Anruf wird gehalten…"
        case .disconnected: return "Verbindung getrennt"
        }
    }

}
