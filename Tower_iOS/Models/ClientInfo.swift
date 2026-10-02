//
//  ClientInfo.swift
//  tower-ios
//
//  Copyright (c) 2025 valo.media GmbH. All rights reserved.
//

import Foundation

// MARK: ClientInfo

/// Information about the client making the call, that is relevant to the assistance session.
///
/// For now this just contains the bundle identifier and version of the app.
///
struct ClientInfo: Codable {

    enum CodingKeys: String, CodingKey {
        case identifier = "identifier"
        case version = "version"
    }

    // MARK: - Life cycle methods

    init() {
        identifier = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as! String
        version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

    // MARK: - Properties

    /// The bundle identifier of the app.
    ///
    var identifier: String

    /// The version number of the app.
    ///
    var version: String

}
