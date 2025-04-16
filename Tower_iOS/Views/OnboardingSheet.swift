//
//  OnboardingSheet.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2023-04-19.
//
//

import Foundation
import SwiftUI
import AVFoundation


// MARK: OnboardingSheet

/// A sheet presenting the user with steps necessary when first using the app.
///
/// This will walk the user through giving access to camera and microphone before making the first call.
///
struct OnboardingSheet: View {

    // MARK: - Properties

    var body: some View {
        if (!onboardingFailed) {
            NoContentView(
                    image: Image(uiImage: Asset.Assets.mascot.image),
                    title: "Willkommen bei Tower!",
                    headline: "Schön, dass Du da bist",
                    caption: """
                             Um Dir helfen zu können, benötigen wir Deine Erlaubnis, \
                             Kamera und Mikrofon an Deinem Handy \
                             einzuschalten. 
                            """) {
                Button {
                    AVAudioSession.sharedInstance().requestRecordPermission { granted in
                        if granted {
                            AVCaptureDevice.requestAccess(for: .video) { granted in
                                if granted {
                                    dismiss()
                                } else {
                                    onboardingFailed = true
                                }
                            }
                        } else {
                            onboardingFailed = true
                        }
                    }
                } label: {
                    Label("Weiter", systemImage: "arrow.right").labelStyle(.trailingIcon)
                }
                        .buttonStyle(.darkmodeAwareProminent)
            }
        } else {
            NoContentView(
                    title: "Fehlende Berechtigungen",
                    headline: "Wir können nicht auf Deine Kamera und Dein Mikrofon zugreifen",
                    caption: """
                             Um dich mit einer Assistenz zu verbinden, \
                             möchten wir auf Deine Kamera und Dein Mikrofon zugreifen. \
                             Ansonsten ist eine Verbindung nicht möglich. \
                             Du kannst uns jetzt die Erlaubnis dafür geben. \
                             Klicke dazu auf den Knopf, um zu den Einstellungen zu gelangen.
                             """) {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        DispatchQueue.main.async {
                            UIApplication.shared.open(url)
                        }
                    }
                } label: {
                    Label("Einstellungen", systemImage: "gear").labelStyle(.trailingIcon)
                }
                        .buttonStyle(.darkmodeAwareProminent)

            }
        }
    }

    @State private var onboardingFailed
            = AVAudioSession.sharedInstance().recordPermission == .denied
                    || AVCaptureDevice.authorizationStatus(for: .video) == .denied

    @Environment(\.dismiss)
    private var dismiss

}


// MARK: OnboardingSheet_Previews

class OnboardingSheet_Previews: PreviewProvider {

    // Mark: - Static properties

    static var previews: some View {
        NavigationView {
            OnboardingSheet()
        }
    }

}
