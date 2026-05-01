//
//  LaunchOfferStore.swift
//  tower-ios
//
//  Created by Arne Engelland on 2026-04-28.
//  Copyright (c) 2026 valo.media GmbH. All rights reserved.
//

import Foundation
import StoreKit

// MARK: LaunchOfferStore

@MainActor
final class LaunchOfferStore: ObservableObject {

    // MARK: - Nested types

    private static let launchOfferProductIdentifier = "media.valo.towerios.trial.26days.1"

    enum PurchaseState: Equatable {
        case idle
        case pending
    }

    // MARK: - Properties

    @Published private(set) var hasAccess = false

    /// The StoreKit product loaded from the App Store for the configured product identifier.
    @Published private(set) var product: Product?

    @Published private(set) var isLoadingProduct = false

    @Published private(set) var isPurchasing = false

    @Published private(set) var purchaseState: PurchaseState = .idle

    @Published var errorMessage: String?

    private var transactionUpdatesTask: Task<Void, Never>?

    // MARK: - Initializers

    init() {
        transactionUpdatesTask = Task {
            for await result in Transaction.updates {
                do {
                    let transaction = try Self.checkVerified(result)
                    guard transaction.productID == Self.launchOfferProductIdentifier else { continue }
                    await transaction.finish()
                    await refreshAccessState()
                }
                catch {
                    continue
                }
            }
        }

    }

    deinit {
        transactionUpdatesTask?.cancel()
    }

    // MARK: - Methods

    func refresh() async {
        await loadProductIfNeeded()
        await refreshAccessState()
    }

    func refreshAccessState() async {
        hasAccess = await Self.hasActiveAccess()

        // `.pending` is only a transient purchase UI state. If StoreKit still reports no active entitlement after a
        // refresh, allow the user to retry.
        if !hasAccess {
            purchaseState = .idle
        }
    }

    func purchaseLaunchOffer() async {
        purchaseState = .idle
        errorMessage = nil

        await loadProductIfNeeded()

        guard let product else {
            errorMessage = "Die App-Freischaltung konnte nicht aus dem App Store geladen werden."
            return
        }

        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try Self.checkVerified(verification)
                await transaction.finish()
                await refreshAccessState()

            case .pending:
                purchaseState = .pending

            case .userCancelled:
                purchaseState = .idle

            @unknown default:
                errorMessage = "Der Kaufstatus konnte nicht ausgewertet werden."
            }
        }
        catch {
            errorMessage = error.localizedDescription
        }
    }

    func restorePurchases() async {
        errorMessage = nil

        do {
            try await AppStore.sync()
            await refreshAccessState()
        }
        catch {
            errorMessage = error.localizedDescription
        }
    }

    static func hasActiveAccess() async -> Bool {
        let productIdentifier = Self.launchOfferProductIdentifier

        guard !productIdentifier.isEmpty else { return false }

        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }
            guard transaction.productID == productIdentifier else { continue }
            return true
        }

        return false
    }

    // MARK: - Private methods

    private func loadProductIfNeeded() async {
        let productIdentifier = Self.launchOfferProductIdentifier

        guard !productIdentifier.isEmpty else {
            product = nil
            errorMessage = "Bitte hinterlege eine Produkt-ID für die App-Freischaltung."
            return
        }

        guard product == nil else { return }

        isLoadingProduct = true
        defer { isLoadingProduct = false }

        do {
            let products = try await Product.products(for: [productIdentifier])
            product = products.first

            if product == nil {
                errorMessage = """
                    Kein App-Store-Produkt für \(productIdentifier) gefunden. Bitte Produkt-ID prüfen.
                    """
            }
            else {
                errorMessage = nil
            }
        }
        catch {
            product = nil
            errorMessage = error.localizedDescription
        }
    }

    private static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let transaction):
            transaction

        case .unverified:
            throw StoreError.failedVerification
        }
    }

}

// MARK: LaunchOfferStore.StoreError

extension LaunchOfferStore {

    enum StoreError: LocalizedError {
        case failedVerification

        var errorDescription: String? {
            switch self {
            case .failedVerification:
                "Die App-Store-Transaktion konnte nicht verifiziert werden."
            }
        }
    }

}
