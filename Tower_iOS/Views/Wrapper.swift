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


// MARK: Wrapper

/// A View that wraps another View without modifying it.
///
/// This View does nothing on its own.  It is only useful in combination with modifiers.  The typical use-case for this
/// View is to break up an expression into distinct sub-expressions in order to prevent Swift's type-checker from
/// crapping its pants, but it is also useful to achieve certain visual styles in a more declarative style than would
/// otherwise be possible.
///
struct Wrapper<Content: View>: View {

    // MARK: - Life cycle methods

    /// Constructor.
    ///
    /// - Parameters
    ///     - content: A ViewBuilder that builds the Content to wrap.
    ///
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    // MARK: - Properties

    var body: some View {
        content()
    }

    // MARK: - Methods

    /// A callback that produces the Content to wrap.
    ///
    var content: () -> Content

}
