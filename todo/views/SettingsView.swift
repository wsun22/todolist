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
            
        }
    }
}
