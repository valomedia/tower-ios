//
//  InvertedProminentButtonStyle.swift
//  Tower_iOS
//
//  Created by Arne Engelland on 10.04.25.
//  Copyright © 2025 valo.media GmbH. All rights reserved.
//

import SwiftUI

/// A button style for prominent buttons that inverts the text color
/// based on the current color scheme.
/// - In light mode: White text on accent color background.
/// - In dark mode: Black text on accent color background.
///
public struct InvertedProminentButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme

    /// Creates an inverted prominent button style.
    public init() { }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(accentColor)
            .foregroundColor(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }

    /// Returns the accent color from the asset catalog.
    private var accentColor: Color {
        // Adjust this if your accent color is provided differently in your project.
        Color(uiColor: Asset.Assets.accentColor.color)
    }

    /// Chooses the text color based on the current color scheme.
    private var foregroundColor: Color {
        colorScheme == .dark ? .black : .white
    }
}

// Extension to allow using the style with the same syntax as .borderedProminent
extension ButtonStyle where Self == InvertedProminentButtonStyle {
    /// A button style similar to .borderedProminent but with inverted text color logic.
    static var invertedProminent: InvertedProminentButtonStyle {
        InvertedProminentButtonStyle()
    }
}
