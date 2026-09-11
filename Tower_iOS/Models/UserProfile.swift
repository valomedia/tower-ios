//
//  UserProfile.swift
//  tower-ios
//
//  Copyright (c) 2025 valo.media GmbH. All rights reserved.
//

import Foundation

// MARK: UserProfile

/// Information provided by the user about themselves.
///
struct UserProfile: Codable, Equatable {

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

    private static let emailRegex = try? Regex(#"^[^\s@]+@[^\s@]+\.[^\s@]+$"#)

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
        firstName: String? = nil,
        lastName: String? = nil,
        gender: Gender? = nil,
        birthdate: String? = nil,
        phone: String? = nil,
        email: String? = nil
    ) {
        self.firstName = Self.nonEmpty(firstName)
        self.lastName = Self.nonEmpty(lastName)
        self.gender = gender
        self.birthdate = Self.nonEmpty(birthdate)
        self.phone = Self.nonEmpty(phone)
        self.email = Self.nonEmptyPreservingWhitespace(email)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let gender = try container.decodeIfPresent(String.self, forKey: .gender)
        self.init(
            firstName: try container.decodeIfPresent(String.self, forKey: .firstName),
            lastName: try container.decodeIfPresent(String.self, forKey: .lastName),
            gender: gender.flatMap(Gender.init(rawValue:)),
            birthdate: try container.decodeIfPresent(String.self, forKey: .birthdate),
            phone: try container.decodeIfPresent(String.self, forKey: .phone),
            email: try container.decodeIfPresent(String.self, forKey: .email))
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

    /// Whether the profile contains no user-provided information.
    ///
    var isEmpty: Bool {
        firstName == nil
            && lastName == nil
            && gender == nil
            && birthdate == nil
            && phone == nil
            && email == nil
    }

    /// Whether the profile has the fields required before placing a call.
    ///
    var isComplete: Bool {
        firstName != nil && email.map(Self.isValidEmail) == true
    }

    // MARK: - Methods

    static func date(fromPreference value: String) -> Date? {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.isEmpty else { return nil }
        return preferenceBirthdateFormatter.date(from: trimmedValue)
    }

    static func apiBirthdate(fromPreference value: String) -> String? {
        guard let date = date(fromPreference: value) else { return nil }
        return apiBirthdateFormatter.string(from: date)
    }

    static func preferenceBirthdate(fromApi value: String?) -> String {
        guard let value, let date = apiBirthdateFormatter.date(from: value) else { return "" }
        return preferenceBirthdateFormatter.string(from: date)
    }

    /// Uses the same deliberately loose syntax check as the backend.
    ///
    static func isValidEmail(_ value: String) -> Bool {
        guard let emailRegex else { return false }
        return (try? emailRegex.matches(value)) == true
    }

    private static func nonEmpty(_ value: String?) -> String? {
        let value = value?.trimmingCharacters(in: .whitespacesAndNewlines)
        return value?.isEmpty == false ? value : nil
    }

    private static func nonEmptyPreservingWhitespace(_ value: String?) -> String? {
        value?.isEmpty == false ? value : nil
    }

}
