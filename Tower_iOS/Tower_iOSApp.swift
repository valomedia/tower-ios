//
//  Tower_iOSApp.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2023-03-06.
//
//

import Foundation
import SwiftUI


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
        UIApplication.shared.isIdleTimerDisabled = true
    }

    // MARK: - Properties

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

}
