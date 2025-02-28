//
//  Date+today.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2025-02-18.
//  Copyright (c) 2025 valo.media GmbH. All rights reserved.
//

import Foundation

// MARK: Date

extension Date {

    // MARK: + today

    /// The first moment of the current Date.
    ///
    /// This will return the first moment of today using the current Calendar (and time zone).
    ///
    static var today: Date {
        .startOfToday
    }

}
