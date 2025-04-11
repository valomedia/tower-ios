//
//  View+invertedForegroundColor.swift
//  Tower_iOS
//
//  Created by Arne Engelland on 10.04.25.
//  Copyright © 2025 valo.media GmbH. All rights reserved.
//

import SwiftUI

/// A modifier that applies black text in dark mode only if accessibility contrast is increased.
private struct InvertedForegroundColor: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        if colorScheme == .dark && UITraitCollection.current.accessibilityContrast == .high {
            content.foregroundColor(.black)
        } else {
            content
        }
    }
}

extension View {
    /// Applies `.foregroundColor(.black)` in dark mode + increased accessibility contrast only.
    func invertedForegroundColor() -> some View {
        self.modifier(InvertedForegroundColor())
    }
}

