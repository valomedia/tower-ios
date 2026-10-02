//
//  Gender.swift
//  tower-ios
//
//  Copyright (c) 2025 valo.media GmbH. All rights reserved.
//

import Foundation

// MARK: Gender

/// An enum representing the gender of a person as either male, female, or other.
///
enum Gender: String, Codable, CustomStringConvertible {
    case male = "M"
    case female = "F"
    case other = "X"

    // MARK: - Properties

    /// Human-readable names for the genders.
    ///
    var description: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        case .other: return "Other"
        }
    }

    /// Localized version of the human-readable names for each gender.
    ///
    var localizedDescription: String {
        switch self {
        case .male: return "Männlich"
        case .female: return "Weiblich"
        case .other: return "Divers"
        }
    }

}
