//
//  UpdateUserRequest.swift
//  tower-ios
//
//  Copyright (c) 2026 valo.media GmbH. All rights reserved.
//

import Foundation

// MARK: UpdateUserRequest

/// The data sent to the `/updateUser` endpoint.
///
struct UpdateUserRequest: Encodable {

    enum CodingKeys: String, CodingKey {
        case userId = "userId"
    }

    // MARK: - Properties

    /// The unique identifier for the user to update.
    ///
    let userId: String

    /// The complete profile to write for the user.
    ///
    let profile: UserProfile

    // MARK: - Methods

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try profile.encode(to: encoder)
    }

}
