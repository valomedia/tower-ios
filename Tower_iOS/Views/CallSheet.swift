//
//  CallSheet.swift
//  Tower_iOS
//
//  Created by Jean-Pierre Höhmann on 2023-04-19.
//
//

import Foundation
import SwiftUI
import AmazonChimeSDK


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
            Text(controller.state.description)
                    .font(.largeTitle)
            Button(role: .destructive, action: controller.end) {
                Label("Auflegen", systemImage: "phone.down.fill")
            }
                    .buttonStyle(.borderedProminent)
        }
                .onAppear {
                    Task { @MainActor in
                        controller.onCallEnd = { [self] (_: MeetingSessionStatus) in
                            dismiss()

                            Task {
                                do {
                                    // An error here just means something went wrong when ending the call, which we'll
                                    // just ignore for now.
                                    try await TowerApi.end()
                                }
                            }
                        }
                        do {
                            try await controller.join(configuration: TowerApi.join())
                        } catch {
                            env.errorWrapper = ErrorWrapper(error: error, guidance: "Bitte versuche es später erneut")
                        }
                    }
                }
    }

    @StateObject private var controller = CallController()

    @Environment(\.dismiss)
    private var dismiss

    @EnvironmentObject private var env: TowerEnvironment

}


// MARK: CallSheet_Previews

class CallSheet_Previews: PreviewProvider {

    // MARK: - Static properties

    static var previews: some View {
        NavigationView {
            CallSheet()
                    .environmentObject(env)
        }
    }

}