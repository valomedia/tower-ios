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
                    .accessibility(hidden: true)
            Button(role: .destructive, action: controller.endCall, label: {
                Label("Auflegen", systemImage: "phone.down.fill")
            })
                    .buttonStyle(.borderedProminent)
        }
                .dynamicTypeSize(...DynamicTypeSize.accessibility4)
                .onAppear {
                    UIApplication.shared.isIdleTimerDisabled = true
                    controller.startCall(
                        onCallEnd: { [self] in
                            Task { @MainActor in
                                UIApplication.shared.isIdleTimerDisabled = false
                                dismiss()
                            }
                        },
                        onCallError: { [self] (error: Error) in
                            Task { @MainActor in
                                env.errorWrapper = ErrorWrapper(
                                    error: error,
                                    guidance: "Bitte versuche es später erneut")
                            }
                        }
                    )
                }
                .onChange(of: phase) { phase in
                    if (phase == .background) {
                        controller.pauseVideo()
                    } else {
                        controller.resumeVideo()
                    }
                }
    }

    @StateObject private var controller = CallController()

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.scenePhase)
    private var phase
    
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
