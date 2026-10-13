//
// Copyright (c) 2026 valo.media GmbH
// All rights reserved.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import StoreKit
import SwiftUI

// MARK: PricingView

struct PricingView: View {

    // MARK: - Types

    enum PresentationMode {
        case profile
        case trialStarted
    }

    // MARK: - Properties

    let presentationMode: PresentationMode

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                freeMinutes
                pricingTiers
                guarantee
            }
            .padding()
        }
        .navigationTitle("Preise")
        .navigationBarTitleDisplayMode(.inline)
        .dynamicTypeSize(...DynamicTypeSize.accessibility4)
        .task { await pricingProducts.load() }
    }

    @StateObject private var pricingProducts = PricingProducts()

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            if presentationMode == .trialStarted {
                Text("Deine kostenlose Testphase läuft")
                    .font(.title.bold())
                Text("Du bist jetzt auf der 7-tägigen kostenlosen Testphase.")
            }
            else {
                Text("Wähle dein Minutenpaket")
                    .font(.title.bold())
            }
            Text("Alle Abos laufen monatlich und ergänzen dein kostenloses Minutenkontingent.")
                .foregroundStyle(.secondary)
        }
    }

    private var freeMinutes: some View {
        Label("5 Freiminuten jeden Monat – auch ohne Abo", systemImage: "gift")
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var pricingTiers: some View {
        VStack(spacing: 16) {
            if let errorMessage = pricingProducts.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            ForEach(PricingTier.allCases) { tier in
                PricingTierView(
                    tier: tier,
                    product: pricingProducts.product(for: tier),
                    hasLoadedProducts: pricingProducts.hasLoaded
                )
            }
        }
    }

    private var guarantee: some View {
        Label(
            "Erfolgsgarantie: wenn wir gemeinsam nicht erfolgreich waren, werden keine Minuten verbraucht.",
            systemImage: "checkmark.seal"
        )
        .font(.headline)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

}

// MARK: - PricingTierView

private struct PricingTierView: View {

    // MARK: - Properties

    let tier: PricingTier
    let product: Product?
    let hasLoadedProducts: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                Image(tier.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 72, height: 72)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.quaternary, lineWidth: 1))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 6) {
                    Text(displayName)
                        .font(.title3.bold())
                    Text(description)
                        .foregroundStyle(.secondary)
                    Text("\(tier.includedMinutes) Minuten pro Monat")
                        .font(.subheadline.weight(.semibold))
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                if let introductoryOfferText {
                    Text(introductoryOfferText)
                        .font(.headline)
                }

                Text(priceText)
                    .font(.headline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(tier.accentColor, lineWidth: 3)
        )
    }

    private var displayName: String {
        guard let product else { return tier.fallbackDisplayName }
        return product.displayName.isEmpty ? tier.fallbackDisplayName : product.displayName
    }

    private var description: String {
        guard let product else { return tier.fallbackDescription }
        return product.description.isEmpty ? tier.fallbackDescription : product.description
    }

    private var priceText: String {
        guard let product else { return hasLoadedProducts ? "Preis nicht verfügbar" : "Preis wird geladen…" }
        let prefix = introductoryOfferText == nil ? "" : "Danach "
        return "\(prefix)\(product.displayPrice) pro Monat"
    }

    private var introductoryOfferText: String? {
        guard let offer = product?.subscription?.introductoryOffer else { return nil }

        switch offer.paymentMode {
            case .freeTrial:
                return "\(periodText(for: offer)) kostenlos testen"
            case .payAsYouGo:
                return "Einführungspreis: \(offer.displayPrice) für \(periodText(for: offer))"
            case .payUpFront:
                return "Einführungspreis: \(offer.displayPrice) für \(periodText(for: offer))"
            @unknown default:
                return nil
        }
    }

    private func periodText(for offer: Product.SubscriptionOffer) -> String {
        let period = offer.period
        let value = period.value * offer.periodCount
        let unit = switch period.unit {
            case .day: value == 1 ? "Tag" : "Tage"
            case .week: value == 1 ? "Woche" : "Wochen"
            case .month: value == 1 ? "Monat" : "Monate"
            case .year: value == 1 ? "Jahr" : "Jahre"
            @unknown default: "Zeitraum"
        }

        return "\(value) \(unit)"
    }

}

// MARK: - PricingView_Previews

class PricingView_Previews: PreviewProvider {

    // MARK: - Static properties

    static var previews: some View {
        NavigationView {
            PricingView(presentationMode: .trialStarted)
        }
    }

}
