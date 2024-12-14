//
//  UserToken.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2024-12-10.
//  Copyright (c) 2024 valo.media GmbH. All rights reserved.
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
