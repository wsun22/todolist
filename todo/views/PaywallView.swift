//
//  PaywallView.swift
//  todo
//
//  Created by William Sun on 7/6/25.
//

import Foundation
import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var storeKit: StoreKitManager
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 36) {
                HeaderView()
                
                FeaturesView()
                
                if storeKit.products.isEmpty {
                    Text("🔄 Loading products...")
                } else {
                    ForEach(storeKit.products, id: \.id) { product in
                        Text(product.displayName)
                    }
                }
                
                Spacer()
                
            }
            .padding(.horizontal, 16)
            .ignoresSafeArea()
        }
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
        .padding(.top, 80)
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
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(feature.color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(feature.title)
                        .font(.inter(fontStyle: .headline, fontWeight: .semibold))
                        .foregroundStyle(feature.color)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    
                    Text(feature.description)
                        .font(.inter(fontStyle: .subheadline))
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

#Preview {
    PaywallView()
        .environmentObject(StoreKitManager.shared)
}
