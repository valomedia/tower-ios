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

// MARK: PricingScreen

/// Pricing screen opened from profile settings.
struct PricingScreen: View {

    // MARK: - Types

    private enum Layout {
        static let headerSpacing: CGFloat = 8
    }

    // MARK: - Properties

    var body: some View {
        PricingView {
            VStack(alignment: .leading, spacing: Layout.headerSpacing) {
                Text("Unsere Minutenpakete")
                    .font(.title.bold())
                Text("Alle Abos laufen monatlich und ergänzen dein kostenloses Minutenkontingent.")
                    .foregroundStyle(.secondary)
            }
        } footer: {
            EmptyView()
        }
    }

}

// MARK: - PricingScreen_Previews

class PricingScreen_Previews: PreviewProvider {

    // MARK: - Static properties

    static var previews: some View {
        NavigationView {
            PricingScreen()
        }
    }

}
