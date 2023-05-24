//
//  Bool+then.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2023-05-24.
//
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
