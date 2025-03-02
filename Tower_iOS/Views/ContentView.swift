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
                .sheet(item: $env.errorWrapper, onDismiss: { env.errorWrapper = nil }) { errorWrapper in
                    ErrorView(errorWrapper: errorWrapper)
                }
                .sheet(isPresented: $isPresentingCallSheet) {
                    CallSheet()
                            .interactiveDismissDisabled()
                }
                .sheet(isPresented: $isPresentingOnboardingSheet) {
                    OnboardingSheet()
                            .interactiveDismissDisabled()
                }
                .sheet(isPresented: $isPresentingSignupSheet) {
                    SignupSheet()
                        .interactiveDismissDisabled()
                }
                .sheet(isPresented: $isPresentingOpeningHours) {
                    OpeningHoursSheet(schedule: schedule)
                }
                .onChange(of: isPresentingOnboardingSheet) { isPresentingOnboardingSheet in
                    if !isPresentingOnboardingSheet { isPresentingSignupSheet = true }
                }
                .onChange(of: isPresentingSignupSheet) { isPresentingSignupSheet in
                    if !isPresentingSignupSheet { login() }
                }
                .onChange(of: phase) { phase in
                    isConnected = false
                    if (phase == .active && !isPresentingOnboardingSheet && !isPresentingSignupSheet) {
                        isPresentingOpeningHours = false
                        login()
                    }
                }
                .environmentObject(env)
    }

    @StateObject private var env = TowerEnvironment()

    @State private var isPresentingCallSheet = false

    @State private var isPresentingSignupSheet = false

    @State private var isPresentingOnboardingSheet
            = AVAudioSession.sharedInstance().recordPermission != .granted
                    || AVCaptureDevice.authorizationStatus(for: .video) != .authorized

    @State private var isConnected = false

    @State private var isPresentingOpeningHours = false

    @State private var schedule: [(Date, String?)] = []

    @Environment(\.scenePhase)
    private var phase
    
    // MARK: - Methods
    
    private func login() {
        Task {
            do {
                let indexResponse = try await TowerApi.index()
                schedule = indexResponse.openingHours.schedule
                if indexResponse.openingHours.status == .closed {
                    isPresentingOpeningHours = true
                }

                // If we don't have an anonymous account yet, create one.
                if UUID(uuidString: Settings.userIdPreference) == nil {
                    Settings.userIdPreference = (try await TowerApi.registerUser()).userId.uuidString
                }

                isConnected = true
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
