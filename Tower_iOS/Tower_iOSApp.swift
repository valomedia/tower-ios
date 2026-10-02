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
import AVFoundation


// MARK: Tower_iOSApp

@main struct Tower_iOSApp: App {

    // MARK: - Life cycle methods

    /// Constructor.
    ///
    /// This is the first thing that runs when the app starts up.  Currently the only thing it does is setting a few
    /// title items in the Settings.bundle to reflect the parameters this app was built with.
    ///
    init() {
        Settings.namePreference = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
        Settings.identifierPreference = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as! String
        Settings.versionPreference = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        Settings.buildPreference = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        
        try? AVAudioSession
            .sharedInstance()
            .setCategory(
                .playAndRecord,
                mode: .videoChat,
                options: [
                    .interruptSpokenAudioAndMixWithOthers,
                    .allowBluetooth,
                    .allowBluetoothA2DP
                ])
    }

    // MARK: - Properties

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

}
