//
//  GetUserResponse.swift
//  tower-ios
//
//  Copyright (c) 2026 valo.media GmbH. All rights reserved.
//

import Foundation

// MARK: GetUserResponse

/// The data returned by the `/getUser` endpoint.
///
struct GetUserResponse: Codable {

    // MARK: - Properties

    /// The user retrieved from the backend.
    ///
    var user: User

}
