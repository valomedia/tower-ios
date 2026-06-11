//
//  Tower_iOSTests.swift
//  Tower_iOSTests
//
//  Created by Jean-Pierre Höhmann on 2023-03-06.
//
//

import Foundation
import XCTest

@testable import Tower_iOS


// MARK: Tower_iOSTests

/// Unit tests for Tower_iOS.
///
final class Tower_iOSTests: XCTestCase {

    // MARK: - Life cycle methods

    /// Setup code.
    ///
    /// This method is called before the invocation of each test method in the class.
    ///
    /// - Throws:
    ///
    override func setUpWithError() throws {}

    /// Teardown code.
    ///
    /// This method is called after the invocation of each test method in the class.
    ///
    /// - Throws:
    ///
    override func tearDownWithError() throws {}

    // MARK: - Tests

    /// Bool.then returns the value only for true conditions.
    ///
    func testThenReturnsValueForTrueAndNilForFalse() {
        XCTAssertEqual(true.then("shown"), "shown")
        XCTAssertNil(false.then("hidden"))

        let optionalValue: String? = "optional"
        XCTAssertEqual(true.then(optionalValue), "optional")
        XCTAssertNil(false.then(optionalValue))
    }

    /// Bool.else returns the value only for false conditions.
    ///
    func testElseReturnsValueForFalseAndNilForTrue() {
        XCTAssertEqual(false.else("fallback"), "fallback")
        XCTAssertNil(true.else("ignored"))

        let optionalValue: String? = "optional"
        XCTAssertEqual(false.else(optionalValue), "optional")
        XCTAssertNil(true.else(optionalValue))
    }

    /// The compacted sequence helper removes nil values without reordering the sequence.
    ///
    func testCompactedRemovesNilValuesAndPreservesOrder() {
        let values: [Int?] = [1, nil, 2, nil, 3]

        XCTAssertEqual(values.compacted(), [1, 2, 3])
    }

    /// The shared JSON encoder keeps URLs readable for Tower API payloads.
    ///
    /// - Throws:
    ///
    func testSharedJSONEncoderDoesNotEscapeSlashes() throws {
        struct Payload: Encodable {
            let url: String
        }

        let data = try JSONEncoder.shared.encode(Payload(url: "https://example.com/tower/path"))
        let json = try XCTUnwrap(String(data: data, encoding: .utf8))

        XCTAssertTrue(json.contains("https://example.com/tower/path"))
        XCTAssertFalse(json.contains(#"\/"#))
    }

    /// User payloads decode API field names used by the Tower backend.
    ///
    /// - Throws:
    ///
    func testUserDecodesTowerApiFields() throws {
        let data = #"{"username":"tower-user","communicationUserId":"8:acs:123"}"#.data(using: .utf8)!

        let user = try JSONDecoder.shared.decode(User.self, from: data)

        XCTAssertEqual(user.username, "tower-user")
        XCTAssertEqual(user.communicationUserId, "8:acs:123")
    }

    /// Regex helpers report matches consistently through the method and operator APIs.
    ///
    /// - Throws:
    ///
    func testRegexMatchesMethodAndOperator() throws {
        let regex = try Regex("^tower-[0-9]+$")

        XCTAssertTrue(try regex.matches("tower-42"))
        XCTAssertTrue(try "tower-42" =~ regex)
        XCTAssertFalse(try regex.matches("tower"))
        XCTAssertFalse(try "help-42" =~ regex)
    }

}
