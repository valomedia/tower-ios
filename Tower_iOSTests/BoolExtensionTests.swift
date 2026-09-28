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

final class BoolExtensionTests: XCTestCase {

    func testThenReturnsValueForTrueAndNilForFalse() {
        XCTAssertEqual(true.then("shown"), "shown")
        XCTAssertNil(false.then("hidden"))

        let optionalValue: String? = "optional"
        XCTAssertEqual(true.then(optionalValue), "optional")
        XCTAssertNil(false.then(optionalValue))
    }

    func testElseReturnsValueForFalseAndNilForTrue() {
        XCTAssertEqual(false.else("fallback"), "fallback")
        XCTAssertNil(true.else("ignored"))

        let optionalValue: String? = "optional"
        XCTAssertEqual(false.else(optionalValue), "optional")
        XCTAssertNil(true.else(optionalValue))
    }

}
