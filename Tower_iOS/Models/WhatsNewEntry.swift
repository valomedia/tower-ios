//
//  WhatsNewEntry.swift
//  Tower_iOS
//
//  Created by Arne Engelland on 2026-05-20.
//  Copyright © 2026 valo.media GmbH. All rights reserved.
//

import Foundation

// MARK: WhatsNewEntry

struct WhatsNewEntry: Identifiable {

    // MARK: - Properties

    let id: String
    let version: String
    let title: String
    let items: [String]

}

// MARK: WhatsNewEntry constants

extension WhatsNewEntry {

    static let all: [WhatsNewEntry] = [
        // Add new entries at the top. Example:
        //
        // WhatsNewEntry(
        //     id: "1.3.0",
        //     version: "Version 1.3.0",
        //     title: "Was ist neu",
        //     items: [
        //         "Neue Funktion: ...",
        //         "Verbesserung: ...",
        //     ]
        // ),
    ]

    static var latestVersion: String? {
        all.first?.id
    }

}
