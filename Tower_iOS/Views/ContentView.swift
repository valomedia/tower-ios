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
            Image(uiImage: Asset.Assets.logo.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            Text(isConnected ? "Willkommen bei Tower!" : "Verbinden…")
                    .font(.largeTitle)
            Button {
                isPresentingCallSheet = true
            } label: {
                Label("Hilfe erhalten", systemImage: "phone.fill")
            }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isConnected)
        }
                .padding()
                .sheet(item: $env.errorWrapper, onDismiss: { env.errorWrapper = nil }) { errorWrapper in
                    ErrorView(errorWrapper: errorWrapper)
                }
                .sheet(isPresented: $isPresentingCallSheet) {
                    NavigationView {
                        CallSheet()
                                .toolbar {
                                    ToolbarItem(placement: .navigationBarTrailing) {
                                        Button(role: .destructive) {
                                            isPresentingCallSheet = false
                                        } label: {
                                            Label("Auflegen", systemImage: "phone.down.fill")
                                        }
                                                .buttonStyle(.borderedProminent)
                                    }
                                }
                    }
                }
                .sheet(isPresented: $isPresentingOnboardingSheet) {
                    NavigationView {
                        OnboardingSheet()
                    }
                            .interactiveDismissDisabled()
                }
                .onChange(of: phase) { phase in
                    if (phase == .active) {
                        let user = Settings.usernamePreference
                        let pass = Settings.passwordPreference
                        let auth = (user + ":" + pass).data(using: .utf8)?.base64EncodedString()
                        guard let auth, user != "" && pass != "" else {
                            env.errorWrapper = ErrorWrapper(
                                    error: TowerError.missingCredentials,
                                    guidance: "Bitte füge in der Einstellungen-App Zugangsdaten hinzu.")
                            return
                        }

                        let url = URL(string: Settings.endpointPreference)
                        guard let url else {
                            env.errorWrapper = ErrorWrapper(
                                    error: TowerError.invalidEndpoint,
                                    guidance: "Bitte überprüfe die Einstellung „Server“.")
                            return
                        }

                        var request = URLRequest(url: url)
                        request.setValue("Basic " + auth, forHTTPHeaderField: "Authorization")
                        URLSession.shared.dataTask(with: request) { data, response, error in
                            if let error {
                                DispatchQueue.main.async {
                                    env.errorWrapper = ErrorWrapper(
                                            error: error,
                                            guidance: "Bitte überprüfe die Einstellung „Server“.")
                                }
                            } else {
                                guard let response = response as? HTTPURLResponse else {
                                    DispatchQueue.main.async {
                                        env.errorWrapper = ErrorWrapper(
                                                error: TowerError.invalidEndpoint,
                                                guidance: "Bitte überprüfe die Einstellung „Server“.")
                                    }
                                    return
                                }
                                switch response.statusCode {
                                case 200:
                                    isConnected = true
                                case 401:
                                    DispatchQueue.main.async {
                                        env.errorWrapper = ErrorWrapper(
                                                error: TowerError.badCredentials,
                                                guidance: "Bitte überprüfe Benutzername und Passwort.")
                                    }
                                    return
                                case 503:
                                    DispatchQueue.main.async {
                                        env.errorWrapper = ErrorWrapper(
                                                error: TowerError.serverError,
                                                guidance: "Bitte versuche es später erneut.")
                                    }
                                    return
                                default:
                                    DispatchQueue.main.async {
                                        env.errorWrapper = ErrorWrapper(
                                                error: TowerError.unexpectedError,
                                                guidance: "Frag den Entwickler, ob er besseren Code schreiben kann ;-)")
                                    }
                                    return
                                }
                            }
                        }
                                .resume()
                    }
                }
    }

    @StateObject private var env = TowerEnvironment()

    @State private var isPresentingCallSheet = false

    @State private var isPresentingOnboardingSheet
            = AVAudioSession.sharedInstance().recordPermission != .granted
                    || AVCaptureDevice.authorizationStatus(for: .video) != .authorized

    @State private var isConnected = false

    @Environment(\.scenePhase)
    private var phase

}


// MARK: ContentView_Previews

class ContentView_Previews: PreviewProvider {

    // MARK: - Static properties

    static var previews: some View {
        ContentView()
    }

}
