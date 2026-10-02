//
//  Date+startOfToday.swift
//  tower-ios
//
//  Copyright (c) 2025 valo.media GmbH. All rights reserved.
//

import Foundation

// MARK: Date

extension Date {

    // MARK: + startOfToday

    /// The first moment of the current Date.
    ///
    /// This will return the first moment of today using the current Calendar (and time zone).
    ///
    static var startOfToday: Date {
        Calendar.current.startOfDay(for: Date())
    }

}
