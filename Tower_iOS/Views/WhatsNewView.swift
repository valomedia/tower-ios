//
//  WhatsNewView.swift
//  Tower_iOS
//
//  Created by Arne Engelland on 2026-05-20.
//  Copyright © 2026 valo.media GmbH. All rights reserved.
//

import SwiftUI

// MARK: WhatsNewView

/// View displaying the changelog
///
struct WhatsNewView: View {

    // MARK: - Properties

    var body: some View {
        Group {
            if WhatsNewEntry.all.isEmpty {
                NoContentView(
                    title: "Keine Neuigkeiten",
                    headline: "Es gibt noch keine Einträge",
                    caption: "Sobald es Neuigkeiten gibt, findest du sie hier."
                )
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(WhatsNewEntry.all) { entry in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(entry.version)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(entry.title)
                                    .font(.headline)
                                Text(entry.body)
                            }
                            .accessibilityElement(children: .combine)
                            if entry.id != WhatsNewEntry.all.last?.id {
                                Divider()
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Neuigkeiten")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { WhatsNewEntry.markAsSeen() }
    }

    // MARK: - Static methods

}

// MARK: WhatsNewView_Previews

class WhatsNewView_Previews: PreviewProvider {

    // MARK: - Static properties

    static var previews: some View {
        NavigationView {
            WhatsNewView()
        }
    }

}
