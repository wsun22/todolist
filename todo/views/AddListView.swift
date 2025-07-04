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
    @State var selectedIcon: String = "star"

    
    let iconOptions: [String] = [
        "star", "briefcase", "house", "heart",
        "dumbbell", "cart", "book", "calendar",
        "lightbulb", "tray", "bookmark", "music.note"
    ]
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 48) {
                EnterNameSection(name: $name)
                    .border(.red)
                
                ChooseIconSection(selectedIcon: $selectedIcon, icons: iconOptions)
                    .border(.red)
            }
            .padding(32)
        }
    }
}

private struct EnterNameSection: View {
    @Binding var name: String
    
    var body: some View {
        TextField("Enter list name", text: $name)
            .padding(16)
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


#Preview {
    AddListView(
        listVM: ListViewModel(),
        isPresented: .constant(true)
    )
}
