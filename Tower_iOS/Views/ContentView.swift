//
//  ContentView.swift
//  Tower_iOS
//
//
//

import Foundation
import SwiftUI
import AVFoundation


// MARK: ContentView

struct ContentView: View {

    // MARK: - Properties

    var body: some View {
        TabView(selection: $selectedTab) {
            VStack {
                Spacer()
                Image(uiImage: Asset.Assets.logo.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .accessibility(hidden: true)
                Text(
                    UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory
                        ? "Verbinden…"
                        : "Verbindung wird hergestellt…")
                    .opacity(isConnected ? 0 : 1)
                    .accessibilityHidden(isConnected)
                Button {
                    isPresentingCallSheet = true
                } label: {
                    Label("Jetzt anrufen", systemImage: "phone.fill")
                }
                    .buttonStyle(.darkModeAwareProminent)
                    .disabled(!isConnected || !env.isUserProfileLoaded || env.isProfileOperationInProgress)
                    .accessibilityHidden(
                        !isConnected || !env.isUserProfileLoaded || env.isProfileOperationInProgress)
                    .padding()
                Spacer()
            }
                .padding()
                .tag(Tab.home)
                .tabItem {
                    Label("Start", systemImage: "house")
                }

            NavigationView {
                ProfileEditView()
            }
                .navigationViewStyle(.stack)
                .tag(Tab.profile)
                .tabItem {
                    Label("Profil", systemImage: "person.crop.circle")
                }

            NavigationView {
                ContactView()
            }
                .navigationViewStyle(.stack)
                .tag(Tab.contact)
                .tabItem {
                    Label("Kontakt", systemImage: "envelope")
                }

            NavigationView {
                WhatsNewView()
            }
                .navigationViewStyle(.stack)
                .tag(Tab.whatsNew)
                .tabItem {
                    Label("Neuigkeiten", systemImage: "sparkles")
                }
        }
            .sheet(item: $env.errorWrapper, onDismiss: login) { errorWrapper in
                ErrorView(errorWrapper: errorWrapper)
            }
            .sheet(isPresented: $isPresentingCallSheet) {
                CallSheet().interactiveDismissDisabled()
            }
            .sheet(isPresented: $isPresentingOnboardingSheet, onDismiss: login) {
                OnboardingSheet().interactiveDismissDisabled()
            }
            .sheet(isPresented: $isPresentingSignupSheet, onDismiss: login) {
                SignupSheet().interactiveDismissDisabled()
            }
            .sheet(isPresented: $isPresentingOpeningHours) {
                OpeningHoursSheet(openingHours)
            }
            .sheet(isPresented: $isPresentingUpdatePrompt, onDismiss: login) {
                UpdatePrompt().interactiveDismissDisabled()
            }
            .confirmationDialog(
                "Benutzerkonto nicht gefunden",
                isPresented: $isPresentingAccountRecovery,
                titleVisibility: .visible
            ) {
                Button("Erneut versuchen", action: login)
                Button("Neues Benutzerkonto anlegen", role: .destructive, action: createNewAccount)
                Button("Abbrechen", role: .cancel) {}
            } message: {
                Text(
                    "Der Server konnte das auf diesem Gerät gespeicherte Benutzerkonto nicht finden. " +
                        "Beim Anlegen eines neuen Kontos müssen deine Angaben erneut eingegeben werden.")
            }
            .onChange(of: phase) { phase in
                if (phase == .active && env.errorWrapper == nil) { login() }
            }
            .environmentObject(env)
    }

    @StateObject private var env = TowerEnvironment()

    @State private var isPresentingCallSheet = false

    @State private var isPresentingSignupSheet = false

    @State private var isPresentingOnboardingSheet = false

    @State private var isConnected = false

    @State private var isLoggingIn = false

    @State private var isCreatingNewAccount = false

    @State private var isPresentingAccountRecovery = false

    @State private var isPresentingOpeningHours = false

    @State private var openingHours: String = ""

    @State private var isPresentingUpdatePrompt = false

    @State private var selectedTab: Tab = .home

    @Environment(\.scenePhase)
    private var phase

    // MARK: - Types

    private enum Tab {
        case home, profile, contact, whatsNew
    }

    // MARK: - Methods

    @MainActor
    private func login() {
        guard !isLoggingIn
            && !isCreatingNewAccount
            && !isPresentingCallSheet
            && !isPresentingSignupSheet
            && !isPresentingOnboardingSheet
            && !isPresentingUpdatePrompt
        else { return }

        isLoggingIn = true
        Task { @MainActor in
            defer { isLoggingIn = false }
            isConnected = false
            isPresentingOpeningHours = false

            do {
                // First make sure we can talk to the server.
                let indexResponse = try await TowerApi.index()

                // We can talk to the server, check whether the user needs to update before making a call.
                let apiMajorVersion = indexResponse.apiVersion.split(separator: ".").first.flatMap { Int($0) }
                let appMajorVersion = Settings.versionPreference.split(separator: ".").first.flatMap { Int($0) }
                isPresentingUpdatePrompt = apiMajorVersion ?? Int.max > appMajorVersion ?? 0
                guard !isPresentingUpdatePrompt else { return }

                // If we don't have an anonymous account yet, create one, so it has time to propagate.
                let userId: UUID
                if let storedUserId = UUID(uuidString: Settings.userIdPreference) {
                    userId = storedUserId
                } else {
                    userId = try await TowerApi.registerUser().userId
                    Settings.userIdPreference = userId.uuidString
                }

                // If we don't have permissions prompt the user for permissions (and welcome them if they are new).
                isPresentingOnboardingSheet
                    = AVAudioSession.sharedInstance().recordPermission != .granted
                    || AVCaptureDevice.authorizationStatus(for: .video) != .authorized

                guard !isPresentingOnboardingSheet else { return }

                // Load the server profile, uploading legacy local-only data once for users upgrading the app.
                try await env.loadUserProfile(userId: userId)

                // If the server does not have a usable name and e-mail, prompt the user to complete the profile.
                isPresentingSignupSheet = env.userProfile?.isComplete != true

                // If the user is just signing up, mark the current WhatsNewEntry as seen (it makes no sense to show
                // these on the very first use.
                if isPresentingSignupSheet {
                    WhatsNewEntry.markAsSeen()
                }

                guard !isPresentingSignupSheet else { return }

                // Show What's New tab once per version if there are new entries.
                if WhatsNewEntry.isUnread {
                    selectedTab = .whatsNew
                }

                // We have everything we need to make a call, check to see if the service is actually open.
                openingHours = indexResponse.openingHours.description
                isPresentingOpeningHours = indexResponse.openingHours.status == .closed
                isConnected = true
            } catch {
                if error as? TowerError == .userNotFound {
                    isPresentingAccountRecovery = true
                } else {
                    env.errorWrapper = loginErrorWrapper(for: error)
                }
            }
        }
    }

    private func loginErrorWrapper(for error: Error) -> ErrorWrapper {
        ErrorWrapper(
            error: error,
            guidance: """
                Bitte überprüfe, ob du mit dem Internet verbunden bist. Wenn das Problem nicht an deiner \
                Internetverbindung liegt, gibt es möglicherweise ein vorrübergehendes Problem mit dem \
                Fernassistenz-Service. In diesem Fall versuche es bitte später noch einmal.
                """)
    }

    @MainActor
    private func createNewAccount() {
        guard !isCreatingNewAccount else { return }

        isCreatingNewAccount = true
        Task { @MainActor in
            do {
                Settings.userIdPreference = try await TowerApi.registerUser().userId.uuidString
                isCreatingNewAccount = false
                login()
            } catch {
                isCreatingNewAccount = false
                env.errorWrapper = ErrorWrapper(
                    error: error,
                    guidance: "Das neue Benutzerkonto konnte nicht angelegt werden. Bitte versuche es erneut.")
            }
        }
    }

}

// MARK: ContentView_Previews

class ContentView_Previews: PreviewProvider {

    // MARK: - Static properties

    static var previews: some View {
        ContentView()
    }

}
