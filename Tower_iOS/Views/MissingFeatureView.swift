//
//  MissingFeatureView.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2023-04-02.
//
//

import Foundation
import SwiftUI


// MARK: MissingFeatureView

/// A view telling the user about a missing feature.
///
/// This view is shown when a user encounters a place in the apps that isn't finished yet.
///
struct MissingFeatureView: View {

    // MARK: - Properties

    var body: some View {
        NoContentView(
                title: "In Arbeit",
                headline: "Diese Funktion befindet sich noch in der Entwicklung",
                caption: """
                         Sie haben eine Funktion aufgerufen, an der wir noch arbeiten.  Bitte versuchen Sie es zu \
                         einem späteren Zeitpunkt erneut.
                         """)
    }

}


// MARK: MissingFeatureView_Previews

class MissingFeatureView_Previews: PreviewProvider {

    // MARK: - Static properties

    static var previews: some View {
        MissingFeatureView()
    }

}
