//
// Copyright (c) 2025-2026 valo.media GmbH
// All rights reserved.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import SwiftUI

// MARK: SignupSheet

/// A sheet prompting the user for their name and e-mail, as well as asking them to sign up for the newsletter.
///
struct SignupSheet: View {

    // MARK: - Properties

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationView {
            Form {
                Text("Verrate uns bitte deinen Namen, damit wir dich bei Anrufen besser ansprechen können.")
                Section {
                    HStack {
                        Text("Vorname")
                        TextField(text: $firstName, prompt: Text("Erforderlich")) {
                            Text("Vorname")
                        }
                    }
                    HStack {
                        Text("Nachname")
                        TextField(text: $lastName, prompt: Text("Optional")) {
                            Text("Nachname")
                        }
                    }
                    HStack {
                        Text("e-Mail")
                        TextField(text: $email, prompt: Text("Erforderlich")) {
                            Text("E-Mail-Adresse")
                        }
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                    }
                }
                Section {
                    Toggle("Ich möchte euren monatlichen Newsletter erhalten", isOn: $wantsNewsletter)
                        .disabled(isEmailProvided)
                }
                Section {
                    Button(action: handleSignup, label: {
                        HStack {
                            Spacer()
                            Label("Anmelden", systemImage: "arrow.right").labelStyle(.trailingIcon)
                            Spacer()
                        }
                    })
                        .disabled(firstName.isEmpty || !isEmailProvided)
                        .listRowBackground(Color(Asset.Assets.accentColor.color))
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                }
            }
                .navigationTitle("Angaben zu dir")
        }
            .dynamicTypeSize(...DynamicTypeSize.accessibility4)
    }

    @State private var firstName = Settings.firstNamePreference
    @State private var lastName = Settings.lastNamePreference
    @State private var email = Settings.emailPreference
    @State private var wantsNewsletter = false
    
    private var isEmailProvided: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @Environment(\.dismiss)
    private var dismiss

    // MARK: - Methods

    private func handleSignup() {
        Settings.firstNamePreference = firstName
        Settings.lastNamePreference = lastName
        Settings.emailPreference = email
        dismiss()
        Task {
            await NewsletterApi.signup(
                firstName: firstName,
                lastName: lastName,
                email: email,
                wantsNewsletter: wantsNewsletter
            )
        }
    }

}

// MARK: SignupSheet_Previews

class SignupSheet_Previews: PreviewProvider {

    // Mark: - Static properties

    static var previews: some View {
        VStack {
            EmptyView()
        }
        .sheet(isPresented: $isPresented) { SignupSheet() }
    }

    @State static private var isPresented = true

}
