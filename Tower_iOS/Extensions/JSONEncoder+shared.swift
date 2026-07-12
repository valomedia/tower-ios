//
//  JSONEncoder+shared.swift
//  Tower_iOS
//
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
