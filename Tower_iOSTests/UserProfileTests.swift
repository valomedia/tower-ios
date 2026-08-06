//
//  UserProfileTests.swift
//  Tower_iOSTests
//
//  Copyright (c) 2026 valo.media GmbH. All rights reserved.
//

import XCTest

@testable import Tower_iOS

final class UserProfileTests: XCTestCase {

    func testEmailValidationMatchesBackendRules() {
        XCTAssertTrue(UserProfile.isValidEmail("anna@example.com"))
        XCTAssertFalse(UserProfile.isValidEmail("  anna@example.com  "))
        XCTAssertFalse(UserProfile.isValidEmail("anna@example"))
        XCTAssertFalse(UserProfile.isValidEmail("anna example.com"))
    }

    func testProfileCompletenessRequiresNameAndValidEmail() {
        XCTAssertFalse(UserProfile().isComplete)
        XCTAssertFalse(UserProfile(firstName: "Anna", email: "invalid").isComplete)
        XCTAssertFalse(UserProfile(firstName: " ", email: "anna@example.com").isComplete)
        XCTAssertTrue(UserProfile(firstName: "Anna", email: "anna@example.com").isComplete)
    }

}
