//
//  WhatsNewEntry.swift
//  Tower_iOS
//
//  Copyright © 2026 valo.media GmbH. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: WhatsNewEntry

/// An entry in the changelog.
///
struct WhatsNewEntry: Identifiable {

    // MARK: - Static properties

    /// Entries for all prior versions.
    ///
    /// This contains the entries for all versions of the app that have been published so far, sorted newest to oldest.
    ///
    static let all: [WhatsNewEntry] = [
        WhatsNewEntry(
            id: "v1.4.0",
            version: "Version 1.4.0",
            title: "Herzlich willkommen in der TOWER Assist App",
            body: """
                  Wenn du diesen Text lesen oder hören kannst, \
                  hat alles geklappt: \
                  Du bist in der richtigen App. \
                  Hier findest du TOWER Assist genauso wie bisher. \
                  Die neue TOWER Assist App sieht fast genauso aus \
                  wie die bisherige TOWER Fernassistenz App. \
                  Das ist so gewollt. \
                  Auch mit VoiceOver fühlt sie sich vertraut an. \
                  Du kannst die TOWER Fernassistenz App jetzt von deinem Handy löschen. \
                  Für TOWER brauchst du ab jetzt nur noch die TOWER Assist App. \
                  Wenn du unsicher bist oder Fragen hast, \
                  ruf uns einfach an. \
                  Wir helfen dir gern.
                  """
        ),
        WhatsNewEntry(
            id: "v1.3.1",
            version: "Version 1.3.1",
            title: "Wir sind umgezogen!",
            body: """
                  Bitte installiere die neue TOWER Assist App, \
                  damit du unsere Assistenz weiterhin wie gewohnt nutzen kannst. \
                  Die bisherige TOWER Fernassistenz App wird ab jetzt nicht mehr gepflegt \
                  und demnächst abgeschaltet. \
                  Die neue App gehört zur TOWER Assist GmbH und ersetzt die bisherige App. \
                  Alles andere bleibt wie gewohnt.

                  [TOWER Assist App jetzt installieren](https://tower-assist.de/app)
                  """
        ),
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

    /// The latest version we have an entry for.
    ///
    /// This is needed to figure out whether to show the `WhatsNewView`, since there might not be news for every
    /// version.
    ///
    static var latestVersion: String? {
        all.first?.id
    }

    /// Whether there is a new entry the user hasn't seen yet.
    ///
    /// This is true if a new entry has been added since the user installed the app that the user hasn't seen yet.
    ///
    static var isUnread: Bool {
        guard let latestVersion = WhatsNewEntry.latestVersion else { return false }
        return UserDefaults.standard.string(forKey: "latest_seen_whats_new_version") != latestVersion
    }

    // MARK: - Static methods

    /// Mark the current entry as seen.
    ///
    /// This can be used to mark the newest entry as seen, so `isUnread()` becomes false.
    ///
    static func markAsSeen() {
        guard let latestVersion = WhatsNewEntry.latestVersion else { return }
        UserDefaults.standard.set(latestVersion, forKey: "latest_seen_whats_new_version")
    }

    // MARK: - Properties

    /// The string identifying the current version in the code base.
    ///
    /// This is used to keep track of which versions we have already seen.
    ///
    let id: String

    /// Human readable version name.
    ///
    let version: LocalizedStringKey

    /// Title for the current update.
    ///
    let title: LocalizedStringKey

    /// Body text with the actual changelog.
    ///
    let body: LocalizedStringKey

}

