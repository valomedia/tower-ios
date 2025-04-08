//
//  AppButtonStyle.swift
//  Tower_iOS
//
//  Created by Arne Engelland on 08.04.25.
//  Copyright © 2025 valo.media GmbH. All rights reserved.
//

import SwiftUI

struct AppButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(accentColor)
            .foregroundColor(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }

    private var accentColor: Color {
        // Use SwiftGen's color if needed
        Color(uiColor: Asset.Assets.accentColor.color)
    }

    private var foregroundColor: Color {
        // In dark mode, if your accent color is light, switch to black text
        colorScheme == .dark ? .black : .white
    }
}
