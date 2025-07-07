//
//  PaywallView.swift
//  todo
//
//  Created by William Sun on 7/6/25.
//

import Foundation
import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var storeKit: StoreKitManager
    @State var selectedProduct: Product? = nil
    @StateObject private var toastManager = ToastManager()
    
    private func setDefaultProductIfNeeded() {
        if selectedProduct == nil && !storeKit.products.isEmpty {
            selectedProduct = storeKit.products.last
        }
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    HeaderView()
                    
                    FeaturesView()
                    
                    ProductsView(products: storeKit.products, selectedProduct: $selectedProduct)
                    
                    PurchaseButton(selectedProduct: selectedProduct, toastManager: toastManager)
                }
            }
            .scrollIndicators(.hidden)
            .padding(.horizontal, 16)
            .ignoresSafeArea(edges: .top)
            
        }
        .onAppear {
            setDefaultProductIfNeeded()
        }
        .onChange(of: storeKit.products) { _, newProducts in
            setDefaultProductIfNeeded()
        }
        .toast(isVisible: toastManager.isVisible, message: toastManager.message)
    }
}

private struct HeaderView: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Text("taskmaster+")
                    .font(.inter(fontStyle: .title, fontWeight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            
            Text("unlock all features and customizations")
                .font(.inter(fontStyle: .headline))
                .foregroundStyle(.white.opacity(0.8))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 56)
        .padding(.bottom, 24)
        .padding(.horizontal, 24)
        .background(AppColors.accent)
        .clipShape(
            RoundedCorner(corners: [.bottomLeft, .bottomRight], radius: 40)
        )
        .overlay(
            RoundedCorner(corners: [.bottomLeft, .bottomRight], radius: 40)
                .stroke(AppColors.separator, lineWidth: 1)
        )
        .shadow(radius: 3)
    }
}

private struct FeaturesView: View {
    private struct Feature {
        let icon: String
        let title: String
        let description: String
        let color: Color
    }
    
    private let features: [Feature] = [
        .init(icon: "number.square", title: "Unlimited lists", description: "Create as many lists as you need", color: .pink),
        .init(icon: "wand.and.sparkles", title: "Full customization", description: "Unlock all folder icons and colors", color: .green),
        .init(icon: "lock.open", title: "Dark mode", description: "Switch to a beautiful dark theme", color: .purple),
        .init(icon: "heart", title: "Support an indie developer", description: "Get updates, features, and good karma", color: .red),
        .init(icon: "hourglass", title: "... and more!", description: "Your feedback helps shape what’s next", color: .cyan)

    ]
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Here's what you'll get:")
                .font(.inter(fontStyle: .headline, fontWeight: .semibold))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            VStack(spacing: 8) {
                ForEach(features.indices, id: \.self) { idx in
                    FeatureRow(feature: features[idx])
                }
            }
        }
    }
    
    private struct FeatureRow: View {
        let feature: Feature
        
        var body: some View {
            HStack {
                Image(systemName: feature.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(feature.color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(feature.title)
                        .font(.inter(fontStyle: .headline, fontWeight: .semibold))
                        .foregroundStyle(feature.color)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    
                    Text(feature.description)
                        .font(.inter(fontStyle: .caption))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
                
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8)
            .padding(.horizontal, 8)
            .background(feature.color.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(lineWidth: 1)
                    .fill(feature.color)
            )
        }
    }
}

private struct ProductsView: View {
    let products: [Product]
    @Binding var selectedProduct: Product?
    
    var body: some View {
        HStack {
            ForEach(products) { product in
                ProductButton(product: product, selectedProduct: $selectedProduct)
            }
        }
    }
    
    private struct ProductButton: View {
        let product: Product
        @Binding var selectedProduct: Product?

        var body: some View {
            Button {
                selectedProduct = product
                haptic()
            } label: {
                VStack(alignment: .leading, spacing: 8) {
                    // Display short name (e.g. "Weekly")
                    Text(product.displayName
                        .replacingOccurrences(of: "taskmaster+ ", with: "")
                        .capitalized)
                    .font(.inter(fontStyle: .title3, fontWeight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)

                    // Display price per time unit
                    Text(pricePerInterval)
                        .font(.inter(fontStyle: .headline, fontWeight: .semibold))
                        .foregroundStyle(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(product == selectedProduct ? AppColors.accent.opacity(0.4) : AppColors.background)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(lineWidth: 1)
                        .foregroundStyle(product == selectedProduct ? AppColors.accent : AppColors.separator)
                )
            }
        }

        private var pricePerInterval: String {
            guard let unit = product.subscription?.subscriptionPeriod.unit else {
                return product.displayPrice
            }

            let interval: String
            switch unit {
            case .day: interval = "/ day"
            case .week: interval = "/ week"
            case .month: interval = "/ month"
            case .year: interval = "/ year"
            @unknown default: interval = ""
            }

            return product.displayPrice + " " + interval
        }
    }
}

private struct PurchaseButton: View {
    @EnvironmentObject var storeKit: StoreKitManager
    let selectedProduct: Product?
    let toastManager: ToastManager
    @Environment(\.openURL) var openURL

    let termsURL = URL(string: "https://www.notion.so/taskmaster-Terms-Conditions-22767265edb080c0b7cfe1fddc686104")!
    let privacyURL = URL(string: "https://www.notion.so/taskmaster-Privacy-Policy-22767265edb080f69860c67be33eb333")!

    
    var body: some View {
        VStack(spacing: 4) {
            Button {
                haptic()
                _Concurrency.Task {
                    if let product = selectedProduct {
                        let success = await storeKit.purchase(product)
                        
                        if success {
                            toastManager.show(message: "🎉 Subscribed!", duration: 3.0)
                        } else {
                            toastManager.show(message: "Purchase cancelled", duration: 3.0)
                        }
                        
                        haptic()
                    }
                }
            } label: {
                HStack {
                    Text("Continue")
                        .font(.inter(fontStyle: .title3, fontWeight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(lineWidth: 1)
                                .foregroundStyle(AppColors.accent)
                        }
                }
            }
            
            HStack {
                Button("Restore") {
                    _Concurrency.Task {
                        let success = await storeKit.restorePurchases()

                        if success {
                            toastManager.show(message: "✅ Restored purchases", duration: 3.0)
                        } else {
                            toastManager.show(message: "Nothing to restore", duration: 3.0)
                        }
                    }
                }
                
                Spacer()
                
                Button("Terms & Conditions") {
                    openURL(termsURL)
                }
                
                Spacer()
                
                Button("Privacy Policy") {
                    openURL(privacyURL)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .font(.inter(fontStyle: .footnote))
            .foregroundStyle(AppColors.textSecondary)
            .underline()
            
        }
    }
}

//#Preview {
//    PaywallView()
//        .environmentObject(StoreKitManager.shared)
//}
