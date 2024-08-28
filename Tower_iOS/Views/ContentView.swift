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
        
                .sheet(isPresented: $isPresentingLoginSheet) {
                    LoginSheet()
                        .interactiveDismissDisabled()
                }
                .onChange(of: isPresentingLoginSheet) { isPresentingLoginSheet in
                    if !isPresentingLoginSheet {
                        login()
                    }
                }
                .onChange(of: phase) { phase in
                    isConnected = false
                    

                    if (phase == .active && !isPresentingOnboardingSheet) {
                        login()
                    }
                }
                .environmentObject(env)
    }

    func login() {
        Task {
            do {
                try await TowerApi.index()
                isConnected = true
            }
            catch {
                Task { @MainActor in
                    isPresentingLoginSheet = true
                }
            }
        }
    }
        
        
    
    
    
    @StateObject private var env = TowerEnvironment()

    @State private var isPresentingCallSheet = false
    
    @State private var isPresentingLoginSheet = false

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
