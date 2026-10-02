//
// Copyright (c) 2025-2026 valo.media GmbH
// All rights reserved.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
