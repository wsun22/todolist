//
//  todoApp.swift
//  todo
//
//  Created by William Sun on 7/1/25.
//

import SwiftUI

@main
struct todoApp: App {
    @StateObject var todoItemsVM = TodoItemViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(todoItemsVM: todoItemsVM)
        }
    }
}
