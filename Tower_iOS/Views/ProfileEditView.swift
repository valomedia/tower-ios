//
//  ProfileEditView.swift
//  Tower_iOS
//
//  Created by Arne Engelland on 2026-04-17.
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

    @Environment(\.dismiss)
    private var dismiss

    @State private var firstName = Settings.firstNamePreference
    @State private var lastName = Settings.lastNamePreference
    @State private var gender = Settings.genderPreference
    @State private var birthdate = Settings.birthdatePreference
    @State private var phone = Settings.phonePreference
    @State private var email = Settings.emailPreference

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
                        Label("Sichern", systemImage: "checkmark").labelStyle(.trailingIcon)
                        Spacer()
                    }
                }
                .disabled(!canSave)
                .listRowBackground(Color(Asset.Assets.accentColor.color))
                .foregroundColor(colorScheme == .dark ? .black : .white)
            }
        }
        .navigationTitle("Benutzerprofil")
        .navigationBarTitleDisplayMode(.inline)
        .dynamicTypeSize(...DynamicTypeSize.accessibility4)
        .onAppear(perform: loadProfile)
    }

    private var canSave: Bool {
        !trimmedFirstName.isEmpty && !trimmedEmail.isEmpty && isBirthdateValid
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
    }

    private func saveProfile() {
        Settings.firstNamePreference = trimmedFirstName
        Settings.lastNamePreference = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        Settings.genderPreference = gender
        Settings.birthdatePreference = birthdate.trimmingCharacters(in: .whitespacesAndNewlines)
        Settings.phonePreference = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        Settings.emailPreference = trimmedEmail

        dismiss()
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
