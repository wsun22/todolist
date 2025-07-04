//
//  DataModels.swift
//  todo
//
//  Created by William Sun on 7/3/25.
//

import Foundation
import GRDB

struct List: Codable, Identifiable, FetchableRecord, PersistableRecord {
    static let databaseTableName: String = "lists"
    
    var id: UUID
    var name: String
    var color: String
    var image: String
    var createdAt: Date
    
    init(id: UUID = UUID(), name: String, color: String, image: String, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.color = color
        self.image = image
        self.createdAt = createdAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case color
        case image
        case createdAt = "created_at"
    }
}

class ListViewModel: ObservableObject {
    private let dbManager = DatabaseManager.shared

    @Published var lists: [List] = []
        
    init() {
        loadLists()
    }
    
    private func loadLists() {
        lists = dbManager.fetchAllLists()
    }
    
    func addList(name: String, color: String, image: String) {
        let list = List(name: name, color: color, image: image)
        dbManager.createList(list) // update backend
        lists.append(list) // update UI
    }
    
    func deleteList(_ list: List) {
        dbManager.deleteList(list)
        lists.removeAll { $0.id == list.id }
    }
    
    func taskCount(_ list: List) -> Int {
        return dbManager.taskCount(for: list.id)
    }
    
    func completedTaskCount(_ list: List) -> Int {
        return dbManager.completedTaskCount(for: list.id)
    }
}

// MARK : - Task struct and VM

struct Task: Codable, Identifiable, FetchableRecord, PersistableRecord {
    static let databaseTableName: String = "tasks"
    
    var id: UUID
    var listId: UUID
    var title: String
    var isComplete: Bool
    var createdAt: Date
    var dueAt: Date?
    
    init(id: UUID = UUID(), listId: UUID, title: String, isComplete: Bool = false, createdAt: Date = Date(), dueAt: Date? = nil) {
        self.id = id
        self.listId = listId
        self.title = title
        self.isComplete = isComplete
        self.createdAt = createdAt
        self.dueAt = dueAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case listId = "list_id"
        case title
        case isComplete = "is_complete"
        case createdAt = "created_at"
        case dueAt = "due_at"
    }
}

class TaskViewModel: ObservableObject {
    private let dbManager = DatabaseManager.shared
    
    @Published var tasks: [Task] = []
    private let listId: UUID
    
    init(for list: List) {
        self.listId = list.id
        loadTasks()
    }
    
    private func loadTasks() {
        tasks = dbManager.fetchTasks(for: listId)
    }
    
    func addTask(to list: List, title: String, isComplete: Bool, createdAt: Date = Date(), dueAt: Date? = nil) {
        let task = Task(listId: list.id, title: title, isComplete: isComplete, createdAt: createdAt, dueAt: dueAt)
        dbManager.createTask(task)
        tasks.append(task)
    }
    
    func toggleTask(_ task: Task) {
        let updated = Task(id: task.id, listId: listId, title: task.title, isComplete: !task.isComplete, createdAt: task.createdAt, dueAt: task.dueAt)
        dbManager.updateTask(updated)
        
        if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[idx] = updated
        }
    }
    
    func deleteTask(_ task: Task) {
        dbManager.deleteTask(task)
        tasks.removeAll { $0.id == task.id }
    }
}
