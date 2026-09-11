//
//  UpdateUserRequestTests.swift
//  Tower_iOSTests
//
//  Copyright (c) 2026 valo.media GmbH. All rights reserved.
//

import XCTest

@testable import Tower_iOS

final class UpdateUserRequestTests: XCTestCase {

    func testRequestEncodesProfileFieldsAtTopLevel() throws {
        let profile = UserProfile(
            firstName: "Anna",
            lastName: "Beispiel",
            gender: .female,
            birthdate: "2000-12-31",
            phone: "01234",
            email: "anna@example.com")
        let request = UpdateUserRequest(userId: "user-id", profile: profile)

        let data = try JSONEncoder.shared.encode(request)
        let payload = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: String])

        XCTAssertEqual(payload["userId"], "user-id")
        XCTAssertEqual(payload["firstName"], profile.firstName)
        XCTAssertEqual(payload["lastName"], profile.lastName)
        XCTAssertEqual(payload["gender"], profile.gender?.rawValue)
        XCTAssertEqual(payload["birthdate"], profile.birthdate)
        XCTAssertEqual(payload["phone"], profile.phone)
        XCTAssertEqual(payload["email"], profile.email)
    }

}
