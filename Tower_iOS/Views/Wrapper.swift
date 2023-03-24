//
//  Wrapper.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2023-03-24.
//
//

import Foundation
import SwiftUI


// MARK: Wrapper

/// A View that wraps another View without modifying it.
///
/// This View does nothing on its own.  It is only useful in combination with modifiers.  The typical use-case for this
/// View is to break up an expression into distinct sub-expressions in order to prevent Swift's type-checker from
/// crapping its pants, but it is also useful to achieve certain visual styles in a more declarative style than would
/// otherwise be possible.
///
struct Wrapper<Content: View>: View {

    // MARK: - Life cycle methods

    /// Constructor.
    ///
    /// - Parameters
    ///     - content: A ViewBuilder that builds the Content to wrap.
    ///
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    // MARK: - Properties

    var body: some View {
        content()
    }

    // MARK: - Methods

    /// A callback that produces the Content to wrap.
    ///
    var content: () -> Content

}
