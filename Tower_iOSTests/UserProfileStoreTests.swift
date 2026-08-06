//
//  UserProfileStoreTests.swift
//  Tower_iOSTests
//
//  Copyright (c) 2026 valo.media GmbH. All rights reserved.
//

import XCTest

@testable import Tower_iOS

final class UserProfileStoreTests: XCTestCase {

    func testEmptyServerProfileMigratesNormalizedLegacyValues() async throws {
        let userId = UUID()
        let defaults = try makeDefaults()
        defaults.set("  Anna  ", forKey: "first_name_preference")
        defaults.set("not-an-email", forKey: "email_preference")
        defaults.set("31.02.2020", forKey: "birthdate_preference")
        defaults.set("invalid", forKey: "gender_preference")
        defaults.set("keep", forKey: "unrelated")

        let migratedProfile = UserProfile(firstName: "Anna")
        var requestedUserIds: [UUID] = []
        var updatedProfiles: [UserProfile] = []
        var updatedUserIds: [UUID] = []
        let store = UserProfileStore(
            defaults: defaults,
            getRemoteProfile: { requestedUserId in
                requestedUserIds.append(requestedUserId)
                return UserProfile()
            },
            updateRemoteProfile: { profile, updatedUserId in
                updatedProfiles.append(profile)
                updatedUserIds.append(updatedUserId)
            })

        let profile = try await store.loadProfile(userId: userId)

        XCTAssertEqual(profile, migratedProfile)
        XCTAssertEqual(requestedUserIds, [userId])
        XCTAssertEqual(requestedUserIds.count, 1, "Migration must not read after updating the server profile")
        XCTAssertEqual(updatedProfiles, [migratedProfile])
        XCTAssertEqual(updatedUserIds, [userId])
        XCTAssertNil(defaults.object(forKey: "first_name_preference"))
        XCTAssertNil(defaults.object(forKey: "email_preference"))
        XCTAssertEqual(defaults.string(forKey: "unrelated"), "keep")
    }

    func testExistingServerProfileDiscardsLegacyValuesWithoutUpdating() async throws {
        let userId = UUID()
        let defaults = try makeDefaults()
        defaults.set("Legacy", forKey: "first_name_preference")
        let serverProfile = UserProfile(firstName: "Anna", email: "anna@example.com")
        var updatedProfiles: [UserProfile] = []
        let store = UserProfileStore(
            defaults: defaults,
            getRemoteProfile: { requestedUserId in
                XCTAssertEqual(requestedUserId, userId)
                return serverProfile
            },
            updateRemoteProfile: { profile, _ in updatedProfiles.append(profile) })

        let profile = try await store.loadProfile(userId: userId)

        XCTAssertEqual(profile, serverProfile)
        XCTAssertTrue(updatedProfiles.isEmpty)
        XCTAssertNil(defaults.object(forKey: "first_name_preference"))
    }

    func testFailedMigrationKeepsLegacyValuesForAnotherAttempt() async throws {
        let userId = UUID()
        let defaults = try makeDefaults()
        defaults.set("Anna", forKey: "first_name_preference")
        let store = UserProfileStore(
            defaults: defaults,
            getRemoteProfile: { requestedUserId in
                XCTAssertEqual(requestedUserId, userId)
                return UserProfile()
            },
            updateRemoteProfile: { _, updatedUserId in
                XCTAssertEqual(updatedUserId, userId)
                throw SampleError.updateFailed
            })

        do {
            _ = try await store.loadProfile(userId: userId)
            XCTFail("Expected migration to fail")
        } catch SampleError.updateFailed {
            XCTAssertEqual(defaults.string(forKey: "first_name_preference"), "Anna")
        }
    }

    // MARK: - Methods

    private func makeDefaults() throws -> UserDefaults {
        let suiteName = "UserProfileStoreTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        addTeardownBlock { defaults.removePersistentDomain(forName: suiteName) }
        return defaults
    }

    // MARK: - Types

    private enum SampleError: Error {
        case updateFailed
    }

}
