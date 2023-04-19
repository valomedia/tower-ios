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
            Image(uiImage: Asset.Assets.logo.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.accentColor)
                    .padding()
            Text("Willkommen bei Tower!")
                    .font(.largeTitle)
            Button {
                isPresentingCallSheet = true
            } label: {
                Label("Hilfe erhalten", systemImage: "phone.fill")
            }
                    .buttonStyle(.borderedProminent)
        }
                .padding()
                .sheet(item: $env.errorWrapper) { errorWrapper in
                    ErrorView(errorWrapper: errorWrapper)
                }
                .sheet(isPresented: $isPresentingCallSheet) {
                    NavigationView {
                        CallSheet()
                                .toolbar {
                                    ToolbarItem(placement: .navigationBarTrailing) {
                                        Button(role: .destructive) {
                                            isPresentingCallSheet = false
                                        } label: {
                                            Label("Auflegen", systemImage: "phone.down.fill")
                                        }
                                                .buttonStyle(.borderedProminent)
                                    }
                                }
                    }
                }
    }

    @StateObject private var env = TowerEnvironment()

    @State private var isPresentingCallSheet = false

}


// MARK: ContentView_Previews

class ContentView_Previews: PreviewProvider {

    // MARK: - Static properties

    static var previews: some View {
        ContentView()
    }

}
