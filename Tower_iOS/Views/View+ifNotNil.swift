//
//  View+ifNotNil.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2023-06-12.
//
//

import Foundation
import SwiftUI


// MARK: View

// MARK: + ifNotNil

extension View {

    /// Applies the given transform if the given optional is not nil.
    ///
    /// - Parameters:
    ///     - optional: An optional.
    ///     - transform: The transform to apply to the source View.
    /// - Returns: Either the original View or the modified View.
    ///
    @ViewBuilder
    func ifNotNil<Content: View, Type: Any>(_ optional: @autoclosure () -> Type?, transform: (Self, Type) -> Content)
            -> _ConditionalContent<Content, Self> {
        if let x = optional() {
            transform(self, x)
        } else {
            self
        }
    }

}