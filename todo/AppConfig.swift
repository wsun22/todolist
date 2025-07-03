//
//  AppConfig.swift
//  todo
//
//  Created by William Sun on 7/1/25.
//

import Foundation
import SwiftUI

enum AppColors {
    static let backgroundColor = Color.white
    static let heroGradient = LinearGradient(
        gradient: Gradient(colors: [Color(red: 122/255, green: 95/255, blue: 255/255), // purple
                                    Color(red: 1/255, green: 200/255, blue: 238/255)]), // blue
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let backgroundSecondary = Color(red: 0.96, green: 0.96, blue: 0.96) // off-white
    static let backgroundTertiary = Color.black.opacity(0.05)
    static let textPrimary = Color.black
    static let textSecondary = Color.black.opacity(0.8)
    static let accent = Color(red: 122/255, green: 95/255, blue: 255/255)
}
