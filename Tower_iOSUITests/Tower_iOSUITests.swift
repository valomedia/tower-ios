//
//  Tower_iOSUITests.swift
//  Tower_iOSUITests
//
//
//

import Foundation
import XCTest


// MARK: Tower_iOSUITests

/// General UI tests for Tower_iOS.
///
final class Tower_iOSUITests: XCTestCase {

    // MARK: - Life cycle methods

    /// Setup code.
    ///
    /// This method is called before the invocation of each test method in the class.
    ///
    /// - Throws:
    ///
    override func setUpWithError() throws {
        // Stop immediately when a failure occurs.
        continueAfterFailure = false
    }

    /// Teardown code.
    ///
    /// This method is called after the invocation of each test method in the class.
    ///
    /// - Throws:
    ///
    override func tearDownWithError() throws {}

    // MARK: - Tests

    /// Measure how long it takes to launch the application.
    ///
    /// - Throws:
    ///
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

}
