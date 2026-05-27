//
//  WhatsNewView.swift
//  Tower_iOS
//
//  Created by Arne Engelland on 2026-05-20.
//  Copyright © 2026 valo.media GmbH. All rights reserved.
//

import SwiftUI

// MARK: WhatsNewView

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
                                ForEach(Array(entry.paragraphs.enumerated()), id: \.offset) { _, paragraph in
                                    Text(paragraph)
                                }
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
        .onAppear { Self.markAsSeen() }
    }

    // MARK: - Static methods

    static func shouldAutoShow() -> Bool {
        guard let latestVersion = WhatsNewEntry.latestVersion else { return false }
        return UserDefaults.standard.string(forKey: "latest_seen_whats_new_version") != latestVersion
    }

    static func markAsSeen() {
        guard let latestVersion = WhatsNewEntry.latestVersion else { return }
        UserDefaults.standard.set(latestVersion, forKey: "latest_seen_whats_new_version")
    }

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
