//
//  ListView.swift
//  todo
//
//  Created by William Sun on 7/4/25.
//

import Foundation
import SwiftUI

struct ListView: View {
    @State var list: List
    @StateObject var taskVM: TaskViewModel
    @Binding var showListView: Bool
    
    @State var newTitle: String = ""
    
    init(list: List, showListView: Binding<Bool>) {
        self.list = list
        // _ needed when initializing Property wrapped properties
        self._showListView = showListView
        self._taskVM = StateObject(wrappedValue: TaskViewModel(for: list))
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                HeaderView(list: list,
                           completed: taskVM.tasks.filter{ $0.isComplete }.count,
                           total: taskVM.tasks.count)
                
                NewTaskView(newTitle: $newTitle, taskVM: taskVM, list: list)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .ignoresSafeArea()
        }
    }
}

private struct HeaderView: View {
    let list: List
    let completed: Int
    let total: Int
    
    var body: some View {
        VStack {
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
                
                Text("\(completed)/\(total)")
                    .font(.inter(fontStyle: .title2, fontWeight: .semibold))
                    .foregroundStyle(Color(hex: list.color) ?? .gray)
            }

        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
        .padding(.bottom, 40)
        .padding(.horizontal, 24)
        .background((Color(hex: list.color) ?? .gray).opacity(0.50))
        .clipShape(
            RoundedCorner(corners: [.bottomLeft, .bottomRight], radius: 40)
        )
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
}

private struct NewTaskView: View {
    @Binding var newTitle: String
    var taskVM: TaskViewModel
    let list: List
    
    private func submit() {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        taskVM.addTask(to: list, title: trimmed)
        newTitle = ""
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
                        .fill(AppColors.accent.opacity(0.45))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(AppColors.accent)
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

//#Preview {
//    ListView()
//}

private struct ListViewPreviewWrapper: View {
    @State var showListView: Bool = true

    var body: some View {
        let mockList = List(
            name: "Groceries",
            color: "#7A5FFF",
            icon: "cart"
        )

        ListView(list: mockList, showListView: $showListView)
    }
}

#Preview {
    ListViewPreviewWrapper()
}
