//
//  OpeningHoursSheet.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2025-02-18.
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
        ZStack(alignment: .topTrailing) {
            Color(UIColor.systemGray6)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 24) {
                Spacer(minLength: 0)

                Image(uiImage: Asset.Assets.logo.image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 180)
                    .accessibilityHidden(true)

                Text("Willkommen bei Tower!")
                    .font(.title3).bold()
                    .multilineTextAlignment(.center)

                Text(openingHours)
                    .font(.callout).bold()
                    .multilineTextAlignment(.center)

                Text("""
Wir arbeiten daran, diese Zeiten weiter auszubauen. Wenn du jetzt einen Termin mit uns hast, gehe auf Weiter. Ansonsten kannst du hier direkt deinen persönlichen Termin vereinbaren.
""")
                    .font(.callout)
                    .multilineTextAlignment(.center)

                Button {
                    openURL(appointmentURL)
                } label: {
                    Text("Jetzt Termin vereinbaren")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.darkModeAwareProminent)
                .padding(.horizontal)

                Spacer(minLength: 0)
            }
            .padding()

            Button(action: { dismiss() }) {
                Text("Weiter").bold()
            }
            .padding(.top, 16)
            .padding(.trailing, 16)
            .accessibilitySortPriority(-1)
        }
    }

}

// MARK: OpeningHoursView_Previews

/// Preview for OpeningHoursView
///
class OpeningHoursView_Previews: PreviewProvider {

    // MARK: - Static properties

    static var previews: some View {
        OpeningHoursSheet("Du erreichst uns momentan von Dienstag bis Donnerstag von 12 bis 16 Uhr.")
    }

}
