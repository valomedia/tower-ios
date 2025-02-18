//
//  Date+day.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2025-02-18.
//  Copyright (c) 2025 valo.media GmbH. All rights reserved.
//

import Foundation

// MARK: Date

extension Date {

    // MARK: + day

    /// Get the date without its time component.
    ///
    var day: Date {
        Calendar.current.startOfDay(for: self)
    }

}
