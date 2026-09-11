//
//  TowerEnvironmentTests.swift
//  Tower_iOSTests
//
//  Copyright (c) 2026 valo.media GmbH. All rights reserved.
//

import XCTest

@testable import Tower_iOS

final class TowerEnvironmentTests: XCTestCase {

    @MainActor
    func testProfileCannotBeUpdatedBeforeItHasLoaded() async throws {
        let defaults = try makeDefaults()
        let store = UserProfileStore(
            defaults: defaults,
            getRemoteProfile: { _ in UserProfile() },
            updateRemoteProfile: { _, _ in XCTFail("Unexpected profile update") })
        let environment = TowerEnvironment(userProfileStore: store)

        XCTAssertNil(environment.userProfile)
        XCTAssertFalse(environment.isUserProfileLoaded)

        do {
            try await environment.updateUserProfile(UserProfile(firstName: "Anna"))
            XCTFail("Expected update to fail before loading")
        } catch let error as TowerEnvironment.UserProfileError {
            XCTAssertEqual(error, .profileNotLoaded)
        }
    }

    @MainActor
    func testLoadedEmptyProfileUsesUserIdAndPublishesUpdate() async throws {
        let userId = UUID()
        let loadedProfile = UserProfile()
        let updatedProfile = UserProfile(firstName: "Anne", email: "anne@example.com")
        let defaults = try makeDefaults()
        var updatedUserIds: [UUID] = []
        let store = UserProfileStore(
            defaults: defaults,
            getRemoteProfile: { requestedUserId in
                XCTAssertEqual(requestedUserId, userId)
                return loadedProfile
            },
            updateRemoteProfile: { profile, updatedUserId in
                XCTAssertEqual(profile, updatedProfile)
                updatedUserIds.append(updatedUserId)
            })
        let environment = TowerEnvironment(userProfileStore: store)

        try await environment.loadUserProfile(userId: userId)
        XCTAssertEqual(environment.userProfile, loadedProfile)
        XCTAssertTrue(environment.isUserProfileLoaded)

        try await environment.updateUserProfile(updatedProfile)

        XCTAssertEqual(updatedUserIds, [userId])
        XCTAssertEqual(environment.userProfile, updatedProfile)
    }

    @MainActor
    func testReloadIsSkippedWhileUpdateIsInProgress() async throws {
        let userId = UUID()
        let reloadedUserId = UUID()
        let loadedProfile = UserProfile(firstName: "Anna", email: "anna@example.com")
        let updatedProfile = UserProfile(firstName: "Anne", email: "anne@example.com")
        let defaults = try makeDefaults()
        let updateGate = UpdateGate()
        var requestedUserIds: [UUID] = []
        let store = UserProfileStore(
            defaults: defaults,
            getRemoteProfile: { requestedUserId in
                requestedUserIds.append(requestedUserId)
                return loadedProfile
            },
            updateRemoteProfile: { _, _ in await updateGate.suspend() })
        let environment = TowerEnvironment(userProfileStore: store)

        try await environment.loadUserProfile(userId: userId)

        let updateTask = Task {
            try await environment.updateUserProfile(updatedProfile)
        }
        await updateGate.waitUntilSuspended()
        XCTAssertTrue(environment.isProfileOperationInProgress)

        try await environment.loadUserProfile(userId: reloadedUserId)

        XCTAssertEqual(requestedUserIds, [userId])
        await updateGate.resume()
        try await updateTask.value
        XCTAssertFalse(environment.isProfileOperationInProgress)
        XCTAssertEqual(environment.userProfile, updatedProfile)
    }

    // MARK: - Methods

    private func makeDefaults() throws -> UserDefaults {
        let suiteName = "TowerEnvironmentTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        addTeardownBlock { defaults.removePersistentDomain(forName: suiteName) }
        return defaults
    }

    private actor UpdateGate {
        private var continuation: CheckedContinuation<Void, Never>?
        private var isSuspended = false

        func suspend() async {
            isSuspended = true
            await withCheckedContinuation { continuation = $0 }
        }

        func waitUntilSuspended() async {
            while !isSuspended {
                await Task.yield()
            }
        }

        func resume() {
            continuation?.resume()
            continuation = nil
        }
    }

}
