//
//  LoginSheet.swift
//  Tower_iOS
//
//  Created by Thomas Lier on 15.08.24.
//

import Foundation
import SwiftUI

// MARK: LoginSheet

/// A sheet to enter login information to the app.
///
struct LoginSheet: View {
    
    // MARK: - Properties
    
    var body: some View {
        VStack {
            
            if Settings.usernamePreference != "" && Settings.passwordPreference != "" {
                Text("Anmeldung Fehlgeschlagen")
                    .font(.title)
                    .padding()
                
                Text(
                    UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory
                    ? "Erneut versuchen"
                    : "Bitte versuchen Sie es erneut")
                .foregroundColor(Color(UIColor.systemRed))
            }
            
            if Settings.usernamePreference == "" && Settings.passwordPreference == "" {
                Text("Anmeldung")
                    .font(.title)
                    .padding()
                
                Text(
                    UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory
                    ? "Zugangsdaten eingeben"
                    : "Bitte geben Sie Ihre Zugangsdaten ein.")
            }
            
            Form {
                Section {
                    HStack {
                        Text("Benutzername")
                        TextField ("", text: $username)
                    }
                    HStack {
                        Text("Passwort")
                        SecureField("", text: $password)
                    }
                }
                
                Section {
                    Button {
                        Settings.usernamePreference = username
                        Settings.passwordPreference = password
                        dismiss()
                    }
                    label: {
                        HStack {
                            Spacer()
                            Label("Anmelden", systemImage: "arrow.right").labelStyle(.trailingIcon)
                            Spacer()
                        }
                    }
                    .listRowBackground(Color(Asset.Assets.accentColor.color))
                    .foregroundColor(.white)
                }
                
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.accessibility4)
    }
    
    @State private var username = Settings.usernamePreference
    @State private var password = Settings.passwordPreference
    
    @Environment(\.dismiss)
    private var dismiss
            
}

// MARK: #Preview

#Preview {
    LoginSheet()
}
