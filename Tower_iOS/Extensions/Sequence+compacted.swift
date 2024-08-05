//
//  Sequence+compacted.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2024-08-05.
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
