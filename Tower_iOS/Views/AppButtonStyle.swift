//
//  AppButtonStyle.swift
//  Tower_iOS
//
//  Created by Arne Engelland on 08.04.25.
//  Copyright © 2025 valo.media GmbH. All rights reserved.
//

import SwiftUI

// Layout modes: full-width (form-style) or auto-size (minimal buttons)
enum AppButtonLayoutMode {
    case fullWidth
    case autoSize
}

struct AppButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme

    var layoutMode: AppButtonLayoutMode = .fullWidth

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .modifier(ConditionalFrameModifier(applyFullWidth: layoutMode == .fullWidth))
            .background(accentColor)
            .foregroundColor(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }

    private var accentColor: Color {
        Color(uiColor: Asset.Assets.accentColor.color)
    }

    private var foregroundColor: Color {
        colorScheme == .dark ? .black : .white
    }
}

private struct ConditionalFrameModifier: ViewModifier {
    let applyFullWidth: Bool

    func body(content: Content) -> some View {
        if applyFullWidth {
            content.frame(maxWidth: .infinity)
        } else {
            content
        }
    }
}
