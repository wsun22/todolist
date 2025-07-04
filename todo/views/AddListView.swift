//
//  AddListView.swift
//  todo
//
//  Created by William Sun on 7/4/25.
//

import SwiftUI

struct AddListView: View {
    @ObservedObject var listVM: ListViewModel
    @Binding var isPresented: Bool
    
    @State var name: String = ""
    @State var selectedIcon: String = iconOptions[0]
    @State var selectedColor: String = colorOptions[0]
    
    private static let iconOptions: [String] = [
        "star", "briefcase", "house", "heart",
        "dumbbell", "cart", "book", "calendar",
        "lightbulb", "tray", "bookmark", "music.note"
    ]

    private static let colorOptions: [String] = [
        "#FFCC00", "#01C8EE", "#7A5FFF",
        "#F35BAC", "#32C77F", "#FF9442"
    ]

    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 40) {
                EnterNameSection(name: $name)
                
                ChooseIconSection(selectedIcon: $selectedIcon, icons: Self.iconOptions)
                
                ChooseColorSection(selectedColor: $selectedColor, colors: Self.colorOptions)
                
                PreviewCardSection(
                    list: List(
                        name: name.isEmpty ? "New List" : name,
                        color: selectedColor,
                        icon: selectedIcon
                    )
                )
                
                CreateList(
                    listVM: listVM,
                    name: $name,
                    selectedIcon: selectedIcon,
                    selectedColor: selectedColor,
                    isPresented: $isPresented
                )

            }
            .padding(32)
        }
    }
}

private struct EnterNameSection: View {
    @Binding var name: String

    var body: some View {
        ZStack(alignment: .leading) {
            if name.isEmpty {
                Text("Enter list name...")
                    .foregroundColor(AppColors.textSecondary.opacity(0.5))
                    .padding(.horizontal, 20)
            }

            TextField("", text: $name)
                .foregroundColor(AppColors.textSecondary)
                .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.backgroundSecondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.separator, lineWidth: 1)
        )
    }
}


private struct ChooseIconSection: View {
    @Binding var selectedIcon: String
    let icons: [String]
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(icons, id: \.self) { icon in
                Button {
                    selectedIcon = icon
                } label: {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedIcon == icon ? AppColors.accent.opacity(0.15) : AppColors.backgroundSecondary)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedIcon == icon ? AppColors.accent : AppColors.separator, lineWidth: 1)
                        )
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
        }
    }
    
}

private struct ChooseColorSection: View {
    @Binding var selectedColor: String
    let colors: [String]

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(colors, id: \.self) { hex in
                Button {
                    selectedColor = hex
                } label: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: hex) ?? .gray).opacity(0.45)
                        .frame(height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedColor == hex ? AppColors.accent : .clear, lineWidth: 2)
                        )
                }
            }
        }
//        .padding()
//        .background(Color.white)
//        .overlay {
//            RoundedRectangle(cornerRadius: 12)
//                .stroke(Color.white)
//        }
    }
}

private struct PreviewCardSection: View {
    let list: List

    var body: some View {
        ListCardView(list: list, completed: 0, total: 0)
            .frame(maxWidth: 190)
    }
}

private struct CreateList: View {
    let listVM: ListViewModel
    @Binding var name: String
    let selectedIcon: String
    let selectedColor: String
    
    @Binding var isPresented: Bool
    
    var isDisabled: Bool {
        name.isEmpty
    }
    
    var body: some View {
        Button {
            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedName.isEmpty else { return }

            listVM.addList(name: trimmedName, color: selectedColor, icon: selectedIcon)
            isPresented = false
        } label: {
            Text("Create list")
                .font(.inter(fontStyle: .headline, fontWeight: .semibold))
                .frame(maxWidth: .infinity)
                .padding()
                .background(isDisabled ? AppColors.accent.opacity(0.4) : AppColors.accent)
                .foregroundColor(isDisabled ? AppColors.textPrimary.opacity(0.7) : AppColors.textPrimary)
                .cornerRadius(12)
        }
        .disabled(isDisabled)
    }
}

#Preview {
    AddListView(
        listVM: ListViewModel(),
        isPresented: .constant(true)
    )
}
