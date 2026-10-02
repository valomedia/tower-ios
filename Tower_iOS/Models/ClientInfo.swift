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

import Foundation

// MARK: ClientInfo

/// Information about the client making the call, that is relevant to the assistance session.
///
/// For now this just contains the bundle identifier and version of the app.
///
struct ClientInfo: Codable {

    enum CodingKeys: String, CodingKey {
        case identifier = "identifier"
        case version = "version"
    }

    // MARK: - Life cycle methods

    init() {
        identifier = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as! String
        version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

    // MARK: - Properties

    /// The bundle identifier of the app.
    ///
    var identifier: String

    /// The version number of the app.
    ///
    var version: String

}
