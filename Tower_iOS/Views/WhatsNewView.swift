//
// Copyright (c) 2026 valo.media GmbH
// All rights reserved.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
