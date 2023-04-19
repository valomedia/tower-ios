//
//  TrailingIconLabelStyle.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2023-04-19.
//
//

import Foundation
import SwiftUI


// MARK: TrailingIconLabelStyle

/// A LabelStyle with the icon after the title.
///
struct TrailingIconLabelStyle: LabelStyle {

    // MARK: - Methods

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            configuration.icon.frame(width: 10)
        }
    }

}


// MARK: LabelStyle

extension LabelStyle where Self == TrailingIconLabelStyle {

    // MARK: + TrailingIconLabelStyle

    /// A LabelStyle with the icon after the title.
    ///
    static var trailingIcon: Self { Self() }

}
