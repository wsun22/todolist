//
//  DataModels.swift
//  todo
//
//  Created by William Sun on 7/3/25.
//

import Foundation
import GRDB
import StoreKit

struct List: Codable, Identifiable, Equatable, FetchableRecord, PersistableRecord {
    static let databaseTableName: String = "lists"
    
    var id: UUID
    var name: String
    var color: String
    var icon: String
    var idx: Int
    var createdAt: Date
    
    init(id: UUID = UUID(), name: String, color: String, icon: String, idx: Int, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.color = color
        self.icon = icon
        self.idx = idx
        self.createdAt = createdAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case color
        case icon
        case idx
        case createdAt = "created_at"
    }
}

final class ListViewModel: ObservableObject {
    private let dbManager = DatabaseManager.shared

    @Published var lists: [List] = []
        
    init() {
        loadLists()
    }
    
    private func loadLists() {
        lists = dbManager.fetchAllLists()
    }
    
    func addList(name: String, color: String, icon: String) {
        let nextIdx = (lists.map { $0.idx }.max() ?? -1) + 1
        let list = List(name: name, color: color, icon: icon, idx: nextIdx)
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
    
    func refreshCount(for list: List) {
        // this is a manual refresh for this class. it says: "I didn't change any @Published properties directly, but trust me bro, act like I did"
        objectWillChange.send()
    }
}

//
// Task struct and VM
//

struct Task: Codable, Identifiable, FetchableRecord, PersistableRecord {
    static let databaseTableName: String = "tasks"
    
    var id: UUID
    var listId: UUID
    var title: String
    var isComplete: Bool
    var createdAt: Date
    var dueAt: Date?
    var idx: Int
    
    init(id: UUID = UUID(), listId: UUID, title: String, isComplete: Bool, createdAt: Date = Date(), dueAt: Date?, idx: Int) {
        self.id = id
        self.listId = listId
        self.title = title
        self.isComplete = isComplete
        self.createdAt = createdAt
        self.dueAt = dueAt
        self.idx = idx
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case listId = "list_id"
        case title
        case isComplete = "is_complete"
        case createdAt = "created_at"
        case dueAt = "due_at"
        case idx
    }
}

final class TaskViewModel: ObservableObject {
    private let dbManager = DatabaseManager.shared
    
    @Published var tasks: [Task] = []
    private let listId: UUID
    
    var onTasksChanged: (() -> Void)?
    
    // IGNORE: for rating app
    private var hasRequestedReview: Bool = UserDefaults.standard.bool(forKey: "hasRequestedReview")

    init(for list: List) {
        self.listId = list.id
        loadTasks()
    }
    
    private func loadTasks() {
        tasks = dbManager.fetchTasks(for: listId)
    }
    
    func addTask(to list: List, title: String, isComplete: Bool = false, createdAt: Date = Date(), dueAt: Date? = nil) {
        let maxIdx = (tasks.map { $0.idx }.max() ?? -1) + 1
        let task = Task(listId: list.id, title: title, isComplete: isComplete, createdAt: createdAt, dueAt: dueAt, idx: maxIdx)
        dbManager.createTask(task)
        tasks.append(task)
        onTasksChanged?()
    }
    
    func toggleTask(_ task: Task) {
        let updated = Task(id: task.id, listId: listId, title: task.title, isComplete: !task.isComplete, createdAt: task.createdAt, dueAt: task.dueAt, idx: task.idx)
        dbManager.updateTask(updated)
        
        if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[idx] = updated
        }
        onTasksChanged?()
        
        // IGNORE: for rating app
        if !hasRequestedReview {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                
                DispatchQueue.main.async {
                    if #available(iOS 18.0, *) {
                        AppStore.requestReview(in: scene)
                    } else {
                        SKStoreReviewController.requestReview(in: scene)
                    }
                }
                
                UserDefaults.standard.set(true, forKey: "hasRequestedReview")
                hasRequestedReview = true
            }
        }
    }
    
    func deleteTask(_ task: Task) {
        dbManager.deleteTask(task)
        tasks.removeAll { $0.id == task.id }
        onTasksChanged?()
    }
}
