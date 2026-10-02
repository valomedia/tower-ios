//
//  Date+tomorrow.swift
//  tower-ios
//
//  Copyright (c) 2025 valo.media GmbH. All rights reserved.
//

import Foundation

// MARK: Date

extension Date {

    // MARK: + tomorrow

    /// The first moment of tomorrows date.
    ///
    /// This will return the first moment of tomorrow using the current Calendar (and time zone).
    ///
    static var tomorrow: Date {
        .startOfTomorrow
    }

}
