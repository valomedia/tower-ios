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

    private static let preferenceBirthdateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.isLenient = false
        formatter.locale = Locale(identifier: "de_DE")
        return formatter
    }()

    private static let apiBirthdateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

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
        birthdate = Self.apiBirthdate(fromPreference: Settings.birthdatePreference)
        phone = (Settings.phonePreference != "") .!! Settings.phonePreference
        email = (Settings.emailPreference != "") .!! Settings.emailPreference

        // If the birthdate is not valid, unset it.
        if birthdate == nil && !Settings.birthdatePreference.isEmpty {
            Settings.birthdatePreference = ""
        }
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

    // MARK: - Methods

    static func date(fromPreference value: String) -> Date? {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.isEmpty else { return nil }
        return preferenceBirthdateFormatter.date(from: trimmedValue)
    }

    static func preferenceBirthdate(from date: Date) -> String {
        preferenceBirthdateFormatter.string(from: date)
    }

    static func apiBirthdate(fromPreference value: String) -> String? {
        guard let date = date(fromPreference: value) else { return nil }
        return apiBirthdateFormatter.string(from: date)
    }

}
