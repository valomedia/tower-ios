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
    let items: [AttributedString]

}

// MARK: WhatsNewEntry constants

extension WhatsNewEntry {

    // Add new entries at the top.
    static let all: [WhatsNewEntry] = [
        WhatsNewEntry(
            id: "1.3.0",
            version: "Version 1.3.0",
            title: "Was ist neu",
            items: [
                try! AttributedString(markdown: "Neues, übersichtlicheres Menü für eine einfachere Bedienung."),
                try! AttributedString(markdown: "Das Benutzerprofil lässt sich jetzt einfacher bearbeiten."),
                try! AttributedString(markdown: "Unter Was gibt's Neues sind alle Änderungen der App auf einen Blick zu finden."),
                try! AttributedString(markdown: "**Wichtig:** Der Fernassistenzservice wird ab dem 1. Juli kostenpflichtig."),
            ]
        ),
        WhatsNewEntry(
            id: "1.2.1",
            version: "Version 1.2.1",
            title: "Was ist neu",
            items: [
                try! AttributedString(markdown: "Der Kontaktbildschirm ist jetzt noch barrierefreier."),
            ]
        ),
        WhatsNewEntry(
            id: "1.2.0",
            version: "Version 1.2.0",
            title: "Was ist neu",
            items: [
                try! AttributedString(markdown: "Termine können jetzt auch außerhalb der Öffnungszeiten vereinbart werden."),
                try! AttributedString(markdown: "Die Angabe der E-Mail-Adresse ist nun verpflichtend."),
                try! AttributedString(markdown: "VoiceOver-Ansagen sind jetzt immer gut hörbar."),
                try! AttributedString(markdown: "Eingehende Anrufe während eines Telefonats verursachen keine Audioprobleme mehr."),
            ]
        ),
        WhatsNewEntry(
            id: "1.1.0",
            version: "Version 1.1.0",
            title: "Was ist neu",
            items: [
                try! AttributedString(markdown: "Fotos werden jetzt schneller und zuverlässiger an die Assistent:innen übertragen."),
                try! AttributedString(markdown: "Assistent:innen erhalten Fotos in höherer Auflösung."),
                try! AttributedString(markdown: "Das Vorschaubild zeigt jetzt exakt denselben Bildausschnitt wie die Assistent:in."),
                try! AttributedString(markdown: "Über die neue Kontaktseite sind unsere E-Mail-Adresse und Telefonnummer erreichbar."),
                try! AttributedString(markdown: "Ein Signalton zeigt an, wenn die Assistent:in zwischen den Kameras wechselt."),
            ]
        ),
        WhatsNewEntry(
            id: "1.0.1",
            version: "Version 1.0.1",
            title: "Was ist neu",
            items: [
                try! AttributedString(markdown: "Statusmeldungen und Knöpfe sind jetzt verständlicher beschriftet."),
                try! AttributedString(markdown: "Die Autokorrektur ist bei der Eingabe der E-Mail-Adresse nicht mehr aktiv."),
                try! AttributedString(markdown: "Knöpfe sind im Dunkelmodus mit hohem Kontrast besser lesbar."),
            ]
        ),
    ]

    static var latestVersion: String? {
        all.first?.id
    }

}
