//
//  TodoItem.swift
//  todo
//
//  Created by William Sun on 7/1/25.
//

import Foundation
import GRDB

struct TodoItem: Codable, Identifiable, FetchableRecord, PersistableRecord {
    var id: UUID
    var task: String
    var isComplete: Bool
    
    init(id: UUID = UUID(), task: String, isComplete: Bool) {
        self.id = id
        self.task = task
        self.isComplete = isComplete
    }
}

class TodoItemViewModel: ObservableObject {
    private let databaseManager = DatabaseManager.shared
    @Published var todos: [TodoItem] = []
    
    init() {
        loadTodos()
    }
    
    func loadTodos() {
        todos = databaseManager.fetchAllTodos()
    }
    
    func addTodo(task: String) {
        let todo = TodoItem(task: task, isComplete: false)
        databaseManager.createTodo(todo)
        todos.append(todo) // update UI side
    }
    
    func toggleTodo(_ todo: TodoItem) {
        // Flip the isComplete value
        print("Before toggle: \(todo.isComplete)")
        let updated = TodoItem(id: todo.id, task: todo.task, isComplete: !todo.isComplete)
        print("New value to save: \(updated.isComplete)")
        // Save to the database
        databaseManager.updateTodo(updated)
        print("todo.id = \(todo.id), trying to find in todos...")

        // update UI side
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index] = updated
            print("✅ Updated in memory: \(todos[index].isComplete)")
        }
    }
    
    func deleteTodo(_ todo: TodoItem) {
        databaseManager.deleteTodo(todo)
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos.remove(at: index)
        }
    }
}
