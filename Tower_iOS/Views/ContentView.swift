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
            Button {
                isPresentingMissingFeatureView = true
            } label: {
                Label("Hilfe erhalten", systemImage: "phone.fill")
            }
                    .buttonStyle(.borderedProminent)
        }
                .padding()
                .sheet(item: $env.errorWrapper) { errorWrapper in
                    ErrorView(errorWrapper: errorWrapper)
                }
                .sheet(isPresented: $isPresentingMissingFeatureView) {
                    NavigationView {
                        MissingFeatureView()
                    }
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button(role: .destructive) {
                                        isPresentingMissingFeatureView = false
                                    } label: {
                                        Label("Auflegen", systemImage: "phone.down.fill")
                                    }
                                            .buttonStyle(.borderedProminent)
                                }
                            }
                }
    }

    @StateObject private var env = TowerEnvironment()

    @State private var isPresentingMissingFeatureView = false

}


// MARK: ContentView_Previews

struct ContentView_Previews: PreviewProvider {

    // MARK: - Static properties

    static var previews: some View {
        ContentView()
    }

}
