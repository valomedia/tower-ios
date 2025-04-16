//
//  darkModeAwareProminentButtonStyle.swift
//  Tower_iOS
//
//  Created by Arne Engelland on 10.04.25.
//  Copyright © 2025 valo.media GmbH. All rights reserved.
//

import SwiftUI

/// A button style based on `.borderedProminent` that ensures readable text in dark mode
///
struct ContrastAwareProminentButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .buttonStyle(.borderedProminent)
            .foregroundColor(colorScheme == .dark ? .black : .white)
    }
}

extension ButtonStyle where Self == ContrastAwareProminentButtonStyle {
    static var darkModeAwareProminent: ContrastAwareProminentButtonStyle {
        ContrastAwareProminentButtonStyle()
    }
}
