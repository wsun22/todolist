//
//  ContentView.swift
//  todo
//
//  Created by William Sun on 7/1/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var todoItemsVM: TodoItemViewModel
    
    @State private var selectedFilter: FilterType = .all
    
    var body: some View {
        ZStack {
            AppColors.backgroundColor.ignoresSafeArea()
            
            VStack {
                HeroHeader()
                
                VStack(spacing: 24) {
                    StatsCard(todoItemsVM: todoItemsVM)
                    
                    AddTodoCard(todoItemsVM: todoItemsVM)
                    
                    FilterBar(selectedFilter: $selectedFilter)
                    
                    ScrollView {
                        TodoRows(todoItemsVM: todoItemsVM, selectedFilter: selectedFilter)
                    }
                }
                
                .offset(y: -40) // to overlap the header
                Spacer()
                
            }
            .ignoresSafeArea()
        }
    }
    
    private struct HeroHeader: View {
        private enum HeaderColors {
            static let primary = Color.white
            static let secondary = Color.white.opacity(0.7)
            static let tertiary = Color.white.opacity(0.2)
        }
        
        private var todayString: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMMM d"
            return formatter.string(from: Date())
        }
        
        private struct RoundedCorner: Shape {
            var corners: UIRectCorner
            var radius: CGFloat
            
            func path(in rect: CGRect) -> Path {
                let path = UIBezierPath(
                    roundedRect: rect,
                    byRoundingCorners: corners,
                    cornerRadii: CGSize(width: radius, height: radius)
                )
                return Path(path.cgPath)
            }
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(HeaderColors.tertiary)
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "checkmark")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(HeaderColors.primary)
                    }
                    
                    Text("TaskFlow")
                        .font(.title)
                        .bold()
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(HeaderColors.tertiary)
                            .frame(width: 30, height: 30)
                        
                        Image(systemName: "person.fill")
                            .font(.caption)
                            .bold()
                            .foregroundStyle(HeaderColors.primary)
                    }
                }
                
                Text(todayString)
                    .font(.body)
                    .foregroundStyle(HeaderColors.secondary)
                    .fontWeight(.semibold)
                
                Text("Good morning 👋")
                    .font(.title2)
                    .foregroundStyle(HeaderColors.primary)
                    .fontWeight(.semibold)
            }
            .padding(.top, 64)
            .padding(.bottom, 40)
            .padding(.horizontal, 24)
            .background(AppColors.heroGradient)
            .clipShape(
                RoundedCorner(corners: [.bottomLeft, .bottomRight], radius: 40)
            )
            .padding(.horizontal, 16)
        }
    }
    
    private struct StatsCard: View {
        @ObservedObject var todoItemsVM: TodoItemViewModel
        
        private var total: Int { todoItemsVM.todos.count }
        private var complete: Int { todoItemsVM.todos.reduce(0) {
            $1.isComplete ? $0 + 1 : $0} }
        private var pending: Int { total - complete }
        
        var body: some View {
            HStack {
                VStack(spacing: 4) {
                    Text("\(total)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(StatusColors.total)
                    
                    Text("Total")
                        .font(.body)
                        .foregroundStyle(AppColors.textSecondary)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("\(complete)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(StatusColors.done)
                    
                    Text("Done")
                        .font(.body)
                        .foregroundStyle(AppColors.textSecondary)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("\(pending)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(StatusColors.pending)
                    
                    Text("Pending")
                        .font(.body)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            .padding(16)
            .background(AppColors.backgroundColor)
            .cornerRadius(16)
            .shadow(radius: 12)
            .padding(.horizontal, 32)
        }
    }
    
    private struct AddTodoCard: View {
        let todoItemsVM: TodoItemViewModel
        
        @State private var newTask: String = ""
        
        var body: some View {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(AppColors.accent.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "plus")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColors.accent)
                }
                
                ZStack(alignment: .leading) {
                    if newTask.isEmpty {
                        Text("Add a new task...")
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.leading, 4)
                    }

                    TextField("", text: $newTask)
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.leading, 4)
                }
                
                Button {
                    guard !newTask.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    todoItemsVM.addTodo(task: newTask)
                    newTask = ""
                } label: {
                    ZStack {
                        Circle()
                            .fill(AppColors.accent)
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.white)
                    }
                }

            }
            .padding(16)
            .background(AppColors.backgroundTertiary)
            .cornerRadius(16)
            .padding(.horizontal, 32)
        }
    }
    
    private struct FilterBar: View {
        @Binding var selectedFilter: FilterType
        
        var body: some View {
            HStack(spacing: 12) {
                ForEach(FilterType.allCases, id: \.self) { filter in
                    Button {
                        selectedFilter = filter
                    } label: {
                        Text(filter.rawValue)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(
                                filter == selectedFilter ? AppColors.backgroundColor : Color.clear
                            )
                            .foregroundStyle(
                                filter == selectedFilter ? AppColors.accent : AppColors.textSecondary
                            )
                            .cornerRadius(8)
                    }
                }
            }
            .padding(4)
            .background(AppColors.backgroundTertiary)
            .cornerRadius(8)
            .padding(.horizontal, 32)
            
        }
    }
    
    private struct TodoRows: View {
        @ObservedObject var todoItemsVM: TodoItemViewModel
        let selectedFilter: FilterType
        
        private var filteredTodos: [TodoItem] {
            switch selectedFilter {
            case .all:
                return todoItemsVM.todos
            case .done:
                return todoItemsVM.todos.filter { $0.isComplete }
            case .pending:
                return todoItemsVM.todos.filter { !$0.isComplete }
            }
        }

        var body: some View {
            VStack(spacing: 12) {
                ForEach(filteredTodos) { todo in
                    Button {
                        todoItemsVM.toggleTodo(todo)
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .frame(width: 24, height: 24)
                                    .foregroundStyle(todo.isComplete ? StatusColors.done : AppColors.accent)
                                
                                if !todo.isComplete {
                                    Circle()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(.white)
                                } else {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.white)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                            }

                            Text(todo.task)
                                .font(.body)
                                .foregroundStyle(todo.isComplete ? AppColors.textSecondary : AppColors.textPrimary)
                                .strikethrough(todo.isComplete, color: AppColors.textSecondary)

                            Spacer()
                            
                            Circle()
                                .frame(width: 12, height: 12)
                                .foregroundStyle(todo.isComplete ? StatusColors.done : StatusColors.pending)
                        }
                        .padding(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.black.opacity(0.08), lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal, 32)
        }
    }

}

private enum StatusColors {
    static let total = Color.blue
    static let done = Color.green
    static let pending = Color.orange
}

private enum FilterType: String, CaseIterable {
    case all = "All"
    case done = "Done"
    case pending = "Pending"
}

#Preview {
    let previewVM = TodoItemViewModel()
    previewVM.todos = [
        TodoItem(task: "Buy milk", isComplete: false),
        TodoItem(task: "Walk the dog", isComplete: true)
    ]
    return ContentView(todoItemsVM: previewVM)
}
