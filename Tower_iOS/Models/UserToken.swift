//
//  UserToken.swift
//  tower-ios
//
//  Copyright (c) 2024-2025 valo.media GmbH. All rights reserved.
//

import Foundation

// MARK: UserToken

/// A user associated with an access token.
///
struct UserToken: Codable {

    enum CodingKeys: String, CodingKey {
        case user = "user"
        case token = "token"
    }

    // MARK: - Properties

    /// The `User` this `UserToken` is for.
    /// 
    var user: User

    /// The access token issued for the user.
    /// 
    var token: String

}
