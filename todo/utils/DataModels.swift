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

struct Task: Codable, Identifiable, FetchableRecord, PersistableRecord {
    static let databaseTableName: String = "tasks"
    
    var id: UUID
    var listId: UUID
    var task: String
    var isComplete: Bool
    var createdAt: Date
    var dueAt: Date?
    
    init(id: UUID = UUID(), listId: UUID, task: String, isComplete: Bool = false, createdAt: Date = Date(), dueAt: Date? = nil) {
        self.id = id
        self.listId = listId
        self.task = task
        self.isComplete = isComplete
        self.createdAt = createdAt
        self.dueAt = dueAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case listId = "list_id"
        case task
        case isComplete = "is_complete"
        case createdAt = "created_at"
        case dueAt = "due_at"
    }
}
