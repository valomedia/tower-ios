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

enum PricingTier: String, CaseIterable, Identifiable {

    // MARK: - Cases

    case mini
    case basic
    case power

    // MARK: - Properties

    var id: String { rawValue }

    var productID: String {
        "media.valo.towerios.\(rawValue).1month.1"
    }

    var includedMinutes: Int {
        switch self {
            case .mini: return 20
            case .basic: return 50
            case .power: return 100
        }
    }

    var accentColor: Color {
        switch self {
            case .mini: return Color(red: 227 / 255, green: 181 / 255, blue: 5 / 255)
            case .basic: return Color(red: 195 / 255, green: 172 / 255, blue: 206 / 255)
            case .power: return Color(red: 18 / 255, green: 172 / 255, blue: 177 / 255)
        }
    }

    var fallbackDisplayName: String {
        switch self {
            case .mini: return "Mini"
            case .basic: return "Basic"
            case .power: return "Power"
        }
    }

    var fallbackDescription: String {
        "\(includedMinutes) Minuten Fernassistenz pro Monat"
    }

    var imageName: String {
        "Subscription\(fallbackDisplayName)"
    }

}

// MARK: - PricingProducts

@MainActor
final class PricingProducts: ObservableObject {

    // MARK: - Properties

    @Published private(set) var products: [String: Product] = [:]
    @Published private(set) var errorMessage: String?
    @Published private(set) var hasLoaded = false
    @Published private(set) var isLoading = false

    // MARK: - Methods

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

    func product(for tier: PricingTier) -> Product? {
        products[tier.productID]
    }

}
