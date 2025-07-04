//
//  AppConfigs.swift
//  todo
//
//  Created by William Sun on 7/4/25.
//

import Foundation
import SwiftUI

enum AppColors {
    static let background = Color(red: 0.90, green: 0.97, blue: 0.90) // soft mint green
    static let backgroundSecondary = Color.black.opacity(0.05)
    static let accent = Color(red: 122/255, green: 95/255, blue: 255/255) // soft purple
    static let textPrimary = Color.white
    static let textSecondary = Color.black.opacity(0.45)
    static let separator = Color.black.opacity(0.1)
    
    static let done = Color.green
    static let pending = Color.orange
}


extension Font {
    static func inter(fontStyle: Font.TextStyle = .body, fontWeight: Weight = .regular) -> Font {
        return Font.custom(CustomFont(weight: fontWeight).rawValue, size: fontStyle.size)
    }
}

enum CustomFont: String {
    case regular = "Inter18pt-Regular"
    case semibold = "Inter18pt-SemiBold"
    case bold = "Inter18pt-Bold"
    
    init(weight: Font.Weight) {
        switch weight {
        case .regular:
            self = .regular
        case .semibold:
            self = .semibold
        case .bold:
            self = .bold
        default:
            self = .regular
        }
    }
}

extension Font.TextStyle {
    var size: CGFloat {
        switch self {
        case .largeTitle: return 34
        case .title: return 30
        case .title2: return 22
        case .title3: return 20
        case .headline: return 18
        case .body: return 16
        case .callout: return 15
        case .subheadline: return 14
        case .footnote: return 13
        case .caption: return 12
        case .caption2: return 11
        @unknown default: return 8
        }
    }
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
}
