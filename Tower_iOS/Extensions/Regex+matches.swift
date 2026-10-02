//
// Copyright (c) 2025-2026 valo.media GmbH
// All rights reserved.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
