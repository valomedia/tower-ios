//
//  CallSheet.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2023-04-19.
//
//

import Foundation
import SwiftUI


// MARK: CallSheet

/// The view showing the in-call ui.
///
struct CallSheet: View {

    // MARK: - Properties

    var body: some View {
        VStack {
            Image(uiImage: Asset.Assets.logo.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            Text("Tower anfunken…")
                    .font(.largeTitle)
            Button(role: .destructive, action: dismiss.callAsFunction) {
                Label("Auflegen", systemImage: "phone.down.fill")
            }
                    .buttonStyle(.borderedProminent)
        }
    }

    @Environment(\.dismiss)
    private var dismiss

}


// MARK: CallSheet_Previews

class CallSheet_Previews: PreviewProvider {

    // MARK: - Static properties

    static var previews: some View {
        NavigationView {
            CallSheet()
        }
    }

}