//
//  JSONEncoder+shared.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2023-05-24.
//
//

import Foundation


// MARK: JSONEncoder

// MARK: + shared

extension JSONEncoder {

    /// A shared JSONEncoder for use throughout the application.
    ///
    static let shared: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        return encoder
    }()

}
