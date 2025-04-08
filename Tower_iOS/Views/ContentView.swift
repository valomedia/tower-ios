//
//  ContentView.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2023-03-06.
//
//

import Foundation
import SwiftUI
import AVFoundation


// MARK: ContentView

struct ContentView: View {

    // MARK: - Properties

    var body: some View {
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
                    .buttonStyle(.borderedProminent)
                    .disabled(!isConnected)
                    .accessibilityHidden(!isConnected)
                    .padding()
            Spacer()
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url)
                    }
                }
            } label: {
                Label("Einstellungen", systemImage: "gear")
            }
            Spacer()
        }
                .padding()
                .sheet(item: $env.errorWrapper, onDismiss: { env.errorWrapper = nil; login() }) { errorWrapper in
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
                .onChange(of: phase) { phase in
                    if (phase == .active) { login() }
                }
                .environmentObject(env)
    }

    @StateObject private var env = TowerEnvironment()

    @State private var isPresentingCallSheet = false

    @State private var isPresentingSignupSheet = false

    @State private var isPresentingOnboardingSheet = false

    @State private var isConnected = false

    @State private var isPresentingOpeningHours = false

    @State private var openingHours: String = ""

    @State private var isPresentingUpdatePrompt = false

    @Environment(\.scenePhase)
    private var phase

    // MARK: - Methods

    private func login() {
        Task {
            guard !isPresentingCallSheet 
                && !isPresentingSignupSheet
                && !isPresentingOnboardingSheet
                && !isPresentingUpdatePrompt 
            else { return }
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
                if UUID(uuidString: Settings.userIdPreference) == nil {
                    Settings.userIdPreference = (try await TowerApi.registerUser()).userId.uuidString
                }
                isConnected = true

                // If we don't have permissions prompt the user for permissions (and welcome them if they are new).
                isPresentingOnboardingSheet
                    = AVAudioSession.sharedInstance().recordPermission != .granted 
                        || AVCaptureDevice.authorizationStatus(for: .video) != .authorized
                guard !isPresentingOnboardingSheet else { return }

                // If we don't know the name of the user prompt them to sign up (first name is the only required field).
                isPresentingSignupSheet = Settings.firstNamePreference.isEmpty
                guard !isPresentingSignupSheet else { return }

                // We have everything we need to make a call, check to see if the service is actually open.
                openingHours = indexResponse.openingHours.description
                isPresentingOpeningHours = indexResponse.openingHours.status == .closed
                guard !isPresentingOpeningHours else { return }
            }
            catch {
                Task { @MainActor in
                    env.errorWrapper = ErrorWrapper(
                        error: error,
                        guidance: """
                            Bitte überprüfe ob du die aktuelle Version der Tower-Fernassistenz-App installiert hast \
                            und versuche es dann erneut. Wenn das Problem weiterhin autritt, wende dich an unseren \
                            Support.
                            """)
                }
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
