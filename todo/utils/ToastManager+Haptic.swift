//
//  ToastManager.swift
//  todo
//
//  Created by William Sun on 7/5/25.
//

import Foundation
import SwiftUI

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.inter(fontStyle: .callout, fontWeight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.85))
            .cornerRadius(12)
            .shadow(radius: 5)
            .transition(.move(edge: .top).combined(with: .opacity))
    }
}

final class ToastManager: ObservableObject {
    @Published var message: String = ""
    @Published var isVisible: Bool = false

    func show(message: String, duration: Double = 2.0) {
        self.message = message
        withAnimation {
            self.isVisible = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation {
                self.isVisible = false
            }
        }
    }
}

extension View {
    func toast(isVisible: Bool, message: String) -> some View {
        ZStack(alignment: .top) {
            self

            if isVisible {
                ToastView(message: message)
                    .padding(.top, 60)
                    .zIndex(1)
            }
        }
    }
}

enum VibrationWeight {
    case light
    case medium
    case heavy
}

func haptic(weight: VibrationWeight = .light) {
    let style: UIImpactFeedbackGenerator.FeedbackStyle

    switch weight {
    case .light:
        style = .light
    case .medium:
        style = .medium
    case .heavy:
        style = .heavy
    }

    let generator = UIImpactFeedbackGenerator(style: style)
//    generator.prepare() // optional, makes it feel snappier
    generator.impactOccurred()
}
