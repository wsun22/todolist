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
    let onTasksChanged: () -> Void
    @ObservedObject var toast: ToastManager
    
    @State var newTitle: String = ""
    @State var showMoreView: Bool = false
    @State var dueDate: Date? = nil
    
    init(list: List, showListView: Binding<Bool>, onTasksChanged: @escaping () -> Void, toast: ToastManager) {
        // 1. Assign plain values
        self.list = list
        self._showListView = showListView
        self.onTasksChanged = onTasksChanged
        self.toast = toast

        // 2. Now it's safe to use `onTasksChanged` and `self` to create vm
        let vm = TaskViewModel(for: list)
        vm.onTasksChanged = onTasksChanged
        self._taskVM = StateObject(wrappedValue: vm)
    }
    
    // PREVIEW ONLY
//    
//    init(list: List, showListView: Binding<Bool>, taskVM: TaskViewModel) {
//        self.list = list
//        self._showListView = showListView
//        self._taskVM = StateObject(wrappedValue: taskVM)
//    }
    
    // END PREVIEW ONLY
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                HeaderView(list: list,
                           completed: taskVM.tasks.filter{ $0.isComplete }.count,
                           total: taskVM.tasks.count,
                           showListView: $showListView)
                
                NewTaskView(newTitle: $newTitle,
                            showMoreView: $showMoreView,
                            dueDate: $dueDate,
                            taskVM: taskVM,
                            list: list,
                            toast: toast)
                
                TaskRowView(taskVM: taskVM, list: list, toast: toast)
            }
            .padding(.horizontal, 16)
            .ignoresSafeArea(edges: .top)
        }
        .toast(isVisible: toast.isVisible, message: toast.message)
        .onDisappear {
            toast.isVisible = false
        }
        .hideKeyboardOnTap()
        .navigationBarBackButtonHidden()
    }
}

private struct HeaderView: View {
    let list: List
    let completed: Int
    let total: Int
    @Binding var showListView: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            CustomBackButton(action: {  showListView = false })
            
            HStack(spacing: 8) {
                Image(systemName: list.icon)
                    .font(.inter(fontStyle: .headline, fontWeight: .semibold))
                    .foregroundStyle(Color(hex: list.color) ?? .gray)
                
                Text(list.name)
                    .font(.inter(fontStyle: .title2, fontWeight: .semibold))
                    .foregroundStyle(Color(hex: list.color) ?? .gray)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
                
                Spacer()
                
                Text(total == 0 ? "No tasks" : "\(completed)/\(total)")
                    .font(.inter(fontStyle: .title2, fontWeight: .semibold))
                    .foregroundStyle(Color(hex: list.color) ?? .gray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill((Color(hex: list.color) ?? .gray).opacity(0.15))
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 56) // not ideal. later, make custom nav buttons?
        .padding(.bottom, 24)
        .padding(.horizontal, 24)
        .background((Color(hex: list.color) ?? .gray).opacity(0.25))
        .clipShape(
            RoundedCorner(corners: [.bottomLeft, .bottomRight], radius: 40)
        )
        .overlay(
            RoundedCorner(corners: [.bottomLeft, .bottomRight], radius: 40)
                .stroke(AppColors.separator, lineWidth: 1)
        )
    }
}

private struct NewTaskView: View {
    @Binding var newTitle: String
    @Binding var showMoreView: Bool
    @Binding var dueDate: Date?
    var taskVM: TaskViewModel
    let list: List
    @ObservedObject var toast: ToastManager

    @EnvironmentObject var storeKit: StoreKitManager

    @State private var showDatePicker = false

    private func submit() {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        taskVM.addTask(to: list, title: trimmed, dueAt: dueDate)
        newTitle = ""
        showMoreView = false
        dueDate = nil
        showDatePicker = false

        toast.show(message: "Task created!")
        haptic()
    }

    private func formattedDate(_ date: Date) -> String {
        let thisYear = Calendar.current.component(.year, from: Date())
        let targetYear = Calendar.current.component(.year, from: date)

        let formatter = DateFormatter()
        formatter.dateFormat = thisYear == targetYear ? "MMMM d" : "MMMM d, yyyy"
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Button {
                    showMoreView.toggle()
                } label: {
                    Image(systemName: showMoreView ? "chevron.up" : "chevron.down")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(AppColors.backgroundSecondary)
                        )
                }
                
                ZStack(alignment: .leading) {
                    if newTitle.isEmpty {
                        Text("Add a new task...")
                            .font(.inter(fontStyle: .body))
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.leading, 4)
                    }
                    
                    TextField("", text: $newTitle)
                        .font(.inter(fontStyle: .body))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.leading, 4)
                        .onSubmit { submit() }
                }
                
                Button {
                    submit()
                } label: {
                    ZStack {
                        Circle()
                            .fill((Color(hex: list.color) ?? .gray).opacity(0.25))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color(hex: list.color) ?? .gray)
                    }
                }
                .disabled(newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.4 : 1)
            }
            .padding(8)
            .background(AppColors.backgroundSecondary)
            .cornerRadius(16)
            
            if showMoreView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Set due date")
                        .font(.inter(fontStyle: .caption, fontWeight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                    
                    HStack {
                        Text(dueDate == nil ? "No due date" : formattedDate(dueDate!))
                            .font(.inter(fontStyle: .body))
                            .foregroundStyle(AppColors.textPrimary)
                        
                        Spacer()
                        
                        if storeKit.isSubscribed {
                            ZStack {
                                DatePicker(
                                    "",
                                    selection: Binding(
                                        get: { dueDate ?? Date() },
                                        set: { newDate in
                                            dueDate = newDate
                                            haptic()
                                        }
                                    ),
                                    displayedComponents: .date
                                )
                                .labelsHidden()
                                .datePickerStyle(.compact)
                                .opacity(0.01)
                                .allowsHitTesting(true)
                                
                                Circle()
                                    .fill(AppColors.textSecondary.opacity(0.15))
                                    .overlay(
                                        Image(systemName: "calendar")
                                            .foregroundStyle(AppColors.textSecondary)
                                    )
                                    .allowsHitTesting(false) // Important!
                            }
                            .frame(width: 32, height: 32)
                            .clipped()
                        } else {
                            Button {
                                toast.show(message: "🔒 Setting due date is a premium feature")
                                haptic()
                            } label: {
                                Image(systemName: "calendar")
                                    .foregroundStyle(AppColors.textSecondary)
                                    .padding(8)
                                    .background(
                                        Circle()
                                            .fill(AppColors.textSecondary.opacity(0.15))
                                    )
                            }
                        }
                    }
                    .padding(12)
                    .background(AppColors.backgroundSecondary)
                    .cornerRadius(10)
                    
                    if dueDate != nil {
                        Button("Clear") {
                            dueDate = nil
                            haptic()
                        }
                        .font(.inter(fontStyle: .caption))
                        .foregroundColor(AppColors.accent)
                    }
                }
                .padding()
                .background(AppColors.backgroundSecondary)
                .cornerRadius(12)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}



private struct TaskRowView: View {
    // this needs to be observed object. why? bc it says "watch the source of truth. if a @Published property changes, you need to know and rerun"
    @ObservedObject var taskVM: TaskViewModel
    @State private var taskToDelete: Task? = nil
    @State private var showDeleteConfirm: Bool = false
    
    let list: List
    
    @ObservedObject var toast: ToastManager
    
    private func formattedDate(_ date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let currentYear = calendar.component(.year, from: Date())
            let targetYear = calendar.component(.year, from: date)

            let formatter = DateFormatter()
            formatter.dateFormat = currentYear == targetYear ? "MMMM d" : "MMMM d, yyyy"
            return formatter.string(from: date)
        }
    }

    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(taskVM.tasks) { task in
                    TaskCardView(
                        task: task,
                        list: list,
                        isSelectedForDelete: taskToDelete?.id == task.id,
                        showTrashOverlay: taskToDelete != nil,
                        onTap: {
                            withAnimation {
                                taskVM.toggleTask(task)
                            }
                            haptic()
                        },
                        onLongPress: {
                            taskToDelete = task
                            showDeleteConfirm = true
                            haptic()
                        },
                        formattedDate: formattedDate
                    )
                }
                .confirmationDialog(
                    "Delete task “\(taskToDelete?.title ?? "")”?",
                    isPresented: $showDeleteConfirm,
                    titleVisibility: .visible
                ) {
                    Button("Delete", role: .destructive) {
                        if let task = taskToDelete {
                            taskVM.deleteTask(task)
                            toast.show(message: "Task deleted!")
                            haptic()
                            taskToDelete = nil
                        }
                    }
                    Button("Cancel", role: .cancel) {
                        taskToDelete = nil
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
    }
    
    private struct TaskCardView: View {
        let task: Task
        let list: List
        let isSelectedForDelete: Bool
        let showTrashOverlay: Bool
        let onTap: () -> Void
        let onLongPress: () -> Void
        let formattedDate: (Date) -> String

        var body: some View {
            ZStack {
                HStack {
                    Image(systemName: task.isComplete ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(Color(hex: list.color) ?? .gray)

                    Text(task.title)
                        .font(.inter(fontStyle: .body))
                        .foregroundStyle(AppColors.textPrimary)
                        .strikethrough(task.isComplete, color: AppColors.textPrimary.opacity(0.8))
                        .opacity(task.isComplete ? 0.8 : 1.0)

                    Spacer()

                    if let dueDate = task.dueAt {
                        Text(formattedDate(dueDate))
                            .font(.inter(fontStyle: .caption))
                            .foregroundStyle(AppColors.textPrimary)
                            .strikethrough(task.isComplete, color: AppColors.textPrimary.opacity(0.8))
                            .opacity(task.isComplete ? 0.8 : 1.0)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background((Color(hex: list.color) ?? .gray).opacity(0.25))
                .cornerRadius(16)
                .contentShape(Rectangle())
                .opacity(isSelectedForDelete || !showTrashOverlay ? 1 : 0.3)
                .onTapGesture { onTap() }
                .onLongPressGesture { onLongPress() }

                if isSelectedForDelete {
                    Color.red.opacity(0.6)
                        .cornerRadius(16)
                        .overlay(
                            Image(systemName: "trash")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .transition(.opacity)
                        .animation(.easeInOut, value: isSelectedForDelete)
                }
            }
        }
    }

}

private struct ListViewPreviewWrapper: View {
    @State var showListView: Bool = true
    @StateObject private var toastManager = ToastManager()

    var body: some View {
        let mockList = List(
            name: "Groceries",
            color: "#7A5FFF",
            icon: "cart",
            idx: 0
        )

        let vm = TaskViewModel(for: mockList)
        vm.tasks = [
            Task(listId: mockList.id, title: "Buy milk", isComplete: false, dueAt: nil, idx: 0),
            Task(listId: mockList.id, title: "Eggs", isComplete: true, dueAt: nil, idx: 1),
            Task(listId: mockList.id, title: "Bread", isComplete: false, dueAt: nil, idx: 2)
        ]

        return ListView(
            list: mockList,
            showListView: $showListView,
            onTasksChanged: {},
            toast: toastManager
        )
    }
}
//
//#Preview {
//    ListViewPreviewWrapper()
//}
