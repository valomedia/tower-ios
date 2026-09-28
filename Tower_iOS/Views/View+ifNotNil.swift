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


// MARK: View

// MARK: + ifNotNil

extension View {

    /// Applies the given transform if the given optional is not nil.
    ///
    /// - Parameters:
    ///     - optional: An optional.
    ///     - transform: The transform to apply to the source View.
    /// - Returns: Either the original View or the modified View.
    ///
    @ViewBuilder
    func ifNotNil<Content: View, Type: Any>(_ optional: @autoclosure () -> Type?, transform: (Self, Type) -> Content)
            -> _ConditionalContent<Content, Self> {
        if let x = optional() {
            transform(self, x)
        } else {
            self
        }
    }

}