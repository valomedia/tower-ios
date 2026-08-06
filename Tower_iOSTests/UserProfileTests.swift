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

    func testProfileWithServerInvalidEmailRequiresCorrection() throws {
        let data = Data(#"{"firstName":"Anna","email":" anna@example.com "}"#.utf8)

        let profile = try JSONDecoder.shared.decode(UserProfile.self, from: data)

        XCTAssertEqual(profile.email, " anna@example.com ")
        XCTAssertFalse(profile.isComplete)
        XCTAssertEqual(UserProfileForm(profile).trimmedEmail, "anna@example.com")
    }

    func testFormConvertsBetweenDisplayAndApiValues() {
        let profile = UserProfile(
            firstName: "Anna",
            lastName: "Beispiel",
            gender: .female,
            birthdate: "2000-12-31",
            phone: "01234",
            email: "anna@example.com")

        var form = UserProfileForm(profile)
        form.firstName = "  Anne  "
        form.email = "  anne@example.com  "

        XCTAssertEqual(form.birthdate, "31.12.2000")
        XCTAssertEqual(form.profile.firstName, "Anne")
        XCTAssertEqual(form.profile.lastName, profile.lastName)
        XCTAssertEqual(form.profile.gender, profile.gender)
        XCTAssertEqual(form.profile.birthdate, profile.birthdate)
        XCTAssertEqual(form.profile.phone, profile.phone)
        XCTAssertEqual(form.profile.email, "anne@example.com")
    }

    func testFormValidityIncludesRequiredFieldsAndBirthdate() {
        var form = UserProfileForm()
        XCTAssertFalse(form.isValid)

        form.firstName = "Anna"
        form.email = "anna@example.com"
        XCTAssertTrue(form.isValid)

        form.birthdate = "31.02.2020"
        XCTAssertFalse(form.isValid)
    }

}
