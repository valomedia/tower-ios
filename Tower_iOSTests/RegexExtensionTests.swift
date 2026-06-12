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
