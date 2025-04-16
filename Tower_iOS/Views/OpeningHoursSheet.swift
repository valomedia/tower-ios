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

/// A view telling the user when the service is available, shown if the user opens the app outside of service hours.
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

    var body: some View {
        NavigationView {
            NoContentView(
                image: Image(uiImage: Asset.Assets.logo.image),
                title: "Wir haben gerade geschlossen",
                headline: openingHours,
                caption:
                    """
                    Wir arbeiten daran, diese Zeiten weiter auszubauen. Falls du einen Termin mit uns hast, kannst du \
                    trotzdem einen Anruf mit uns starten.
                    """
            ) {
                Button {
                    dismiss()
                } label: {
                    Label("Verstanden", systemImage: "checkmark").labelStyle(.trailingIcon)
                }
                        .buttonStyle(.darkmodeAwareProminent)

            }
        }
    }

    @Environment(\.dismiss)
    private var dismiss

}

// MARK: OpeningHoursView_Previews

/// Preview for OpeningHoursView
///
class OpeningHoursView_Previews: PreviewProvider {

    // MARK: - Static properties

    static var previews: some View {
        OpeningHoursSheet("Montag bis Freitag von 8 bis 12 und von 13 bis 17 Uhr.")
    }

}
