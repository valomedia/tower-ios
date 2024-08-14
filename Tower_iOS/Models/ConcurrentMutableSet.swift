//
//  ConcurrentMutableSet.swift
//  Tower_iOS
//
//  Added by Jean-Pierre Höhmann on 2024-08-05.
//  Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation


// MARK: ConcurrentMutableSet

class ConcurrentMutableSet {
    
    // MARK: - Properties
    
    var count: Int {
        return set.count
    }

    private let lock = NSRecursiveLock()
    private let set = NSMutableSet()
    
    // MARK: - Methods
    
    func add(_ object: Any) {
        lock.lock()
        defer { lock.unlock() }
        set.add(object)
    }

    func remove(_ object: Any) {
        lock.lock()
        defer { lock.unlock() }
        set.remove(object)
    }
    
    func removeAll() {
        lock.lock()
        defer { lock.unlock() }
        set.removeAllObjects()
    }

    func contains(_ object: Any) -> Bool {
        return set.contains(object)
    }

    func forEach(_ body: (Any) throws -> Void) rethrows {
        lock.lock()
        defer { lock.unlock() }
        try set.forEach(body)
    }
    
}
