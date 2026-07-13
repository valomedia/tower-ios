//
//  LeadingIconLabelStyle.swift
//  Tower_iOS
//
//
//

import Foundation
import SwiftUI


// MARK: LeadingIconLabelStyle

/// A LabelStyle where the icon precedes the title.
///
/// This LabelStyle is very similar to the TitleAndIconLabelStyle, except that it is setup to have a spacing that
/// matches the TrailingIconLabelStyle.
///
struct LeadingIconLabelStyle: LabelStyle {

    // MARK: - Methods

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon.frame(width: 10)
            configuration.title
        }
    }

}


// MARK: LabelStyle

// MARK: + LeadingIconLabelStyle

extension LabelStyle where Self == LeadingIconLabelStyle {

    // MARK: - Static properties

    /// A LabelStyle where the icon precedes the title.
    ///
    static var leadingIcon: Self { Self() }

}
