//
//  SignupSheet.swift
//  tower-ios
//
//  Copyright (c) 2025 valo.media GmbH. All rights reserved.
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
                        TextField(text: $profileForm.firstName, prompt: Text("Erforderlich")) {
                            Text("Vorname")
                        }
                    }
                    HStack {
                        Text("Nachname")
                        TextField(text: $profileForm.lastName, prompt: Text("Optional")) {
                            Text("Nachname")
                        }
                    }
                    HStack {
                        Text("E-Mail")
                        TextField(text: $profileForm.email, prompt: Text("Erforderlich")) {
                            Text("E-Mail-Adresse")
                        }
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                    }
                } footer: {
                    if profileForm.hasInvalidEmail {
                        Text("Bitte gib eine gültige E-Mail-Adresse ein.")
                    }
                }
                Section {
                    Toggle("Ich möchte euren monatlichen Newsletter erhalten", isOn: $wantsNewsletter)
                        .disabled(!profileForm.isEmailValid)
                }
                Section {
                    Button(action: handleSignup, label: {
                        HStack {
                            Spacer()
                            Label("Anmelden", systemImage: "arrow.right").labelStyle(.trailingIcon)
                            Spacer()
                        }
                    })
                        .disabled(!profileForm.isValid || !env.isUserProfileLoaded || isSaving)
                        .listRowBackground(Color(Asset.Assets.accentColor.color))
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                }
            }
                .disabled(!env.isUserProfileLoaded || isSaving)
                .navigationTitle("Angaben zu dir")
        }
            .dynamicTypeSize(...DynamicTypeSize.accessibility4)
            .onAppear(perform: loadProfile)
            .sheet(item: $errorWrapper) { ErrorView(errorWrapper: $0) }
    }

    @State private var profileForm = UserProfileForm()
    @State private var wantsNewsletter = false
    @State private var isSaving = false
    @State private var errorWrapper: ErrorWrapper?

    @Environment(\.dismiss)
    private var dismiss

    @EnvironmentObject private var env: TowerEnvironment

    // MARK: - Methods

    private func handleSignup() {
        let profile = profileForm.profile
        let firstName = profile.firstName ?? ""
        let lastName = profile.lastName ?? ""
        let email = profile.email ?? ""
        let shouldSubscribe = wantsNewsletter
        isSaving = true
        Task {
            do {
                try await env.updateUserProfile(profile)
                await MainActor.run {
                    isSaving = false
                    dismiss()
                }
                await NewsletterApi.signup(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    wantsNewsletter: shouldSubscribe)
            } catch {
                await MainActor.run {
                    isSaving = false
                    errorWrapper = ErrorWrapper(
                        error: error,
                        guidance: "Bitte überprüfe deine Angaben und versuche es mit einer anderen E-Mail-Adresse.")
                }
            }
        }
    }

    private func loadProfile() {
        guard let userProfile = env.userProfile else { return }
        profileForm = UserProfileForm(userProfile)
    }

}

// MARK: SignupSheet_Previews

class SignupSheet_Previews: PreviewProvider {

    // MARK: - Static properties

    static var previews: some View {
        VStack {
            EmptyView()
        }
        .sheet(isPresented: $isPresented) {
            SignupSheet().environmentObject(env)
        }
    }

    @State static private var isPresented = true

}
