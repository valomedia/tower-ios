//
//  OpeningHoursSheet.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2025-02-18.
//  Copyright (c) 2025 valo.media GmbH. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: OpeningHoursView

/// A view telling the user when the service is available, shown if the user opens the app outside of service hours.
///
struct OpeningHoursSheet: View {

    // MARK: - Static properties

    private let dateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()

    // MARK: - Properties

    /// The opening hours to display to the user.
    ///
    let schedule: [(Date, String?)]

    var body: some View {
        NavigationView {
            NoContentView(
                title: "Wir haben geschlossen",
                headline: "Bitte versuche es zu einem späteren Zeitpunkt erneut",
                caption:
                    """
                    Leider ist der TOWER-Assistenzservice gerade nicht verfügbar. Die Öffnungszeiten für die nächsten \
                    Tage findest du unten. Wenn du einen Termin mit uns ausgemacht hast, kannst du diese Meldung \
                    schließen, und trotzdem einen Anruf starten. 
                    """
            ) {
                ForEach(schedule, id: \.0) { (date, hours) in
                    HStack {
                        switch (date) {
                        case .today: Text("Heute")
                        case .tomorrow: Text("Morgen")
                        default: Text(dateFormatter.string(for: date) ?? "")
                        }
                        Spacer()
                        Text(hours ?? "Geschlossen")
                    }
                }
            }
                .toolbar {
                    Button("Trotzdem anrufen") {
                        dismiss()
                    }
                }
        }
    }

    @Environment(\.dismiss)
    private var dismiss

}

// MARK: OpeningHoursView_Previews

/// Preview for OpeningHoursView
///
class OpeningHoursView_Previews: PreviewProvider {

    // MARK: - Static properties

    static var previews: some View {
        OpeningHoursSheet(schedule: [
            (.today, "08:00-12:00, 13:00-17:00"),
            (.tomorrow, nil),
            (Calendar.current.date(byAdding: .day, value: 1, to: .tomorrow)!, "12:00-16:00")
        ])
    }

}
