//
//  ContentView.swift
//  todo
//
//  Created by William Sun on 7/1/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var listVM = ListViewModel()
    
    @State var isAddingList: Bool = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(listVM.lists) { list in
                                let completed = listVM.completedTaskCount(list)
                                let total = listVM.taskCount(list)
                                Button {
                                    print("list presed")
                                } label: {
                                    ListCardView(list: list, completed: completed, total: total)
                                }
                            }
                            
                            Button {
                                isAddingList = true
                                print("add button pressed. isAddingList: \(isAddingList)")
                            } label: {
                                AddListCardView()
                            }
                        }
                    }
                }
                .padding(16)

            }
            .navigationDestination(isPresented: $isAddingList) {
                AddListView(listVM: listVM, isPresented: $isAddingList)
            }
        }

    }
}

struct ListCardView: View {
    let list: List
    let completed: Int
    let total: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: list.icon)
                    .font(.inter(fontStyle: .headline, fontWeight: .semibold))
                    .foregroundStyle(Color(hex: list.color) ?? .gray)
                
                Spacer()
                
                Text("\(completed)/\(total)")
                    .font(.inter(fontStyle: .title2, fontWeight: .bold))
                    .foregroundStyle(Color(hex: list.color) ?? .gray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            
            Text(list.name)
                .font(.inter(fontStyle: .headline, fontWeight: .semibold))
                .foregroundStyle(Color(hex: list.color) ?? .gray)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        .background(RoundedRectangle(cornerRadius: 20)
            .fill((Color(hex: list.color) ?? .gray).opacity(0.15)))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct AddListCardView: View {
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(AppColors.textSecondary.opacity(0.2))

                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 120, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.backgroundSecondary)
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
//
//#Preview {
//    let previewVM = ListViewModel()
//    previewVM.lists = [
//        List(name: "Groceries", color: "#7A5FFF", image: "cart"),
//        List(name: "Work", color: "#01C8EE", image: "briefcase"),
//        List(name: "Fitness", color: "#FFCC00", image: "heart.fill")
//    ]
//    return ContentView(listVM: previewVM)
//}
