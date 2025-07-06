//
//  StoreKitManager.swift
//  todo
//
//  Created by William Sun on 7/6/25.
//

import Foundation
import StoreKit

private enum TaskmasterProduct: String, CaseIterable {
    case weekly = "taskmaster_weekly"
    case yearly = "taskmaster_yearly"
}

@MainActor
final class StoreKitManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isSubscribed: Bool = false
    
    static let shared = StoreKitManager()
    
    private init() {
        _Concurrency.Task {
            await loadProducts() // run 1st
            await checkPurchases() // run 2nd
            isSubscribed = checkIsSubscribed() // run 3rd
            listenForTransactions() // run 4th
        }
    }
    
    func checkIsSubscribed() -> Bool {
        return purchasedProductIDs.contains(TaskmasterProduct.weekly.rawValue) ||
               purchasedProductIDs.contains(TaskmasterProduct.yearly.rawValue)
    }
    
    func loadProducts() async {
        let ids: Set<String> = Set(TaskmasterProduct.allCases.map { $0.rawValue })
        print(ids)

        do {
            let storeProducts = try await Product.products(for: ids)
            self.products = storeProducts.sorted(by: { $0.price < $1.price })
            print(products)
        } catch {
            print("❌ [StoreKit] Failed to load products: \(error)")
        }
    }

    func checkPurchases() async {
        var owned: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            owned.insert(transaction.productID)
        }
        
        self.purchasedProductIDs = owned
    }
    
    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                guard case .verified(let transaction) = verification else {
                    print("❌ Purchase failed: unverified transaction")
                    return false
                }

                purchasedProductIDs.insert(transaction.productID)
                print("✅ Purchase success: \(transaction.productID)")
                await transaction.finish()
                return true

            case .userCancelled:
                print("⚠️ Purchase cancelled")
                return false

            case .pending:
                print("⏳ Purchase pending")
                return false

            @unknown default:
                print("❌ Unknown purchase result")
                return false
            }
        } catch {
            print("❌ Purchase error: \(error)")
            return false
        }
    }
    
    func restorePurchases() async -> Bool {
        var restored: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            restored.insert(transaction.productID)
        }
        
        self.purchasedProductIDs = restored
        print("✅ Restored purchases: \(restored)")
        return true
        
    }
    
    func listenForTransactions() {
        _Concurrency.Task {
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }
 
                self.purchasedProductIDs.insert(transaction.productID)
                print("📦 Received transaction update: \(transaction.productID)")
                
                await transaction.finish()
            }
        }
    }
}
