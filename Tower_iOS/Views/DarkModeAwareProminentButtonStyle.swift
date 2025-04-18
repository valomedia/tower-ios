//
//  DarkModeAwareProminentButtonStyle.swift
//  Tower_iOS
//
//  Created by Arne Engelland on 10.04.25.
//  Copyright © 2025 valo.media GmbH. All rights reserved.
//

import SwiftUI

/// A ButtonStyle based on .borderedProminent that forces black text when in dark mode.
///
struct DarkModeAwareProminentButtonStyle: PrimitiveButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    func makeBody(configuration: Configuration) -> some View {
        BorderedProminentButtonStyle()
            .makeBody(configuration: configuration)
            .foregroundColor(colorScheme == .dark ? .black : nil)
    }
}

/// An extension that allows the use of the darkModeAwareProminent button style (forces black text in dark mode)
///
extension PrimitiveButtonStyle where Self == DarkModeAwareProminentButtonStyle {
    static var darkModeAwareProminent: DarkModeAwareProminentButtonStyle {
        DarkModeAwareProminentButtonStyle()
    }
}
