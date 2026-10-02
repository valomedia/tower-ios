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


// MARK: ErrorWrapper

/// An Error with metadata for display in the UI.
///
/// This is a wrapper around Error that makes it Identifiable and supplements it with a guidance String.
///
struct ErrorWrapper: Identifiable {


    // MARK: - Properties

    let id = UUID()

    /// The wrapped Error.
    ///
    let error: Error

    /// Guidance for the user.
    ///
    /// This is a string containing some information intended to give the user advice on how to proceed.
    ///
    let guidance: String

}
