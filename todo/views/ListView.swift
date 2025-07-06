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
                
                NewTaskView(newTitle: $newTitle, taskVM: taskVM, list: list, toast: toast)
                
                TaskRowView(taskVM: taskVM, list: list, toast: toast)
            }
            .padding(.horizontal, 16)
            .ignoresSafeArea()
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
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
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
        .padding(.top, 80) // not ideal. later, make custom nav buttons?
        .padding(.bottom, 40)
        .padding(.horizontal, 24)
        .background((Color(hex: list.color) ?? .gray).opacity(0.25))
        .clipShape(
            RoundedCorner(corners: [.bottomLeft, .bottomRight], radius: 40)
        )
        .overlay(
            RoundedCorner(corners: [.bottomLeft, .bottomRight], radius: 40)
                .stroke(AppColors.separator, lineWidth: 1)
        )
        .shadow(radius: 3)
    }
}

private struct NewTaskView: View {
    @Binding var newTitle: String
    var taskVM: TaskViewModel
    let list: List
    @ObservedObject var toast: ToastManager
    
    private func submit() {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        taskVM.addTask(to: list, title: trimmed)
        newTitle = ""
        
        toast.show(message: "Task created!")
        haptic()
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppColors.textSecondary.opacity(0.1))
                    .frame(width: 30, height: 30)
                
                Image(systemName: "plus")
                    .font(.system(size: 15))
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.textSecondary)
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
                    .onSubmit {
                        submit()
                    }
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
    //    .padding(.horizontal, 16)
    }
}

private struct TaskRowView: View {
    // this needs to be observed object. why? bc it says "watch the source of truth. if a @Published property changes, you need to know and rerun"
    @ObservedObject var taskVM: TaskViewModel
    @State private var taskToDelete: Task? = nil
    @State private var showDeleteConfirm: Bool = false
    
    let list: List
    
    @ObservedObject var toast: ToastManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(taskVM.tasks) { task in
                    HStack {
                        Image(systemName: task.isComplete ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(Color(hex: list.color) ?? .gray)

                        Text(task.title)
                            .font(.inter(fontStyle: .body))
                            .foregroundStyle(AppColors.textPrimary)
                            .strikethrough(task.isComplete, color: AppColors.textPrimary.opacity(0.8))
                            .opacity(task.isComplete ? 0.8 : 1.0)

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background((Color(hex: list.color) ?? .gray).opacity(0.25))
                    .cornerRadius(16)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            taskVM.toggleTask(task)
                        }
                        haptic()
                    }
                    .onLongPressGesture {
                        taskToDelete = task
                        showDeleteConfirm = true
                        
                        haptic()
                    }
                    .confirmationDialog(
                        "Delete this task?",
                        isPresented: $showDeleteConfirm,
                        titleVisibility: .visible
                    ) {
                        Button("Delete", role: .destructive) {
                            if let task = taskToDelete {
                                taskVM.deleteTask(task)
                                taskToDelete = nil
                                toast.show(message: "Task deleted!")
                                
                                haptic()
                            }
                        }
                        Button("Cancel", role: .cancel) {
                            taskToDelete = nil
                        }
                    }
                }
            }
        }
    }
}

/*
 
 Preview content code below
 
 */

//private struct ListViewPreviewWrapper: View {
//    @State var showListView: Bool = true
//
//    var body: some View {
//        let mockList = List(
//            name: "Groceries",
//            color: "#7A5FFF",
//            icon: "cart"
//        )
//
//        let mockTasks = [
//            Task(listId: mockList.id, title: "Buy milk", isComplete: false, dueAt: nil),
//            Task(listId: mockList.id, title: "Eggs", isComplete: true, dueAt: nil),
//            Task(listId: mockList.id, title: "Bread", isComplete: false, dueAt: nil)
//        ]
//
//        let mockVM = TaskViewModel(for: mockList, mockTasks: mockTasks)
//
//        ListView(list: mockList, showListView: $showListView, taskVM: mockVM)
//    }
//}
//
//
//#Preview {
//    ListViewPreviewWrapper()
//}
