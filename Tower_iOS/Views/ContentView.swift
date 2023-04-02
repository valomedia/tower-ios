//
//  ContentView.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2023-03-06.
//
//

import Foundation
import SwiftUI


// MARK: ContentView

struct ContentView: View {

    // MARK: - Properties

    var body: some View {
        VStack {
            Image(systemName: "globe")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.accentColor)
                    .padding()
            Text("Willkommen bei Tower!")
                    .font(.largeTitle)
            Button {} label: {
                Label("Hilfe erhalten", systemImage: "phone.fill")
            }
                    .buttonStyle(.borderedProminent)
        }
        .padding()
    }

}


// MARK: ContentView_Previews

struct ContentView_Previews: PreviewProvider {

    // MARK: - Static properties

    static var previews: some View {
        ContentView()
    }

}
