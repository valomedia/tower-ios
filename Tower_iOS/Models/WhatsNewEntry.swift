//
//  WhatsNewEntry.swift
//  Tower_iOS
//
//  Created by Arne Engelland on 2026-05-20.
//  Copyright © 2026 valo.media GmbH. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: WhatsNewEntry

struct WhatsNewEntry: Identifiable {
    static let all: [WhatsNewEntry] = [
        WhatsNewEntry(
            id: "v1.3.0",
            version: "Version 1.3.0",
            title: "Was gibt's Neues in Tower Fernassistenz?",
            body: """
                  In dieser Version haben wir Tower Fernassistenz an mehreren Stellen übersichtlicher und \
                  verständlicher gemacht, damit du noch schneller findest, was du brauchst.

                  Das Menü wurde überarbeitet und ist jetzt klarer strukturiert, sodass du wichtige Funktionen \
                  einfacher erreichst. Die Bearbeitung deines Benutzerprofils ist unkomplizierter geworden, damit du \
                  Einstellungen und persönliche Daten mit wenigen Schritten anpassen kannst. Neu in der App ist dieser \
                  Bildschirm „Was gibt's Neues“, auf dem wir dir bei jedem Update kurz und verständlich erklären, was \
                  sich geändert hat.

                  **Wichtige Info**: Der Fernassistenzservice wird ab dem 1. Juli kostenpflichtig. Bis dahin kannst du \
                  den Dienst wie gewohnt nutzen. Zu den Preisen und Konditionen informieren wir dich über unsere \
                  üblichen Kanäle und natürlich auch in der App.
                  """
        ),
        WhatsNewEntry(
            id: "v1.2.1",
            version: "Version 1.2.1",
            title: "Was gibt's Neues in Tower Fernassistenz?",
            body: """
                  Der Kontaktbildschirm ist jetzt noch barrierefreier.
                  """
        ),
        WhatsNewEntry(
            id: "v1.2.0",
            version: "Version 1.2.0",
            title: "Was gibt's Neues in Tower Fernassistenz?",
            body: """
                  Neue Funktionen:

                    • Außerhalb der Öffnungszeiten können Termine vereinbart werden.
                    • Die Angabe der E-Mail-Adresse ist verpflichtend.

                  Behobene Probleme:

                    • VoiceOver-Ansagen sind jetzt immer gut zu hören.
                    • Eingehende Anrufe während des Telefonats führen nicht mehr zu Audioproblemen.
                  """
        ),
        WhatsNewEntry(
            id: "v1.1.0",
            version: "Version 1.1.0",
            title: "Was gibt's Neues in Tower Fernassistenz?",
            body: """
                  • Das Versenden von Fotos an die Assistent:innen ist jetzt schneller und zuverlässiger.
                  • Die Fotos, die die Assistent:innen erhalten sind höher aufgelöst.
                  • Das Vorschaubild zeigt genau denselben Bildausschnitt, den auch die Assistent:in sieht.
                  • Es gibt eine Kontaktseite, auf der unsere E-Mail-Adresse und Telefonnummer zu finden sind.
                  • Wenn die Assistent:in zwischen den Kameras wechselt, wird das durch einen Ton signalisiert.
                  """
        ),
        WhatsNewEntry(
            id: "v1.0.1",
            version: "Version 1.0.1",
            title: "Was gibt's Neues in Tower Fernassistenz?",
            body: """
                  • Einige Statusmeldungen und Knöpfe sind verständlicher beschriftet.
                  • Autokorrektur ist beim Eingeben der E-Mail-Adresse nicht mehr aktiv.
                  • Knöpfe sind im Dunkelmodus mit hohem Kontrast besser lesbar.
                  """
        ),
    ]
    static var latestVersion: String? {
        all.first?.id
    }


    // MARK: - Properties

    let id: String
    let version: LocalizedStringKey
    let title: LocalizedStringKey
    let body: LocalizedStringKey


}

