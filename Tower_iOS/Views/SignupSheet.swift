//
//  SignupSheet.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2025-02-05.
//  Copyright (c) 2025 valo.media GmbH. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: SignupSheet

/// A sheet prompting the user for their name and e-mail, as well as asking them to sign up for the newsletter.
///
struct SignupSheet: View {

    // MARK: - Properties

    var body: some View {
        NavigationView {
            Form {
                Text("Verrate uns bitte deinen Namen, damit wir dich bei Anrufen besser ansprechen können.")
                Section {
                    HStack {
                        Text("Vorname")
                        TextField("", text: $firstName)
                    }
                    HStack {
                        Text("Nachname")
                        TextField("", text: $lastName)
                    }
                    HStack {
                        Text("e-Mail")
                        TextField("", text: $email)
                            .keyboardType(.emailAddress)
                    }
                }
                Section {
                    Toggle("Ich möchte euren monatlichen Newsletter erhalten", isOn: $wantsNewsletter)
                        .disabled(email.isEmpty)
                }
                Section {
                    Button(action: handleSignup, label: {
                        HStack {
                            Spacer()
                            Label("Anmelden", systemImage: "arrow.right").labelStyle(.trailingIcon)
                            Spacer()
                        }
                    })
                        .disabled(firstName.isEmpty)
                        .listRowBackground(Color(Asset.Assets.accentColor.color))
                        .foregroundColor(.white)
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

    @Environment(\.dismiss)
    private var dismiss

    // MARK: - Methods

    private func handleSignup() {
        Settings.firstNamePreference = firstName
        Settings.lastNamePreference = lastName
        Settings.emailPreference = email
        dismiss()
        if wantsNewsletter {
            Task {
                await NewsletterApi.signup(firstName: firstName, lastName: lastName, email: email)
            }
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
