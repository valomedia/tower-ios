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
                    .accessibility(hidden: true)
            Text(controller.state.description)
                    .font(.largeTitle)
                    .if(controller.state != .connected) {
                        $0.accessibility(addTraits: .updatesFrequently)
                    }
            Button(role: .destructive) {
                Task {
                    do {
                        try await TowerApi.end(session: controller.session!)
                    } catch {
                        // Something went wrong ending the call on the server. We'll just have to pretend the call
                        // ended and hope the other side will notice we are gone at some point.
                        controller.videoSessionDidStopWithStatus(sessionStatus: MeetingSessionStatus(statusCode: .audioCallEnded))
                    }
                }
            } label: {
                Label("Auflegen", systemImage: "phone.down.fill")
            }
                    .buttonStyle(.borderedProminent)
        }
                .dynamicTypeSize(...DynamicTypeSize.accessibility4)
                .onAppear {
                    Task { @MainActor in
                        controller.onCallEnd = { [self] (_: MeetingSessionStatus) in dismiss() }
                        do {
                            try await controller.join(configuration: TowerApi.start())
                        } catch {
                            dismiss();
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
