//
// Copyright (c) 2026 valo.media GmbH
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

import XCTest

@testable import Tower_iOS

final class UserTests: XCTestCase {

    func testUserDecodesTowerApiFields() throws {
        let data = #"{"username":"tower-user","communicationUserId":"8:acs:123"}"#.data(using: .utf8)!

        let user = try JSONDecoder.shared.decode(User.self, from: data)

        XCTAssertEqual(user.username, "tower-user")
        XCTAssertEqual(user.communicationUserId, "8:acs:123")
    }

}
