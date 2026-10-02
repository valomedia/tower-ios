//
//  JSONDecoder+shared.swift
//  Tower_iOS
//
//
//

import Foundation


// MARK: JSONDecoder

// MARK: + shared

extension JSONDecoder {

    /// A shared JSONDecoder instance for use throughout the app.
    ///
    static let shared: JSONDecoder = JSONDecoder()

}
