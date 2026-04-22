//
//  MenuSheet.swift
//  Tower_iOS
//
//  Created by Arne Engelland on 2026-04-17.
//

import Foundation
import SwiftUI

// MARK: MenuSheet

/// A sheet collecting secondary actions from the home screen.
///
struct MenuSheet: View {

    // MARK: - Properties

    @Environment(\.dismiss)
    private var dismiss

    @State private var isPresentingProfileSheet = false
    @State private var isPresentingContactSheet = false

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Button {
                        isPresentingProfileSheet = true
                    } label: {
                        MenuRow(
                            title: "Benutzerprofil",
                            subtitle: profileSummary,
                            systemImage: "person.crop.circle"
                        )
                    }
                    Button {
                        isPresentingContactSheet = true
                    } label: {
                        MenuRow(
                            title: "Kontakt",
                            subtitle: "Fragen, Feedback und Impressum",
                            systemImage: "envelope"
                        )
                    }
                }

                Section("Weitere Einstellungen") {
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            DispatchQueue.main.async {
                                UIApplication.shared.open(url)
                            }
                        }
                    } label: {
                        MenuRow(
                            title: "iOS-Einstellungen öffnen",
                            subtitle: "Server, App-Info und Berechtigungen",
                            systemImage: "gear"
                        )
                    }
                }
            }
            .navigationTitle("Menü")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Schließen") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $isPresentingProfileSheet) {
                ProfileEditSheet()
            }
            .sheet(isPresented: $isPresentingContactSheet) {
                ContactSheet()
            }
        }
    }

    private var profileSummary: String {
        let fullName = [Settings.firstNamePreference, Settings.lastNamePreference]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        return fullName.isEmpty ? "Name, E-Mail und Kontaktdaten" : fullName
    }

}

// MARK: MenuRow

private struct MenuRow: View {

    // MARK: - Properties

    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(Color(Asset.Assets.accentColor.color))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
    }

}

// MARK: MenuSheet_Previews

class MenuSheet_Previews: PreviewProvider {

    // MARK: - Static properties

    static var previews: some View {
        MenuSheet()
    }

}
