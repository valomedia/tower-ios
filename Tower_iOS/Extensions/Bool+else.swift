//
//  Bool+else.swift
//  Tower_iOS
//
//
//

import Foundation


// MARK: Bool

// MARK: + else

extension Bool {

    /// Acts as identity for false Bools, returns nil for true Bools.
    ///
    /// - Parameters:
    ///     - value: The value to maybe return.
    /// - Returns: The value if self is false, nil otherwise.
    ///
    func `else`<Value>(_ value: Value) -> Value? {
        self ? nil : value
    }

    /// Acts as identity for false Bools, returns nil for true Bools.
    ///
    /// This is an overload for values that are already optional, which is needed to avoid nested Optionals being
    /// returned.
    ///
    /// - Parameters:
    ///     - value: The value to maybe return.
    /// - Returns: The value if self is false, nil otherwise.
    ///
    func `else`<Value>(_ value: Value?) -> Value? {
        self ? nil : value
    }

}
