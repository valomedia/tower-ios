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

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var gender = ""
    @State private var birthdate = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var hasSaved = false
    @State private var savedSnapshot: [String] = []

    var body: some View {
        Form {
            Text("Hier kannst du deine Angaben bearbeiten. Vorname und E-Mail benötigen wir, um dich bei einem Anruf zuordnen und kontaktieren zu können.")

            Section("Name") {
                HStack {
                    Text("Vorname")
                    TextField(text: $firstName, prompt: Text("Erforderlich")) {
                        Text("Vorname")
                    }
                    .textContentType(.givenName)
                }
                HStack {
                    Text("Nachname")
                    TextField(text: $lastName, prompt: Text("Optional")) {
                        Text("Nachname")
                    }
                    .textContentType(.familyName)
                }
            }

            Section {
                Picker("Geschlecht", selection: $gender) {
                    Text("Keine Angabe").tag("")
                    Text(Gender.male.localizedDescription).tag(Gender.male.rawValue)
                    Text(Gender.female.localizedDescription).tag(Gender.female.rawValue)
                    Text(Gender.other.localizedDescription).tag(Gender.other.rawValue)
                }
                HStack {
                    Text("Geburtsdatum")
                    TextField(text: $birthdate, prompt: Text("TT.MM.JJJJ")) {
                        Text("Geburtsdatum")
                    }
                    .keyboardType(.numbersAndPunctuation)
                    .accessibilityHint("Im Format Tag.Monat.Jahr")
                }
            } header: {
                Text("Persönliche Angaben")
            } footer: {
                if !isBirthdateValid {
                    Text("Bitte gib das Geburtsdatum im Format TT.MM.JJJJ ein.")
                }
            }

            Section("Kontakt") {
                HStack {
                    Text("Telefon")
                    TextField(text: $phone, prompt: Text("Optional")) {
                        Text("Telefonnummer")
                    }
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                }
                HStack {
                    Text("E-Mail")
                    TextField(text: $email, prompt: Text("Erforderlich")) {
                        Text("E-Mail-Adresse")
                    }
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .textContentType(.emailAddress)
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
                .disabled(!canSave || !hasUnsavedChanges)
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
        .navigationTitle("Profil")
        .navigationBarTitleDisplayMode(.inline)
        .dynamicTypeSize(...DynamicTypeSize.accessibility4)
        .onAppear(perform: loadProfile)
    }

    private var canSave: Bool {
        !trimmedFirstName.isEmpty && !trimmedEmail.isEmpty && isBirthdateValid
    }

    private var formSnapshot: [String] {
        [
            trimmedFirstName,
            lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            gender,
            birthdate.trimmingCharacters(in: .whitespacesAndNewlines),
            phone.trimmingCharacters(in: .whitespacesAndNewlines),
            trimmedEmail,
        ]
    }

    private var hasUnsavedChanges: Bool {
        formSnapshot != savedSnapshot
    }

    private var trimmedFirstName: String {
        firstName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isBirthdateValid: Bool {
        let value = birthdate.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty || UserProfile.date(fromPreference: value) != nil
    }

    // MARK: - Methods

    private func loadProfile() {
        firstName = Settings.firstNamePreference
        lastName = Settings.lastNamePreference
        gender = Settings.genderPreference
        birthdate = Settings.birthdatePreference
        phone = Settings.phonePreference
        email = Settings.emailPreference
        savedSnapshot = formSnapshot
        hasSaved = false
    }

    private func saveProfile() {
        Settings.firstNamePreference = trimmedFirstName
        Settings.lastNamePreference = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        Settings.genderPreference = gender
        Settings.birthdatePreference = birthdate.trimmingCharacters(in: .whitespacesAndNewlines)
        Settings.phonePreference = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        Settings.emailPreference = trimmedEmail

        savedSnapshot = formSnapshot
        hasSaved = true
    }

}

// MARK: ProfileEditView_Previews

class ProfileEditView_Previews: PreviewProvider {

    // MARK: - Static properties

    static var previews: some View {
        NavigationView {
            ProfileEditView()
        }
    }

}
