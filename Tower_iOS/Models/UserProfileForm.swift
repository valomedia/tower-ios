//
//  UserProfileForm.swift
//  tower-ios
//
//  Copyright (c) 2026 valo.media GmbH. All rights reserved.
//

import Foundation

// MARK: UserProfileForm

/// Editable form values for a `UserProfile`.
///
struct UserProfileForm {

    // MARK: - Life cycle methods

    init(_ profile: UserProfile = UserProfile()) {
        firstName = profile.firstName ?? ""
        lastName = profile.lastName ?? ""
        gender = profile.gender?.rawValue ?? ""
        birthdate = UserProfile.preferenceBirthdate(fromApi: profile.birthdate)
        phone = profile.phone ?? ""
        email = profile.email ?? ""
    }

    // MARK: - Properties

    /// The editable given name.
    ///
    var firstName: String

    /// The editable family name.
    ///
    var lastName: String

    /// The raw value for the selected gender.
    ///
    var gender: String

    /// The editable birthdate formatted as DD.MM.YYYY.
    ///
    var birthdate: String

    /// The editable phone number.
    ///
    var phone: String

    /// The editable e-mail address.
    ///
    var email: String

    /// The normalized profile represented by the current form values.
    ///
    var profile: UserProfile {
        UserProfile(
            firstName: trimmedFirstName,
            lastName: lastName,
            gender: Gender(rawValue: gender),
            birthdate: UserProfile.apiBirthdate(fromPreference: birthdate),
            phone: phone,
            email: trimmedEmail)
    }

    /// The first name without surrounding whitespace.
    ///
    var trimmedFirstName: String {
        firstName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// The e-mail address without surrounding whitespace.
    ///
    var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Whether the e-mail address has valid syntax.
    ///
    var isEmailValid: Bool {
        UserProfile.isValidEmail(trimmedEmail)
    }

    /// Whether a non-empty e-mail address has invalid syntax.
    ///
    var hasInvalidEmail: Bool {
        !trimmedEmail.isEmpty && !isEmailValid
    }

    /// Whether the optional birthdate is empty or uses the expected format.
    ///
    var isBirthdateValid: Bool {
        let value = birthdate.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty || UserProfile.date(fromPreference: value) != nil
    }

    /// Whether all form values can be saved.
    ///
    var isValid: Bool {
        !trimmedFirstName.isEmpty && isEmailValid && isBirthdateValid
    }

}
