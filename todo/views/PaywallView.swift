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
        Text("hi")
    }
}

#Preview {
    PaywallView()
        .environmentObject(StoreKitManager.shared)
}
