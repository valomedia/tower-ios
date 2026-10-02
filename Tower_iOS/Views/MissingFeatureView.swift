//
// Copyright (c) 2023-2026 valo.media GmbH
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

import Foundation
import SwiftUI


// MARK: MissingFeatureView

/// A view telling the user about a missing feature.
///
/// This view is shown when a user encounters a place in the apps that isn't finished yet.
///
struct MissingFeatureView: View {

    // MARK: - Properties

    var body: some View {
        NoContentView(
                title: "In Arbeit",
                headline: "Diese Funktion befindet sich noch in der Entwicklung",
                caption: """
                         Sie haben eine Funktion aufgerufen, an der wir noch arbeiten.  Bitte versuchen Sie es zu \
                         einem späteren Zeitpunkt erneut.
                         """)
    }

}


// MARK: MissingFeatureView_Previews

class MissingFeatureView_Previews: PreviewProvider {

    // MARK: - Static properties

    static var previews: some View {
        MissingFeatureView()
    }

}
