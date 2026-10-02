//
// Copyright (c) 2023-2026 valo.media GmbH
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
