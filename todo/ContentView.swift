//
//  ContentView.swift
//  todo
//
//  Created by William Sun on 7/1/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var listVM = ListViewModel()
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(listVM.lists) { list in
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
