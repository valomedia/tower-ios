//
//  MenuView.swift
//  Tower_iOS
//
//  Created by Arne Engelland on 2026-04-17.
//

import Foundation
import SwiftUI

// MARK: MenuView

/// A view collecting secondary actions from the home screen.
///
struct MenuView: View {

    // MARK: - Properties

    @AppStorage("first_name_preference")
    private var firstNamePreference = ""

    @AppStorage("last_name_preference")
    private var lastNamePreference = ""

    var body: some View {
        NavigationView {
            Form {
                Section {
                    NavigationLink {
                        ProfileEditView()
                    } label: {
                        MenuRow(
                            title: "Benutzerprofil",
                            subtitle: profileSummary,
                            systemImage: "person.crop.circle"
                        )
                    }
                    NavigationLink {
                        ContactView()
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
                            systemImage: "gear",
                            trailingSystemImage: "arrow.up.forward.app"
                        )
                    }
                }
            }
            .navigationTitle("Menü")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }

    private var profileSummary: String {
        let fullName = [firstNamePreference, lastNamePreference]
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
    var trailingSystemImage: String? = nil

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

            if let trailingSystemImage {
                Image(systemName: trailingSystemImage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
    }

}

// MARK: MenuView_Previews

class MenuView_Previews: PreviewProvider {

    // MARK: - Static properties

    static var previews: some View {
        MenuView()
    }

}
