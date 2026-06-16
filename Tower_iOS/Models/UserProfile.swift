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

    init(
        firstName: String?,
        lastName: String?,
        gender: Gender?,
        birthdate: String?,
        phone: String?,
        email: String?
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.gender = gender
        self.birthdate = birthdate
        self.phone = phone
        self.email = email
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        gender = try? container.decodeIfPresent(Gender.self, forKey: .gender)
        birthdate = try container.decodeIfPresent(String.self, forKey: .birthdate)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        email = try container.decodeIfPresent(String.self, forKey: .email)
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

    /// Build a profile from the locally cached Settings values.
    ///
    static func fromSettings() -> UserProfile {
        var profile = UserProfile(
            firstName: (Settings.firstNamePreference != "") .!! Settings.firstNamePreference,
            lastName: (Settings.lastNamePreference != "") .!! Settings.lastNamePreference,
            gender: Gender(rawValue: Settings.genderPreference),
            birthdate: apiBirthdate(fromPreference: Settings.birthdatePreference),
            phone: (Settings.phonePreference != "") .!! Settings.phonePreference,
            email: (Settings.emailPreference != "") .!! Settings.emailPreference
        )

        if profile.birthdate == nil && !Settings.birthdatePreference.isEmpty {
            Settings.birthdatePreference = ""
        }

        return profile
    }

    /// True when the profile does not contain any user-supplied data.
    ///
    var isEmpty: Bool {
        Self.normalized(firstName) == nil
            && Self.normalized(lastName) == nil
            && gender == nil
            && Self.normalized(birthdate) == nil
            && Self.normalized(phone) == nil
            && Self.normalized(email) == nil
    }

    static func fromFormFields(
        firstName: String,
        lastName: String,
        gender: String,
        birthdate: String,
        phone: String,
        email: String
    ) -> UserProfile {
        UserProfile(
            firstName: firstName.isEmpty ? nil : firstName,
            lastName: lastName.isEmpty ? nil : lastName,
            gender: Gender(rawValue: gender),
            birthdate: apiBirthdate(fromPreference: birthdate),
            phone: phone.isEmpty ? nil : phone,
            email: email.isEmpty ? nil : email
        )
    }

    /// Validate an e-mail address using the same rule as the backend.
    ///
    static func isValidEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        return trimmed.range(of: #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#, options: .regularExpression) != nil
    }

    static func date(fromPreference value: String) -> Date? {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.isEmpty else { return nil }
        return preferenceBirthdateFormatter.date(from: trimmedValue)
    }

    static func apiBirthdate(fromPreference value: String) -> String? {
        guard let date = date(fromPreference: value) else { return nil }
        return apiBirthdateFormatter.string(from: date)
    }

    static func preferenceBirthdate(fromApi value: String?) -> String? {
        guard let value, !value.isEmpty else { return nil }
        guard let date = apiBirthdateFormatter.date(from: value) else { return nil }
        return preferenceBirthdateFormatter.string(from: date)
    }

    /// Write this profile's data to the local Settings cache.
    ///
    func writeToSettings() {
        Settings.firstNamePreference = firstName ?? ""
        Settings.lastNamePreference = lastName ?? ""
        Settings.genderPreference = gender?.rawValue ?? ""
        Settings.birthdatePreference = Self.preferenceBirthdate(fromApi: birthdate) ?? ""
        Settings.phonePreference = phone ?? ""
        Settings.emailPreference = email ?? ""
    }

    private static func normalized(_ value: String?) -> String? {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else { return nil }
        return value
    }

}
