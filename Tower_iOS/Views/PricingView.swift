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

// MARK: PricingViewLayout

private enum PricingViewLayout {
    static let contentSpacing: CGFloat = 24
    static let tierSpacing: CGFloat = 16
    static let infoCardCornerRadius: CGFloat = 16
}

// MARK: - PricingView

/// Displays the subscription tiers and StoreKit pricing details.
struct PricingView<Header: View, Footer: View>: View {

    // MARK: - Properties

    let header: Header
    let footer: Footer

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PricingViewLayout.contentSpacing) {
                header
                freeMinutes
                pricingTiers
                guarantee
                footer
            }
            .padding()
        }
        .navigationTitle("Preise")
        .navigationBarTitleDisplayMode(.inline)
        .dynamicTypeSize(...DynamicTypeSize.accessibility4)
        .task { await pricingProducts.load() }
    }

    @StateObject private var pricingProducts = PricingProducts()

    init(
        @ViewBuilder header: () -> Header,
        @ViewBuilder footer: () -> Footer
    ) {
        self.header = header()
        self.footer = footer()
    }

    private var freeMinutes: some View {
        Label("5 Freiminuten jeden Monat – auch ohne Abo", systemImage: "gift")
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: PricingViewLayout.infoCardCornerRadius))
    }

    private var pricingTiers: some View {
        VStack(spacing: PricingViewLayout.tierSpacing) {
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
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: PricingViewLayout.infoCardCornerRadius))
    }

}

// MARK: - PricingTierView

private struct PricingTierView: View {

    // MARK: - Types

    private enum Layout {
        static let artworkSize: CGFloat = 72
        static let cardCornerRadius: CGFloat = 18
        static let cardBorderWidth: CGFloat = 3
        static let cardSpacing: CGFloat = 16
        static let textSpacing: CGFloat = 6
        static let borderCircleWidth: CGFloat = 1
    }

    // MARK: - Properties

    let tier: PricingTier
    let product: Product?
    let hasLoadedProducts: Bool

    var body: some View {
        HStack(alignment: .top, spacing: Layout.cardSpacing) {
            Image(tier.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: Layout.artworkSize, height: Layout.artworkSize)
                .clipShape(Circle())
                .overlay(Circle().stroke(.quaternary, lineWidth: Layout.borderCircleWidth))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: Layout.cardSpacing) {
                VStack(alignment: .leading, spacing: Layout.textSpacing) {
                    Text(displayName)
                        .font(.title3.bold())
                    Text(description)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: Layout.textSpacing) {
                    if let introductoryOfferText {
                        Text(introductoryOfferText)
                            .font(.headline)
                    }

                    Text(priceText)
                        .font(.headline)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: Layout.cardCornerRadius)
                .stroke(tier.accentColor, lineWidth: Layout.cardBorderWidth)
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
            default:
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
