//
//  ContactSheet.swift
//  Tower_iOS
//
//  Created by Arne Engelland on 2025-05-01.
//  Copyright © 2025 valo.media GmbH. All rights reserved.
//

import SwiftUI

// MARK: ContactSheet

/// A sheet presenting contact information and imprint details.
///
struct ContactSheet: View {

    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text(
                        """
                        Wir freuen uns über deine Fragen und Anregungen. \
                        Schreib uns jederzeit eine Mail oder ruf uns an. \
                        Wir sind von Montag bis Freitag zwischen 9 und 17 Uhr erreichbar. \
                        Weitere Infos findest du auf unserer Webseite.
                        """
                    )

                    // Contact items as individually focusable links
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Text("Mail:").bold()
                            Link("feedback@tower-assist.de",
                                 destination: URL(string: "mailto:feedback@tower-assist.de")!)
                                .accessibilityLabel("E-Mail an feedback@tower-assist.de")
                                .accessibilityHint("E-Mail verfassen")
                        }

                        HStack(spacing: 6) {
                            Text("Telefon:").bold()
                            Link("0173 8406203",
                                 destination: URL(string: "tel:01738406203")!)
                                .accessibilityLabel("Telefonnummer 0173 8406203 anrufen")
                                .accessibilityHint("Anruf starten")
                        }

                        HStack(spacing: 6) {
                            Text("Web:").bold()
                            Link("tower-assist.de",
                                 destination: URL(string: "https://tower-assist.de/")!)
                                .accessibilityLabel("Webseite tower-assist.de öffnen")
                        }
                    }
                    .padding(.top, 12)

                    Divider()

                    VStack {
                        Text("Tower Fernassistanz ist ein Angebot von:")
                            .bold()
                        Text("Bathildisheim e.V.")
                        let mapsQuery = "https://maps.apple.com/?q=Bathildisheim%20e.V.%20Bathildisstraße%207,%2034454%20Bad%20Arolsen"
                        Link("Bathildisstraße 7",
                             destination: URL(string: mapsQuery)!)
                        Link("34454 Bad Arolsen",
                             destination: URL(string: mapsQuery)!)
                    }
                }
                .padding()
            }
            .environment(\.multilineTextAlignment, .center)
            .navigationTitle("Kontakt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Schließen") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: ContactSheet_Previews

class ContactSheet_Previews: PreviewProvider {

    // MARK: - Static properties

    static var previews: some View {
        ContactSheet()
    }

}
