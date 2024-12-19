//
//  ErrorEvent.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2024-12-19.
//  Copyright (c) 2024 valo.media GmbH. All rights reserved.
//

import Foundation

// MARK: ErrorEvent

///
///
struct ErrorEvent: Codable {

    enum CodingKeys: String, CodingKey {
        case description = "description"
        case localizedDescription = "localizedDescription"
    }

    // MARK: - Life cycle methods

    init(description: String, localizedDescription: String? = nil) {
        self.description = description
        self.localizedDescription = localizedDescription
    }

    init(_ error: Error) {
        self.init(description: "\(error)", localizedDescription: error.localizedDescription)
    }

    // MARK: - Properties

    var description: String

    var localizedDescription: String?

}
