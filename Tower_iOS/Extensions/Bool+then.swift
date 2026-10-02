//
// Copyright (c) 2023-2026 valo.media GmbH
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


// MARK: Bool

// MARK: + then

extension Bool {

    /// Acts as identity for true Bools, returns nil for false Bools.
    ///
    /// - Parameters:
    ///     - value: The value to maybe return.
    /// - Returns: The value if self is true, nil otherwise.
    ///
    func then<Value>(_ value: Value) -> Value? {
        self ? value : nil
    }

    /// Acts as identity for true Bools, returns nil for false Bools.
    ///
    /// This is an overload for values that are already optional, which is needed to avoid nested Optionals being
    /// returned.
    ///
    /// - Parameters:
    ///     - value: The value to maybe return.
    /// - Returns: The value if self is true, nil otherwise.
    ///
    func then<Value>(_ value: Value?) -> Value? {
        self ? value : nil
    }

}

precedencegroup ThenPrecedence {
    higherThan: NilCoalescingPrecedence
}

infix operator .!!: ThenPrecedence

/// Operator for the then-function.
///
/// This will return the right hand side, iff the left hand side is true.
///
/// - Parameters:
///     - left: Boolean to check.
///     - right: Value to return, if left is true.
/// - Returns: Right, if left is true, nil otherwise.
///
func .!!<Value>(left: Bool, right: Value) -> Value? {
    left.then(right)
}

/// Operator for the then-function.
///
/// This will return the right hand side, iff the left hand side is true. This is an overload for values that are
/// already optional, which is needed to avoid nested Optionals being returned.
///
/// - Parameters:
///     - left: Boolean to check.
///     - right: Value to return, if left is true.
/// - Returns: Right, if left is true, nil otherwise.
///
func .!!<Value>(left: Bool, right: Value?) -> Value? {
    left.then(right)
}
