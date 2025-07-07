//
//  ContentView.swift
//  todo
//
//  Created by William Sun on 7/1/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var storeKit: StoreKitManager
    @EnvironmentObject var toast: ToastManager
    
    @StateObject var listVM = ListViewModel()
    
    @State var selectedList: List? = nil
    @State var showAddListView: Bool = false
    @State var showListView: Bool = false
    @State var showPaywallView: Bool = false
    @State var didCreateList: Bool = false
//    @State var showSettingsView: Bool = false
    
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
                        HeaderView(showPaywallView: $showPaywallView)
                        
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
                                haptic()
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
                .padding(.horizontal, 16)
                .ignoresSafeArea(edges: .top)
                .scrollIndicators(.hidden)

            }
            .navigationDestination(isPresented: $showAddListView) {
                AddListView(listVM: listVM,
                            showAddListView: $showAddListView,
                            didCreateList: $didCreateList)
            }
            .navigationDestination(isPresented: $showListView) {
                if let list = selectedList {
                    ListView(list: list,
                             showListView: $showListView,
                             onTasksChanged: { listVM.refreshCount(for: list) },
                             toast: toast)
                }
            }
            .sheet(isPresented: $showPaywallView) {
                PaywallView()
            }
//            .sheet(isPresented: $showSettingsView) {
//                SettingsView()
//            }
            .confirmationDialog(
                "Delete this list?",
                isPresented: $showDeleteDialog,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let list = listToDelete {
                        listVM.deleteList(list)
                        toast.show(message: "List deleted!")
                        listToDelete = nil
                        
                        haptic()
                    }
                }
                Button("Cancel", role: .cancel) {
                    listToDelete = nil
                }
            }
            .toast(isVisible: toast.isVisible, message: toast.message)
            .onChange(of: showAddListView) {
                if showAddListView == false && didCreateList {
                    toast.show(message: "List created!")
                    didCreateList = false
                }
            }
        }
    }
}

private struct HeaderView: View {
    @EnvironmentObject var storeKit: StoreKitManager
    @Binding var showPaywallView: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text(storeKit.isSubscribed ? "taskmaster+" : "taskmaster")
                .font(.inter(fontStyle: .title3, fontWeight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            Spacer()
            
            if !storeKit.isSubscribed {
                Button {
                    showPaywallView = true
                } label: {
                    Text("get+")
                        .font(.inter(fontStyle: .callout, fontWeight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 12)
                        .background(AppColors.accent)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(lineWidth: 1)
                                .foregroundStyle(AppColors.separator)
                        )
                        .shadow(radius: 2)
                }
            }
            
//            Button {
//                showSettingsView = true
//            } label: {
//                Image(systemName: "gearshape")
//                    .font(.inter(fontStyle: .callout, fontWeight: .semibold))
//                    .foregroundStyle(.white)
//                    .padding(6)
//                    .background(AppColors.accent.opacity(0.4))
//                    .clipShape(Circle())
//                    .shadow(radius: 2)
//            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
        .padding(.bottom, 24)
        .padding(.horizontal, 24)
        .background(AppColors.accent)
        .clipShape(RoundedCorner(corners: [.bottomLeft, .bottomRight], radius: 40))
    }
}

private struct ListGridView: View {
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
                    .font(.inter(fontStyle: .title2, fontWeight: .semibold))
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
        .frame(maxWidth: .infinity, minHeight: 115, maxHeight: .infinity)
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

struct CustomBackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
                .padding(8)
                .background(
                    Circle()
                        .fill(AppColors.backgroundSecondary)
                )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ContentView()
        .environmentObject(StoreKitManager.shared)
        .environmentObject(ToastManager())
}
