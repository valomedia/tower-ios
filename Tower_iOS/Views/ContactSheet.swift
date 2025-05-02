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
                VStack(spacing: 16) {
                    Text(
                        """
                        Wir freuen uns über deine Fragen und Anregungen. Schreib uns jederzeit eine Mail an [feedback@tower-assist.de](mailto:feedback@tower-assist.de). Du kannst uns auch anrufen unter der Nummer [0173 8406203](tel:01738406203). Wir sind von Montag bis Freitag zwischen 9 und 17 Uhr erreichbar. Weitere Infos findest du auf unserer Webseite unter [tower-assist.de](https://tower-assist.de/).
                        """
                    )
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                    Divider()
                        .padding(.vertical, 8)

                    VStack(spacing: 4) {
                        Text("Tower Fernassistanz ist ein Angebot von:")
                            .bold()
                            .font(.body)
                            .multilineTextAlignment(.center)
                        Text("Bathildisheim e.V.")
                            .multilineTextAlignment(.center)
                        Text("Bathildisstraße 7")
                            .multilineTextAlignment(.center)
                        Text("34454 Bad Arolsen")
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding()
            }
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
