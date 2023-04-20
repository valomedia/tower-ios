//
//  JSONDecoder+shared.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2023-04-20.
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
