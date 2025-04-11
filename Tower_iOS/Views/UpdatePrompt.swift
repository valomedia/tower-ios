//
//  UpdatePrompt.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2025-03-22.
//  Copyright (c) 2025 valo.media GmbH. All rights reserved.
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
                headline: "Bitte aktualisiere TOWER Fernassistenz über den App Store, bevor du einen Anruf startest",
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
                    .buttonStyle(.borderedProminent)
                    .invertedForegroundColor()

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
