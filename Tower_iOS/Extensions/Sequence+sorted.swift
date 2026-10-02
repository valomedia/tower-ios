//
//  Sequence+sorted.swift
//  tower-ios
//
//  Copyright (c) 2025 valo.media GmbH. All rights reserved.
//

import Foundation

// MARK: Sequence

extension Sequence {

    // MARK: + sorted

    /// Returns the elements of the sequence, sorted in increasing order using the given keypath.
    ///
    /// - Parameters
    ///     - keyPath: The path from the element of the sequence to the value to sort by.
    ///
    /// - Returns: A sorted array of the sequence's elements.
    ///
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        sorted { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
    }

}
