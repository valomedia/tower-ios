//
//  Sequence+compacted.swift
//  Tower_iOS
//
//
//

import Foundation


// MARK: Sequence

// MARK: + compacted

extension Sequence {

    @inlinable func compacted<Unwrapped>() -> [Unwrapped] where Element == Unwrapped? {
        self.compactMap { $0 }
    }

}
