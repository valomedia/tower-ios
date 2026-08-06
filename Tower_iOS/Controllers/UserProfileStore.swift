//
//  UserProfileStore.swift
//  tower-ios
//
//  Copyright (c) 2026 valo.media GmbH. All rights reserved.
//

import Foundation

// MARK: UserProfileStore

/// Loads and updates the current user's profile, including migration from legacy local preferences.
///
struct UserProfileStore {

    // MARK: - Life cycle methods

    init(defaults: UserDefaults = .standard) {
        self.init(
            defaults: defaults,
            getRemoteProfile: TowerApi.getUserProfile,
            updateRemoteProfile: TowerApi.updateUserProfile)
    }

    init(
        defaults: UserDefaults,
        getRemoteProfile: @escaping (UUID) async throws -> UserProfile,
        updateRemoteProfile: @escaping (UserProfile, UUID) async throws -> Void
    ) {
        self.defaults = defaults
        self.getRemoteProfile = getRemoteProfile
        self.updateRemoteProfile = updateRemoteProfile
    }

    // MARK: - Properties

    private let defaults: UserDefaults
    private let getRemoteProfile: (UUID) async throws -> UserProfile
    private let updateRemoteProfile: (UserProfile, UUID) async throws -> Void

    // MARK: - Methods

    /// Load the server profile, migrating profile defaults left by older app versions when necessary.
    ///
    /// The server is the migration marker and source of truth: legacy values only populate an empty server profile.
    /// Legacy values remain available for another attempt if the migration fails.
    ///
    func loadProfile(userId: UUID) async throws -> UserProfile {
        let serverProfile = try await getRemoteProfile(userId)
        guard serverProfile.isEmpty else {
            removeLegacyProfile()
            return serverProfile
        }
        guard let legacyProfile else {
            removeLegacyProfile()
            return serverProfile
        }

        try await updateRemoteProfile(legacyProfile, userId)
        removeLegacyProfile()
        return legacyProfile
    }

    /// Replace the current user's complete profile on the backend.
    ///
    func updateProfile(_ profile: UserProfile, userId: UUID) async throws {
        try await updateRemoteProfile(profile, userId)
    }

    private var legacyProfile: UserProfile? {
        guard LegacyPreferenceKey.allCases.contains(where: hasValue(for:)) else { return nil }

        let email = value(for: .email)
        return UserProfile(
            firstName: value(for: .firstName),
            lastName: value(for: .lastName),
            gender: value(for: .gender).flatMap(Gender.init(rawValue:)),
            birthdate: UserProfile.apiBirthdate(fromPreference: value(for: .birthdate) ?? ""),
            phone: value(for: .phone),
            email: email.map(UserProfile.isValidEmail) == true ? email : nil)
    }

    private func hasValue(for key: LegacyPreferenceKey) -> Bool {
        defaults.object(forKey: key.rawValue) != nil
    }

    private func value(for key: LegacyPreferenceKey) -> String? {
        defaults.string(forKey: key.rawValue)
    }

    private func removeLegacyProfile() {
        LegacyPreferenceKey.allCases.forEach { defaults.removeObject(forKey: $0.rawValue) }
    }

    // MARK: - Types

    private enum LegacyPreferenceKey: String, CaseIterable {
        case firstName = "first_name_preference"
        case lastName = "last_name_preference"
        case gender = "gender_preference"
        case birthdate = "birthdate_preference"
        case phone = "phone_preference"
        case email = "email_preference"
    }

}
