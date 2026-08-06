//
//  TowerEnvironment.swift
//  Tower_iOS
//
//
//

import Foundation


// MARK: TowerEnvironment

/// Main environment object.
///
/// This class is a view controller that represents all data that is needed across most views. It is added as an
/// EnvironmentObject to pretty much all views. This means that if this object publishes a change, pretty much the
/// entire app needs to be reloaded, so it should not contain any data that changes often.
///
class TowerEnvironment: ObservableObject {

    // MARK: - Static properties

    /// Preview TowerEnvironment
    ///
    /// This is a singleton used to mock a TowerEnvironment in previews.
    ///
    static let preview: TowerEnvironment = {
        let environment = TowerEnvironment()
        environment.userProfile = UserProfile()
        environment.loadedUserId = UUID()
        return environment
    }()

    // MARK: - Life cycle methods

    init(userProfileStore: UserProfileStore = UserProfileStore()) {
        self.userProfileStore = userProfileStore
    }

    // MARK: - Properties

    /// The current error, if any.
    ///
    /// This contains the current Error, along with its guidance String, if any Error has occurred. The error will
    /// completely take over the app and will be cleared, once the user acknowledges the messages, so there can ever be
    /// at most one error that is current.
    ///
    @Published var errorWrapper: ErrorWrapper?

    /// The current user's server-backed profile, once loaded.
    ///
    /// This is deliberately not persisted locally. The backend remains the sole source of truth.
    ///
    @Published private(set) var userProfile: UserProfile?

    /// Whether a profile, including an empty profile, has been loaded from the backend.
    ///
    var isUserProfileLoaded: Bool {
        userProfile != nil
    }

    /// Whether a profile load or update is currently in progress.
    ///
    @Published private(set) var isProfileOperationInProgress = false

    private let userProfileStore: UserProfileStore
    private var loadedUserId: UUID?

    // MARK: - Methods

    /// Load the current user's profile and publish it for views in the current app session.
    ///
    @MainActor
    func loadUserProfile(userId: UUID) async throws {
        guard !isProfileOperationInProgress else { return }

        isProfileOperationInProgress = true
        loadedUserId = nil
        userProfile = nil
        defer { isProfileOperationInProgress = false }

        let profile = try await userProfileStore.loadProfile(userId: userId)
        loadedUserId = userId
        userProfile = profile
    }

    /// Save a complete profile and publish it for views in the current app session.
    ///
    @MainActor
    func updateUserProfile(_ profile: UserProfile) async throws {
        guard !isProfileOperationInProgress,
              userProfile != nil,
              let userId = loadedUserId
        else {
            throw UserProfileError.profileNotLoaded
        }

        isProfileOperationInProgress = true
        defer { isProfileOperationInProgress = false }

        try await userProfileStore.updateProfile(profile, userId: userId)
        userProfile = profile
    }

    // MARK: - Types

    enum UserProfileError: Equatable, LocalizedError {
        case profileNotLoaded

        var errorDescription: String? {
            "Das Benutzerprofil wurde noch nicht geladen."
        }
    }

}
