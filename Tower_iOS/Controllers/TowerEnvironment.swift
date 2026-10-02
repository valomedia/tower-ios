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


// MARK: TowerEnvironment

/// Main environment object.
///
/// This class is a view controller that represents all data that is needed across most views. It is added as an
/// EnvironmentObject to pretty much all views. This means that if this object publishes a change, pretty much the
/// entire app needs to be reloaded, so it should not contain any data that changes often.
///
class TowerEnvironment: ObservableObject {

    // MARK: - Static properties

    /// Preview TowerEnvironment
    ///
    /// This is a singleton used to mock a TowerEnvironment in previews.
    ///
    static let preview: TowerEnvironment = TowerEnvironment()

    // MARK: - Properties

    /// The current error, if any.
    ///
    /// This contains the current Error, along with its guidance String, if any Error has occurred. The error will
    /// completely take over the app and will be cleared, once the user acknowledges the messages, so there can ever be
    /// at most one error that is current.
    ///
    @Published var errorWrapper: ErrorWrapper?

}
