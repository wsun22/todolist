//
//  ListView.swift
//  todo
//
//  Created by William Sun on 7/4/25.
//

import Foundation
import SwiftUI

struct ListView: View {
    let list: List
    @StateObject var taskVM: TaskViewModel
    @Binding var showListView: Bool
    
    init(list: List, showListView: Binding<Bool>) {
        self.list = list
        // _ needed when initializing Property wrapped properties
        self._showListView = showListView
        self._taskVM = StateObject(wrappedValue: TaskViewModel(for: list))
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack {
                Text(list.name)
                    .font(.inter(fontStyle: .largeTitle, fontWeight: .semibold))
                    .foregroundStyle(.black)
            }
        }
    }
}

//#Preview {
//    ListView()
//}
