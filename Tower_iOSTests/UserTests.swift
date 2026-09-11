//
//  UserTests.swift
//  Tower_iOSTests
//
//  Copyright (c) 2026 valo.media GmbH. All rights reserved.
//

import XCTest

@testable import Tower_iOS

final class UserTests: XCTestCase {

    func testUserDecodesTowerApiFields() throws {
        let json = """
            {"username":"tower-user","communicationUserId":"8:acs:123",\
            "firstName":"Anna","email":"anna@example.com"}
            """
        let data = Data(json.utf8)

        let user = try JSONDecoder.shared.decode(User.self, from: data)

        XCTAssertEqual(user.username, "tower-user")
        XCTAssertEqual(user.communicationUserId, "8:acs:123")
        XCTAssertEqual(user.profile.firstName, "Anna")
        XCTAssertEqual(user.profile.email, "anna@example.com")
    }

    func testInvalidServerGenderDoesNotPreventProfileDecoding() throws {
        let json = """
            {"username":"tower-user","communicationUserId":"8:acs:123","gender":"invalid"}
            """
        let data = Data(json.utf8)

        let user = try JSONDecoder.shared.decode(User.self, from: data)

        XCTAssertNil(user.profile.gender)
    }

    func testUserEncodesProfileFieldsAtTopLevel() throws {
        let json = """
            {"username":"tower-user","communicationUserId":"8:acs:123",\
            "firstName":"Anna","email":"anna@example.com"}
            """
        let user = try JSONDecoder.shared.decode(User.self, from: Data(json.utf8))

        let data = try JSONEncoder.shared.encode(user)
        let encodedUser = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: String])

        XCTAssertEqual(encodedUser["username"], "tower-user")
        XCTAssertEqual(encodedUser["communicationUserId"], "8:acs:123")
        XCTAssertEqual(encodedUser["firstName"], "Anna")
        XCTAssertEqual(encodedUser["email"], "anna@example.com")
    }

}
