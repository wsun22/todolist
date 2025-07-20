//
//  AddListView.swift
//  todo
//
//  Created by William Sun on 7/4/25.
//

import SwiftUI

struct AddListView: View {
    @ObservedObject var listVM: ListViewModel
    @Binding var showAddListView: Bool
    @Binding var didCreateList: Bool
    
    @State var name: String = ""
    @State var selectedIcon: String = iconOptions[0]
    @State var selectedColor: String = colorOptions[0]
    @State var showPremiumIcons: Bool = false
    @State var showPremiumColors: Bool = false
    
    @EnvironmentObject var storeKit: StoreKitManager
    @EnvironmentObject var toast: ToastManager
    
    private static let iconOptions: [String] = [
        "star", "briefcase", "house", "heart",
        "dumbbell", "cart", "book", "calendar"
    ]
    
    private static let premiumIconOptions: [String] = [
        "paintpalette", "globe", "leaf", "moon",
        "flame", "camera", "gamecontroller", "pencil",
        "gift", "graduationcap", "music.note", "film",
        "bolt", "cloud", "bicycle", "scissors"
    ]

    private static let colorOptions: [String] = [
        "#FFCC00", "#01C8EE", "#7A5FFF",
        "#F35BAC", "#32C77F", "#FF9442"
    ]
    
    private static let premiumColorOptions: [String] = [
        "#C084FC", // strong lavender
        "#F472B6", // hot pink
        "#34D399", // vivid mint green
        "#F59E0B", // bold amber
        "#60A5FA", // bright blue
        "#4B5563", // medium gray
        "#1F2937", // slate / near-black
        "#A855F7", // purple
        "#EF4444", // red
        "#10B981", // emerald
        "#3B82F6", // strong blue
        "#EC4899"  // magenta-pink
    ]

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 40) {
                    CustomBackButton(action: { showAddListView = false })
                    
                    EnterNameSection(name: $name)
                    
                    ChooseIconSection(
                        selectedIcon: $selectedIcon,
                        icons: Self.iconOptions,
                        premiumIcons: Self.premiumIconOptions,
                        showPremiumIcons: $showPremiumIcons,
                        storeKit: storeKit,
                        toast: toast)
                    
                    ChooseColorSection(
                        selectedColor: $selectedColor,
                        colors: Self.colorOptions,
                        premiumColors: Self.premiumColorOptions,
                        showPremiumColors: $showPremiumColors,
                        storeKit: storeKit,
                        toast: toast)
                    
                    PreviewCardSection(
                        list: List(
                            name: name.isEmpty ? "New List" : name,
                            color: selectedColor,
                            icon: selectedIcon,
                            idx: 0
                        )
                    )
                    
                    CreateList(
                        listVM: listVM,
                        name: $name,
                        selectedIcon: selectedIcon,
                        selectedColor: selectedColor,
                        showAddListView: $showAddListView,
                        didCreateList: $didCreateList
                    )
                }
                .padding(32)
            }
        }
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(.keyboard)
        .hideKeyboardOnTap()
        .toast(isVisible: toast.isVisible, message: toast.message)
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
    let premiumIcons: [String]
    @Binding var showPremiumIcons: Bool
    let storeKit: StoreKitManager
    let toast: ToastManager
    
    var displayIcons: [String]  {
        showPremiumIcons ? icons + premiumIcons : icons
    }
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(displayIcons, id: \.self) { icon in
                    Button {
                        let isPremium: Bool = premiumIcons.contains(icon)
                        let isLocked: Bool = isPremium && !storeKit.isSubscribed
                        if !isLocked {
                            selectedIcon = icon
                            haptic()
                        } else {
                            haptic(weight: .light)
                            toast.show(message: "Unlock premium icons with taskmaster+")
                        }
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
            
            Button {
                showPremiumIcons.toggle()
            } label: {
                Image(systemName: showPremiumIcons ? "chevron.up" : "chevron.down")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(AppColors.backgroundSecondary)
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.top, 8)
            .padding(.bottom, -16)
        }
    }
}

private struct ChooseColorSection: View {
    @Binding var selectedColor: String
    let colors: [String]
    let premiumColors: [String]
    @Binding var showPremiumColors: Bool
    let storeKit: StoreKitManager
    let toast: ToastManager
    
    var displayColors: [String] {
        showPremiumColors ? colors + premiumColors : colors
    }

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 0) {
            LazyVGrid(columns: columns) {
                ForEach(displayColors, id: \.self) { color in
                    Button {
                        let isPremium: Bool = premiumColors.contains(color)
                        let isLocked = isPremium && !storeKit.isSubscribed
                        if !isLocked {
                            selectedColor = color
                            haptic()
                        } else {
                            haptic()
                            toast.show(message: "Unlock premium colors with taskmaster+")
                        }
                    } label: {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: color) ?? .gray).opacity(0.45)
                            .frame(height: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedColor == color ? AppColors.accent : .clear, lineWidth: 2)
                            )
                    }
                }
            }
            
            Button {
                showPremiumColors.toggle()
            } label: {
                Image(systemName: showPremiumColors ? "chevron.up" : "chevron.down")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(AppColors.backgroundSecondary)
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.top, 8)
            .padding(.bottom, -16)
        }
    }
}

private struct PreviewCardSection: View {
    let list: List

    var body: some View {
        ListCardView(list: list, completed: 5, total: 7)
            .frame(maxWidth: 190)
    }
}

private struct CreateList: View {
    let listVM: ListViewModel
    @Binding var name: String
    let selectedIcon: String
    let selectedColor: String
    
    @Binding var showAddListView: Bool
    @Binding var didCreateList: Bool
    
    var isDisabled: Bool {
        name.isEmpty
    }
    
    var body: some View {
        Button {
            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedName.isEmpty else { return }

            listVM.addList(name: trimmedName, color: selectedColor, icon: selectedIcon)
            showAddListView = false
            didCreateList = true
            
            haptic()
        } label: {
            Text("Create list")
                .font(.inter(fontStyle: .headline, fontWeight: .semibold))
                .frame(maxWidth: .infinity)
                .padding()
                .background(isDisabled ? AppColors.accent.opacity(0.3) : AppColors.accent)
                .foregroundColor(isDisabled ? Color.white.opacity(0.3) : Color.white)
                .cornerRadius(12)
        }
        .disabled(isDisabled)
    }
}

//#Preview {
//    AddListView(
//        listVM: ListViewModel(),
//        showAddListView: .constant(true),
//        didCreateList: .constant(false)
//    )
//}
