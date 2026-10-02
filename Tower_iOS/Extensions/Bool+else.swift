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


// MARK: Bool

// MARK: + else

extension Bool {

    /// Acts as identity for false Bools, returns nil for true Bools.
    ///
    /// - Parameters:
    ///     - value: The value to maybe return.
    /// - Returns: The value if self is false, nil otherwise.
    ///
    func `else`<Value>(_ value: Value) -> Value? {
        self ? nil : value
    }

    /// Acts as identity for false Bools, returns nil for true Bools.
    ///
    /// This is an overload for values that are already optional, which is needed to avoid nested Optionals being
    /// returned.
    ///
    /// - Parameters:
    ///     - value: The value to maybe return.
    /// - Returns: The value if self is false, nil otherwise.
    ///
    func `else`<Value>(_ value: Value?) -> Value? {
        self ? nil : value
    }

}
