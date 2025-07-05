//
//  ContentView.swift
//  todo
//
//  Created by William Sun on 7/1/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var listVM = ListViewModel()
    
    @State var selectedList: List? = nil
    @State var showAddListView: Bool = false
    @State var showListView: Bool = false
    
    @State private var listToDelete: List? = nil
    @State private var showDeleteDialog: Bool = false
        
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
                        ListGridView(
                            lists: listVM.lists,
                            listToDelete: listToDelete,
                            onTap: { list in
                                selectedList = list
                                showListView = true
                            },
                            onLongPress: { list in
                                listToDelete = list
                                showDeleteDialog = true
                            },
                            getCompletedCount: { list in
                                listVM.completedTaskCount(list)
                            },
                            getTotalCount: { list in
                                listVM.taskCount(list)
                            },
                            onTapAddList: {
                                showAddListView = true
                            }
                        )
                    }
                }
                .padding(16)
            }
            .navigationDestination(isPresented: $showAddListView) {
                AddListView(listVM: listVM, showAddListView: $showAddListView)
            }
            .navigationDestination(isPresented: $showListView) {
                if let list = selectedList {
                    ListView(list: list, showListView: $showListView, onTasksChanged: {
                        listVM.refreshCount(for: list)
                    })
                }
            }
            .confirmationDialog(
                "Delete this list?",
                isPresented: $showDeleteDialog,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let list = listToDelete {
                        listVM.deleteList(list)
                        listToDelete = nil
                    }
                }
                Button("Cancel", role: .cancel) {
                    listToDelete = nil
                }
            }
        }

    }
}

struct ListGridView: View {
    let lists: [List]
    let listToDelete: List?
    let onTap: (List) -> Void
    let onLongPress: (List) -> Void
    let getCompletedCount: (List) -> Int
    let getTotalCount: (List) -> Int
    let onTapAddList: () -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(lists) { list in
                let completed = getCompletedCount(list)
                let total = getTotalCount(list)

                ZStack {
                    ListCardView(list: list, completed: completed, total: total)

                    if listToDelete?.id == list.id {
                        Color.red.opacity(0.6)
                            .cornerRadius(20)
                            .overlay(
                                Image(systemName: "trash")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .transition(.opacity)
                            .animation(.easeInOut, value: listToDelete)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { onTap(list) }
                .onLongPressGesture { onLongPress(list) }
            }

            AddListCardView()
                .onTapGesture {
                    onTapAddList()
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
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(hex: list.color) ?? .gray)
                
                Spacer()
                
                Text(total == 0 ? "No tasks" : "\(completed)/\(total)")
                    .font(.inter(fontStyle: total == 0? .body : .title2, fontWeight: .semibold))
                    .foregroundStyle(Color(hex: list.color) ?? .gray)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .background(
                        Capsule()
                            .fill((Color(hex: list.color) ?? .gray).opacity(0.15))
                    )
            }
            
            Text(list.name)
                .font(.inter(fontStyle: .headline, fontWeight: .semibold))
                .foregroundStyle(Color(hex: list.color) ?? .gray)
                .lineLimit(1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        .background(RoundedRectangle(cornerRadius: 20)
            .fill((Color(hex: list.color) ?? .gray).opacity(0.25)))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.separator, lineWidth: 0.75)
        )
    }
}

private struct AddListCardView: View {
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
        .frame(maxWidth: .infinity, minHeight: 110, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.backgroundSecondary)
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.separator, lineWidth: 0.75)
        )
    }
}

#Preview {
    let previewVM = ListViewModel()
    previewVM.lists = [
        List(name: "Groceries", color: "#7A5FFF", icon: "cart"),
        List(name: "Work", color: "#01C8EE", icon: "briefcase"),
        List(name: "Fitness", color: "#FFCC00", icon: "heart.fill")
    ]
    return ContentView(listVM: previewVM)
}
