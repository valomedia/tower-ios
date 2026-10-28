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

// MARK: PricingSheet

/// Pricing presentation shown after the user's free trial starts.
struct PricingSheet: View {

    // MARK: - Types

    private enum Layout {
        static let headerSpacing: CGFloat = 8
    }

    // MARK: - Properties

    var body: some View {
        NavigationView {
            PricingView {
                VStack(alignment: .leading, spacing: Layout.headerSpacing) {
                    Text("Deine kostenlose Testphase läuft")
                        .font(.title.bold())
                    Text("Du bist jetzt auf der 7-tägigen kostenlosen Testphase.")
                    Text("Alle Abos laufen monatlich und ergänzen dein kostenloses Minutenkontingent.")
                        .foregroundStyle(.secondary)
                }
            } footer: {
                Button {
                    dismiss()
                } label: {
                    Text("Weiter")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.darkModeAwareProminent)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Schließen") { dismiss() }
                        .accessibilitySortPriority(-1)
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    @Environment(\.dismiss)
    private var dismiss

}
