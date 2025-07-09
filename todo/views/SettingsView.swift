//
//  SettingsView.swift
//  todo
//
//  Created by William Sun on 7/9/25.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var storeKit: StoreKitManager
    @EnvironmentObject var toast: ToastManager
    
    @Binding var appearance: String

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    Text("Settings")
                        .font(.inter(fontStyle: .title3, fontWeight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(.top, 40)

                    // MARK: Appearance section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Appearance")
                            .font(.inter(fontStyle: .headline, fontWeight: .semibold))
                            .foregroundStyle(AppColors.textSecondary)

                        ZStack {
                            // Actual Picker
                            Picker("Appearance", selection: $appearance) {
                                Text("Light").tag("light")
                                    .font(.inter(fontStyle: .subheadline))
                                Text("Dark").tag("dark")
                                    .font(.inter(fontStyle: .subheadline))
                            }
                            .pickerStyle(.segmented)
                            .tint(AppColors.accent)

                            // Transparent tap blocker if not subscribed
                            if !storeKit.isSubscribed {
                                Color.black.opacity(0.001) // invisible, but catches taps
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .onTapGesture {
                                        haptic()
                                        toast.show(message: "Unlock dark mode with taskmaster+")
                                    }
                            }
                        }
                    }
                    .padding()
                    .background(AppColors.backgroundSecondary)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColors.separator, lineWidth: 1)
                    )
                }
                .padding(.horizontal, 24)
            }
        }
        .toast(isVisible: toast.isVisible, message: toast.message)
    }
}
