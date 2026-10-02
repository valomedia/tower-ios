//
// Copyright (c) 2025-2026 valo.media GmbH
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

// MARK: UpdatePrompt

/// A screen telling the user they need to update their app to proceed.
///
struct UpdatePrompt: View {

    // MARK: - Properties

    var body: some View {
        NavigationView {
            NoContentView(
                title: "Deine App benötigt ein Update",
                headline: "Bitte aktualisiere TOWER Assist über den App Store, bevor du einen Anruf startest",
                caption:
                    """
                    Wir arbeiten kontinuierlich daran, unser Angebot zu verbessen. Gelegentlich ist es dafür \
                    notwendig, die App zu aktualisieren. Um die App zu aktualisieren, musst du zum App Store gehen und \
                    dort auf „aktualisieren“ tippen. Bevor du deine App aktualisiert hast, kannst du leider keinen \
                    Anruf starten.
                    """
            ) {
                Button {
                    if let url = URL(string: "https://apps.apple.com/app/tower-fernassistenz/id6450928033") {
                        DispatchQueue.main.async {
                            UIApplication.shared.open(url)
                        }
                    }
                } label: {
                    Label("AppStore öffnen", systemImage: "arrow.right").labelStyle(.trailingIcon)
                }
                        .buttonStyle(.darkModeAwareProminent)
            }
        }
    }

}

// MARK: UpdatePrompt_Previews

/// Preview for UpdatePrompt
///
class UpdatePrompt_Previews: PreviewProvider {

    // MARK: - Static properties

    static var previews: some View {
        UpdatePrompt()
    }

}
