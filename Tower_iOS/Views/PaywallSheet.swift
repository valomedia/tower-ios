//
//  PaywallSheet.swift
//  tower-ios
//
//  Created by Arne Engelland on 2026-04-28.
//  Copyright (c) 2026 valo.media GmbH. All rights reserved.
//

import SwiftUI

// MARK: PaywallSheet

struct PaywallSheet: View {

    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Label("Launch-Angebot", systemImage: "sparkles")
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                            Text("nur 3 Monate")
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color(Asset.Assets.accentColor.color).opacity(0.14))
                                .clipShape(Capsule())
                        }

                        Text("Tower Launch 26")
                            .font(.title2.weight(.bold))

                        Text("100 Minuten pro Monat für 26 Euro pro Monat.")
                            .font(.headline)

                        Text(
                            """
                            Starte mit 26 Tagen gratis. Danach zahlst du monatlich.
                            """)
                            .foregroundColor(.secondary)

                        VStack(alignment: .leading, spacing: 10) {
                            offerFact("100 Minuten pro Monat", systemImage: "timer")
                            offerFact("26 Euro pro Monat", systemImage: "eurosign.circle")
                            offerFact("Monatliche Zahlung", systemImage: "calendar")
                            offerFact("26 Tage gratis zum Start", systemImage: "gift")
                        }

                        Text("Preisangaben sind vorläufig und können sich ändern.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }

                if launchOfferStore.isLoadingProduct {
                    Section {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                }
                if let errorMessage = launchOfferStore.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                if launchOfferStore.purchaseState == .pending {
                    Section {
                        Text("Der Kauf ist ausstehend und muss gegebenenfalls noch bestätigt werden.")
                    }
                }

                Section {
                    Button {
                        Task {
                            await launchOfferStore.purchaseLaunchOffer()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if launchOfferStore.isPurchasing {
                                ProgressView()
                                    .progressViewStyle(.circular)
                            }
                            else {
                                Label("26 Tage gratis starten", systemImage: "arrow.right").labelStyle(.trailingIcon)
                            }
                            Spacer()
                        }
                    }
                    .disabled(
                        launchOfferStore.isLoadingProduct
                            || launchOfferStore.isPurchasing
                            || launchOfferStore.purchaseState == .pending
                            || launchOfferStore.hasAccess
                            || launchOfferStore.product == nil)
                    .listRowBackground(Color(Asset.Assets.accentColor.color))
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Käufe wiederherstellen") {
                        Task {
                            await launchOfferStore.restorePurchases()
                        }
                    }
                    .disabled(launchOfferStore.isPurchasing)
                }
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.accessibility4)
        .task {
            await launchOfferStore.refresh()
        }
        .onChange(of: launchOfferStore.hasAccess) { hasAccess in
            guard hasAccess else { return }
            dismiss()
        }
        .onChange(of: scenePhase) { phase in
            guard phase == .active else { return }
            Task {
                await launchOfferStore.refreshAccessState()
            }
        }
    }

    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.scenePhase)
    private var scenePhase

    @EnvironmentObject private var launchOfferStore: LaunchOfferStore

    private func offerFact(_ text: String, systemImage: String) -> some View {
        Label(text, systemImage: systemImage)
            .labelStyle(.leadingIcon)
    }

}

// MARK: PaywallSheet_Previews

class PaywallSheet_Previews: PreviewProvider {

    // MARK: - Static properties

    static var previews: some View {
        VStack {
            EmptyView()
        }
        .sheet(isPresented: $isPresented) {
            PaywallSheet()
                .environmentObject(LaunchOfferStore())
        }
    }

    @State static private var isPresented = true

}
