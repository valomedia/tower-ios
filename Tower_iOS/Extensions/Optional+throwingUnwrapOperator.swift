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


// MARK: Optional

postfix operator .!?

// MARK: + throwingUnwrapOperator

extension Optional {

    /// Unwrap a value throwing an UnwrapError, if the value is nil.
    ///
    /// This is intended to be used in situations where the value can't reasonably be nil, but if for whatever reason
    /// it is, we still want to at least display an error instead of just crashing.  Don't use this in situations where
    /// the error can be nil during normal functioning of the app, since the thrown Error is unspecific and unhelpful.
    ///
    static postfix func .!?(_ optional: Optional) throws -> Wrapped {
        guard let wrapped = optional else { throw UnwrapError() }
        return wrapped
    }
}

// MARK: + UnwrapError

extension Optional {

    /// The Error thrown if the throwing unwrap operator encountered a nil value.
    ///
    struct UnwrapError: Error {}

}
