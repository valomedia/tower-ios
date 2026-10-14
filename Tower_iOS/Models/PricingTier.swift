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

import Foundation
import StoreKit
import SwiftUI

// MARK: PricingTier

/// A monthly subscription tier sold through App Store Connect.
enum PricingTier: String, CaseIterable, Identifiable {

    // MARK: - Cases

    /// The smallest monthly minutes package.
    case mini
    /// The default monthly minutes package.
    case basic
    /// The largest monthly minutes package.
    case power

    // MARK: - Properties

    /// The stable identifier used by SwiftUI lists.
    var id: String { rawValue }

    /// The StoreKit product identifier configured in App Store Connect.
    var productID: String {
        "media.valo.towerios.\(rawValue).1month.1"
    }

    /// Number of remote-assistance minutes included each month.
    var includedMinutes: Int {
        switch self {
            case .mini: return 20
            case .basic: return 50
            case .power: return 100
        }
    }

    /// Accent color used for the tier artwork and pricing card outline.
    var accentColor: Color {
        switch self {
            case .mini: return Color(red: 227 / 255, green: 181 / 255, blue: 5 / 255)
            case .basic: return Color(red: 195 / 255, green: 172 / 255, blue: 206 / 255)
            case .power: return Color(red: 18 / 255, green: 172 / 255, blue: 177 / 255)
        }
    }

    /// Local display name used while StoreKit data is unavailable.
    var fallbackDisplayName: String {
        switch self {
            case .mini: return "Mini"
            case .basic: return "Basic"
            case .power: return "Power"
        }
    }

    /// Local description used while StoreKit data is unavailable.
    var fallbackDescription: String {
        "\(includedMinutes) Minuten Fernassistenz pro Monat"
    }

    /// Asset catalog image name for the tier artwork.
    var imageName: String {
        "Subscription\(fallbackDisplayName)"
    }

}

// MARK: - PricingProducts

/// Loads and caches StoreKit products for all pricing tiers.
@MainActor
final class PricingProducts: ObservableObject {

    // MARK: - Properties

    /// Products returned by StoreKit, keyed by App Store Connect product identifier.
    @Published private(set) var products: [String: Product] = [:]
    /// Localized message describing a failed or partial product load.
    @Published private(set) var errorMessage: String?
    /// Indicates that at least one product lookup has completed.
    @Published private(set) var hasLoaded = false
    /// Indicates that a product lookup is currently in progress.
    @Published private(set) var isLoading = false

    // MARK: - Methods

    /// Loads products from StoreKit unless a successful lookup already completed.
    func load() async {
        guard !isLoading else { return }
        guard !hasLoaded || errorMessage != nil else { return }

        isLoading = true
        defer {
            isLoading = false
            hasLoaded = true
        }

        do {
            let products = try await Product.products(for: PricingTier.allCases.map(\.productID))
            self.products = Dictionary(uniqueKeysWithValues: products.map { ($0.id, $0) })
            errorMessage = products.count == PricingTier.allCases.count
                ? nil
                : "Einige App Store Preise sind gerade nicht verfügbar."
        }
        catch {
            errorMessage = "Die Preise konnten gerade nicht geladen werden. Bitte versuche es später erneut."
        }
    }

    /// Returns the StoreKit product for a pricing tier when it is available.
    func product(for tier: PricingTier) -> Product? {
        products[tier.productID]
    }

}
