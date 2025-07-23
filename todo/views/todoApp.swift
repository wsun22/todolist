//
//  todoApp.swift
//  todo
//
//  Created by William Sun on 7/1/25.
//

import SwiftUI

@main
struct todoApp: App {
    @StateObject private var storeKit = StoreKitManager.shared
    @StateObject private var toastManager = ToastManager()
        
    var body: some Scene {
        WindowGroup {
            ContentView(appearance: $appearance)
                .environmentObject(storeKit)
                .environmentObject(toastManager)
                .preferredColorScheme(currentScheme)
        }
    }
    
    // light/dark mode configs
    
    @AppStorage("appearance") private var appearance: String = "system"
    
    private var currentScheme: ColorScheme? {
        if !storeKit.isSubscribed {
            return .light
        }

        switch appearance {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
}
