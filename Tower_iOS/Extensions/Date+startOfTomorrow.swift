//
//  Date+startOfTomorrow.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2025-02-18.
//  Copyright (c) 2025 valo.media GmbH. All rights reserved.
//

import Foundation

// MARK: Date

extension Date {

    // MARK: + startOfTomorrow

    /// The first moment of tomorrows date.
    ///
    /// This will return the first moment of tomorrow using the current Calendar (and time zone).
    ///
    static var startOfTomorrow: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: Date.startOfToday)!
    }

}
