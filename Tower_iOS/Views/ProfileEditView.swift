//
//  ProfileEditView.swift
//  Tower_iOS
//
//

import Foundation
import SwiftUI

// MARK: ProfileEditView

/// A view allowing the user to edit their profile without leaving the app.
///
struct ProfileEditView: View {

    // MARK: - Properties

    @Environment(\.colorScheme)
    private var colorScheme

    @State private var profileForm = UserProfileForm()
    @State private var hasSaved = false
    @State private var savedProfile = UserProfile()
    @State private var isSaving = false

    @EnvironmentObject private var env: TowerEnvironment

    var body: some View {
        Form {
            if !env.isUserProfileLoaded {
                Section {
                    ProgressView("Profil wird geladen …")
                }
            }

            Text(
                "Hier kannst du deine Angaben bearbeiten. Vorname und E-Mail benötigen wir, " +
                    "um dich bei einem Anruf zuordnen und kontaktieren zu können.")

            Section("Name") {
                HStack {
                    Text("Vorname")
                    TextField(text: $profileForm.firstName, prompt: Text("Erforderlich")) {
                        Text("Vorname")
                    }
                    .textContentType(.givenName)
                }
                HStack {
                    Text("Nachname")
                    TextField(text: $profileForm.lastName, prompt: Text("Optional")) {
                        Text("Nachname")
                    }
                    .textContentType(.familyName)
                }
            }

            Section {
                Picker("Geschlecht", selection: $profileForm.gender) {
                    Text("Keine Angabe").tag("")
                    Text(Gender.male.localizedDescription).tag(Gender.male.rawValue)
                    Text(Gender.female.localizedDescription).tag(Gender.female.rawValue)
                    Text(Gender.other.localizedDescription).tag(Gender.other.rawValue)
                }
                HStack {
                    Text("Geburtsdatum")
                    TextField(text: $profileForm.birthdate, prompt: Text("TT.MM.JJJJ")) {
                        Text("Geburtsdatum")
                    }
                    .keyboardType(.numbersAndPunctuation)
                    .accessibilityHint("Im Format Tag.Monat.Jahr")
                }
            } header: {
                Text("Persönliche Angaben")
            } footer: {
                if !profileForm.isBirthdateValid {
                    Text("Bitte gib das Geburtsdatum im Format TT.MM.JJJJ ein.")
                }
            }

            Section {
                HStack {
                    Text("Telefon")
                    TextField(text: $profileForm.phone, prompt: Text("Optional")) {
                        Text("Telefonnummer")
                    }
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                }
                HStack {
                    Text("E-Mail")
                    TextField(text: $profileForm.email, prompt: Text("Erforderlich")) {
                        Text("E-Mail-Adresse")
                    }
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .textContentType(.emailAddress)
                }
            } header: {
                Text("Kontakt")
            } footer: {
                if profileForm.hasInvalidEmail {
                    Text("Bitte gib eine gültige E-Mail-Adresse ein.")
                }
            }

            Section {
                Button(action: saveProfile) {
                    HStack {
                        Spacer()
                        Label(
                            hasSaved && !hasUnsavedChanges ? "Gesichert" : "Sichern",
                            systemImage: hasSaved && !hasUnsavedChanges ? "checkmark.circle" : "checkmark"
                        ).labelStyle(.trailingIcon)
                        Spacer()
                    }
                }
                .disabled(!profileForm.isValid || !hasUnsavedChanges || isSaving)
                .listRowBackground(Color(Asset.Assets.accentColor.color))
                .foregroundColor(colorScheme == .dark ? .black : .white)
            }

            Section("Weitere Einstellungen") {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack {
                        Label("iOS-Einstellungen öffnen", systemImage: "gear")
                        Spacer()
                        Image(systemName: "arrow.up.forward.app")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .disabled(!env.isUserProfileLoaded || isSaving)
        .navigationTitle("Profil")
        .navigationBarTitleDisplayMode(.inline)
        .dynamicTypeSize(...DynamicTypeSize.accessibility4)
        .onAppear(perform: loadProfile)
        .onChange(of: env.userProfile) { profile in
            guard let profile, profile != savedProfile else { return }
            loadProfile()
        }
    }

    private var hasUnsavedChanges: Bool {
        profileForm.profile != savedProfile
    }

    // MARK: - Methods

    private func loadProfile() {
        guard let profile = env.userProfile else { return }
        profileForm = UserProfileForm(profile)
        savedProfile = profile
        hasSaved = false
    }

    private func saveProfile() {
        let profile = profileForm.profile
        isSaving = true
        Task {
            do {
                try await env.updateUserProfile(profile)
                await MainActor.run {
                    savedProfile = profile
                    hasSaved = true
                    isSaving = false
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    env.errorWrapper = ErrorWrapper(
                        error: error,
                        guidance: "Bitte überprüfe deine Angaben und versuche es noch einmal.")
                }
            }
        }
    }

}

// MARK: ProfileEditView_Previews

class ProfileEditView_Previews: PreviewProvider {

    // MARK: - Static properties

    static var previews: some View {
        NavigationView {
            ProfileEditView()
                .environmentObject(env)
        }
    }

}
