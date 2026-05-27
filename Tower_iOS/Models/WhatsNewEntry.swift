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
    let body: String

    var paragraphs: [AttributedString] {
        body
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { paragraph in
                (try? AttributedString(markdown: paragraph)) ?? AttributedString(paragraph)
            }
    }

}

// MARK: WhatsNewEntry constants

extension WhatsNewEntry {

    // Add new entries at the top.
    static let all: [WhatsNewEntry] = [
        WhatsNewEntry(
            id: "1.3.0",
            version: "Version 1.3.0",
            title: "Was ist neu",
            body: """
                Das Menü ist jetzt übersichtlicher, das Benutzerprofil lässt sich einfacher bearbeiten und unter „Was gibt's Neues" sind ab sofort alle Änderungen der App auf einen Blick zu finden.

                **Wichtig:** Der Fernassistenzservice wird ab dem 1. Juli kostenpflichtig.
                """
        ),
        WhatsNewEntry(
            id: "1.2.1",
            version: "Version 1.2.1",
            title: "Was ist neu",
            body: """
                Der Kontaktbildschirm ist jetzt noch barrierefreier.
                """
        ),
        WhatsNewEntry(
            id: "1.2.0",
            version: "Version 1.2.0",
            title: "Was ist neu",
            body: """
                Termine können jetzt auch außerhalb der Öffnungszeiten vereinbart werden. Außerdem ist die Angabe der E-Mail-Adresse nun verpflichtend, VoiceOver-Ansagen sind immer gut hörbar und eingehende Anrufe während eines Telefonats verursachen keine Audioprobleme mehr.
                """
        ),
        WhatsNewEntry(
            id: "1.1.0",
            version: "Version 1.1.0",
            title: "Was ist neu",
            body: """
                Fotos werden jetzt schneller und zuverlässiger an die Assistent:innen übertragen und kommen dort in höherer Auflösung an. Das Vorschaubild zeigt jetzt exakt denselben Bildausschnitt wie die Assistent:in, über die neue Kontaktseite sind E-Mail-Adresse und Telefonnummer erreichbar und ein Signalton zeigt an, wenn zwischen den Kameras gewechselt wird.
                """
        ),
        WhatsNewEntry(
            id: "1.0.1",
            version: "Version 1.0.1",
            title: "Was ist neu",
            body: """
                Statusmeldungen und Knöpfe sind jetzt verständlicher beschriftet. Die Autokorrektur ist bei der Eingabe der E-Mail-Adresse nicht mehr aktiv und Knöpfe sind im Dunkelmodus mit hohem Kontrast besser lesbar.
                """
        ),
    ]

    static var latestVersion: String? {
        all.first?.id
    }

}
