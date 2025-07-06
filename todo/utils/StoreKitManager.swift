//
//  StoreKitManager.swift
//  todo
//
//  Created by William Sun on 7/6/25.
//

import Foundation
import StoreKit

@MainActor
final class StoreKitManager: ObservableObject {
    @Published var products: [Product]
    @Published var purchasedProductIDs: Set<String> = []
    
    static let shared = StoreKitManager()
    
    private init() {
        
    }
}
