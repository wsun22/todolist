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
    @State private var toastManager = ToastManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(storeKit)
                .environmentObject(toastManager)
        }
    }
}
