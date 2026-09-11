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

    // MARK: - Life cycle methods

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        username = try container.decode(String.self, forKey: .username)
        communicationUserId = try container.decode(String.self, forKey: .communicationUserId)
        profile = try UserProfile(from: decoder)
    }

    // MARK: - Properties

    /// The username the user uses to sign in.
    /// 
    var username: String

    /// The id of the user as used by ACS.
    /// 
    var communicationUserId: String

    /// The user-provided profile fields returned by the backend.
    ///
    var profile: UserProfile

    // MARK: - Methods

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(username, forKey: .username)
        try container.encode(communicationUserId, forKey: .communicationUserId)
        try profile.encode(to: encoder)
    }

}
