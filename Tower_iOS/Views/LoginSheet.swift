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
        
        if Settings.usernamePreference != "" && Settings.passwordPreference != "" {
            Text("Anmeldung Fehlgeschlagen")
                .font(.title)
                .padding()
            
            Text("Bitte geben Sie erneut Ihre Anmeldeinformationen ein")
        }
   
        if Settings.usernamePreference == "" && Settings.passwordPreference == "" {
            Text("Anmeldung")
                .font(.title)
                .padding()
            
            Text("Bitte geben Sie Ihre Anmeldeinformationen ein.")
                .padding()
        }
        HStack {
            Text("Benutzername")
            TextField ("", text: $username)
        }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.systemGray4), lineWidth: 1))
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
        
        
        
        HStack {
            Text("Passwort")
            SecureField("", text: $password)
        }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.systemGray4), lineWidth: 1))
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
  
        Button {
            Settings.usernamePreference = username
            Settings.passwordPreference = password
            dismiss()
            
            
        } label: {
            Label("Anmelden", systemImage: "arrow.right").labelStyle(.trailingIcon)
        }
            .buttonStyle(.borderedProminent)
        
        Spacer()

    }
    @State private var username = ""
    @State private var password = ""
    
    @Environment(\.dismiss)
    private var dismiss
}



// MARK: #Preview

#Preview {
    LoginSheet()
}

