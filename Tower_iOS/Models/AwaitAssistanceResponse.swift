//
//  AwaitAssistanceResponse.swift
//  tower-ios
//
//  Copyright (c) 2025 valo.media GmbH. All rights reserved.
//

import Foundation

// MARK: AwaitAssistanceResponse

/// The data returned by the `/awaitAssistance`-endpoint.
///
struct AwaitAssistanceResponse: Codable {

    enum CodingKeys: String, CodingKey {
        case position = "position"
    }

    // MARK: - Properties

    /// The position of the user in the queue.
    ///
    /// This is the zero-indexed position of the user in the list of users waiting to be assisted, which is equal to
    /// the number of people who are ahead of the user in the queue.
    ///
    var position: Int

}
