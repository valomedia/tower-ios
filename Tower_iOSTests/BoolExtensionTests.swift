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
