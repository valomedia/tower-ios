//
// Copyright (c) 2025-2026 valo.media GmbH
// All rights reserved.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
