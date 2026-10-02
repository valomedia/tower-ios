//
// Copyright (c) 2024-2026 valo.media GmbH
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

// MARK: RequestAssistanceResponse

/// The data returned by the `/requestAssistance`-endpoint.
///
struct RequestAssistanceResponse: Codable {

    enum CodingKeys: String, CodingKey {
        case userToken = "userToken"
        case keepaliveInterval = "keepaliveInterval"
    }

    // MARK: - Properties

    /// The access token for the upcoming assistance session.
    ///
    var userToken: UserToken

    /// How often to send a request to the `/awaitAssistance`-endpoint.
    ///
    var keepaliveInterval: Int?

}
