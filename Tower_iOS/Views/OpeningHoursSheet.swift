//
//  OpeningHoursSheet.swift
//  tower-ios
//
//  Copyright (c) 2025 valo.media GmbH. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: OpeningHoursView

/// A view informing the user the service is currently closed and guiding them to book an appointment.
///
struct OpeningHoursSheet: View {

    // MARK: - Life cycle methods

    init(_ openingHours: String) {
        self.openingHours = openingHours
    }

    // MARK: - Properties

    /// The opening hours description string to display to the user.
    ///
    let openingHours: String

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    private var appointmentURL: URL {
        var components = URLComponents(string: "https://tower-assist.de/terminvereinbarung/")!
        var items: [URLQueryItem] = []
        let first = Settings.firstNamePreference
        let mail  = Settings.emailPreference
        if !first.isEmpty { items.append(URLQueryItem(name: "firstname", value: first)) }
        if !mail.isEmpty  { items.append(URLQueryItem(name: "email",     value: mail)) }
        if !items.isEmpty { components.queryItems = items }
        return components.url!
    }

    // MARK: - View

    var body: some View {
        NavigationView {
            NoContentView(
                image: Image(uiImage: Asset.Assets.logo.image),
                title: "Willkommen bei Tower!",
                headline: openingHours,
                caption: "Wir arbeiten daran, diese Zeiten weiter auszubauen. " +
                    "Wenn du jetzt einen Termin mit uns hast, gehe auf Weiter. " +
                    "Ansonsten kannst du hier direkt deinen persönlichen Termin vereinbaren."
            ) {
                VStack(spacing: 16) {
                    Button {
                        openURL(appointmentURL)
                    } label: {
                        Text("Jetzt Termin vereinbaren")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.darkModeAwareProminent)
                }
            }
            .environment(\.multilineTextAlignment, .center)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Weiter") { dismiss() }
                        .accessibilitySortPriority(-1)
                }
            }
        }
    }

}

// MARK: OpeningHoursView_Previews

/// Preview for OpeningHoursView
///
class OpeningHoursView_Previews: PreviewProvider {

    // MARK: - Static properties

    static var previews: some View {
        OpeningHoursSheet("Spontan erreichst du uns Dienstag bis Donnerstag von 12 bis 16 Uhr.")
    }

}
