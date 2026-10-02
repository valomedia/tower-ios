//
//  User.swift
//  tower-ios
//
//  Copyright (c) 2024-2025 valo.media GmbH. All rights reserved.
//

import Foundation

// MARK: User

/// A username associated with an ID for Azure Communication Services.
///
struct User: Codable {

    enum CodingKeys: String, CodingKey {
        case username = "username"
        case communicationUserId = "communicationUserId"
    }

    // MARK: - Properties

    /// The username the user uses to sign in.
    /// 
    var username: String

    /// The id of the user as used by ACS.
    /// 
    var communicationUserId: String

}
