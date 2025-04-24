//
//  DarkModeAwareProminentButtonStyle.swift
//  Tower_iOS
//
//  Created by Arne Engelland on 2025-04-10.
//  Copyright © 2025 valo.media GmbH. All rights reserved.
//

import SwiftUI

// MARK: DarkModeAwareProminentButtonStyle

/// A ButtonStyle based on .borderedProminent that forces black text when in dark mode.
///
struct DarkModeAwareProminentButtonStyle: PrimitiveButtonStyle {

    // MARK: - Properties

    @Environment(\.colorScheme)
    private var colorScheme

    // MARK: - Methods

    func makeBody(configuration: Configuration) -> some View {
        BorderedProminentButtonStyle()
            .makeBody(configuration: configuration)
            .foregroundColor(colorScheme == .dark ? .black : nil)
    }

}

// MARK: - PrimitiveButtonStyle

extension PrimitiveButtonStyle where Self == DarkModeAwareProminentButtonStyle {
    
    // MARK: + darkModeAwareProminent

    /// Dark mode aware prominent button style that forces black text in dark mode.
    /// 
    static var darkModeAwareProminent: DarkModeAwareProminentButtonStyle {
        DarkModeAwareProminentButtonStyle()
    }

}
