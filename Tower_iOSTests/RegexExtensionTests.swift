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

final class RegexExtensionTests: XCTestCase {

    func testRegexMatchesMethodAndOperator() throws {
        let regex = try Regex("^tower-[0-9]+$")

        XCTAssertTrue(try regex.matches("tower-42"))
        XCTAssertTrue(try "tower-42" =~ regex)
        XCTAssertFalse(try regex.matches("tower"))
        XCTAssertFalse(try "help-42" =~ regex)
    }

}
