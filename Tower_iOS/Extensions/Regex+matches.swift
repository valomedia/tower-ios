//
//  Regex+matches.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2025-01-22.
//  Copyright (c) 2025 valo.media GmbH. All rights reserved.
//

import Foundation

// MARK: Regex

extension Regex {

    // MARK: + matches

    /// Check if the regex matches a given String.
    ///
    /// - Parameters
    ///     - string: The String to match this regular expression against.
    ///
    /// - Returns: True if the String matches, false otherwise.
    ///
    /// - Throws: An Error, if this Regex includes a transformation closure that throws an error.
    ///
    func matches(_ string: String) throws -> Bool {
        return try self.firstMatch(in: string) != nil
    }

}

infix operator =~

/// Operator for the matches-function.
///
/// This will check if the given regex matches a given String.
/// 
/// - Parameters:
///   - string: The String to match the regular expression against.
///   - regex: The Regex to use to match the string.
///
/// - Returns: True if the String matches, false otherwise.
///
/// - Throws: An Error, if the Regex includes a transformation closure that throws an error.
///
func =~<Output>(string: String, regex: Regex<Output>) throws -> Bool {
    return try regex.matches(string)
}
