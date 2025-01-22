//
//  UserProfile.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2025-01-22.
//  Copyright (c) 2025 valo.media GmbH. All rights reserved.
//

import Foundation

// MARK: UserProfile

/// Information provided by the user about themselves.
///
struct UserProfile: Codable {

    enum CodingKeys: String, CodingKey {
        case firstName = "firstName"
        case lastName = "lastName"
        case gender = "gender"
        case birthdate = "birthdate"
        case phone = "phone"
        case email = "email"
    }

    // MARK: - Life cycle methods

    init() {
        firstName = (Settings.firstNamePreference != "") .!! Settings.firstNamePreference
        lastName = (Settings.lastNamePreference != "") .!! Settings.lastNamePreference
        gender = Gender.init(rawValue: Settings.genderPreference)
        birthdate = try? (Settings.birthdatePreference =~ /^\d\d\.\d\d\.\d{4}$/)
            .!! Settings.birthdatePreference.split(separator: ".").reversed().joined(separator: "-")
        phone = (Settings.phonePreference != "") .!! Settings.phonePreference
        email = (Settings.emailPreference != "") .!! Settings.emailPreference

        // If the birthdate is not valid, unset it.
        if birthdate == nil { Settings.birthdatePreference = "" }
    }

    // MARK: - Properties

    /// The given name of the user, if known.
    ///
    var firstName: String?

    /// The family name of the user, if known.
    ///
    var lastName: String?

    /// The gender of the user, if known.
    ///
    var gender: Gender?

    /// The birthdate of the user formatted as YYYY-MM-DD, if known.
    ///
    var birthdate: String?

    /// The preferred phone number for calling the user, if known.
    ///
    var phone: String?

    /// The preferred e-mail address for contacting the user, if known.
    ///
    var email: String?

}
