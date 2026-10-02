//
//  View+hidden.swift
//  Tower_iOS
//
//
//

import Foundation
import SwiftUI


// MARK: View

// MARK: + hidden

extension View {

    /// Hides a view conditionally
    ///
    /// - Parameters:
    ///     - hidden: Whether to hide the view.
    /// - Returns: Either the original View or the modified View.
    ///
    @ViewBuilder
    func hidden(_ hidden: Bool) -> _ConditionalContent<some View, Self> {
        self.if(hidden) { $0.hidden() }
    }

}