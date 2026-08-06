//
//  TowerErrorTests.swift
//  Tower_iOSTests
//
//  Copyright (c) 2026 valo.media GmbH. All rights reserved.
//

import XCTest

@testable import Tower_iOS

final class TowerErrorTests: XCTestCase {

    func testExplicitMissingUserResponsesAreDistinguishedFromGenericNotFound() {
        let codedResponse = Data(#"{"code":"USER_NOT_FOUND"}"#.utf8)
        let legacyResponse = Data(#"{"error":"User not found"}"#.utf8)

        XCTAssertEqual(TowerError.responseError(statusCode: 404, data: codedResponse), .userNotFound)
        XCTAssertEqual(TowerError.responseError(statusCode: 404, data: legacyResponse), .userNotFound)
    }

    func testGenericNotFoundDoesNotOfferAccountRecovery() {
        let unrelatedResponse = Data(#"{"message":"Assistance request not found"}"#.utf8)
        let malformedResponse = Data("not-json".utf8)

        XCTAssertEqual(TowerError.responseError(statusCode: 404, data: unrelatedResponse), .notFound)
        XCTAssertEqual(TowerError.responseError(statusCode: 404, data: malformedResponse), .notFound)
        XCTAssertEqual(TowerError.responseError(statusCode: 404), .notFound)
    }

    func testOtherResponseStatusesKeepTheirExistingMeaning() {
        XCTAssertNil(TowerError.responseError(statusCode: 204))
        XCTAssertEqual(TowerError.responseError(statusCode: 400), .badRequest)
        XCTAssertEqual(TowerError.responseError(statusCode: 401), .badCredentials)
        XCTAssertEqual(TowerError.responseError(statusCode: 500), .serverError)
        XCTAssertEqual(TowerError.responseError(statusCode: 418), .unexpectedError)
    }

}
