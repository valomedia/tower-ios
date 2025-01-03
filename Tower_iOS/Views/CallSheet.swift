//
//  CallSheet.swift
//  tower-ios
//
//  Created by Jean-Pierre Höhmann on 2023-04-19.
//  Copyright (c) 2023-2025 valo.media GmbH. All rights reserved.
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
                    .accessibility(hidden: true)
            Text(controller.sessionState.localizedDescription)
                    .font(.largeTitle)
                    .accessibility(hidden: true)
            Button(role: .destructive, action: controller.endSession, label: {
                Label("Auflegen", systemImage: "phone.down.fill")
            })
                    .buttonStyle(.borderedProminent)
        }
                .dynamicTypeSize(...DynamicTypeSize.accessibility4)
                .onAppear {
                    UIApplication.shared.isIdleTimerDisabled = true
                    controller.startSession(
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
