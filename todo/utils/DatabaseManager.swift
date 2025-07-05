//
//  DatabaseManager.swift
//  todo
//
//  Created by William Sun on 7/3/25.
//

import Foundation
import GRDB

final class DatabaseManager {
    static let shared = DatabaseManager()
    var dbQueue: DatabaseQueue!
    
    private init() {
        setUpDatabase()
    }
    
    private func setUpDatabase() {
        do {
            // STEP 1: in this device's Documents folder, create a file called todos.sqlite, if not already created before
            let fileURL = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("todos.sqlite") // file is called todos.sqlite
            
            // STEP 2: tells GRDB: this is the file path to the SQLite db. Set up the queue for it
            dbQueue = try DatabaseQueue(path: fileURL.path)
            
            // STEP 3: create lists and tasks tables
            try dbQueue.write { db in
//                try db.drop(table: "lists") // dev-only
                try db.create(table: "lists", ifNotExists: true) { t in
                    t.column("id").primaryKey()
                    t.column("name").notNull()
                    t.column("color").notNull()
                    t.column("icon").notNull()
                    t.column("created_at").notNull()
                }
                
                try db.create(table: "tasks", ifNotExists: true) { t in
                    t.column("id").primaryKey()
                    t.column("list_id")
                        .notNull()
                        .indexed()
                        .references("lists", onDelete: .cascade)
                    t.column("title").notNull()
                    t.column("is_complete").notNull()
                    t.column("created_at").notNull()
                    t.column("due_at")
                }
            }
        } catch {

        }
    }
    //
    // CRUD for lists table
    //
    
    func createList(_ list: List) {
        do {
            try dbQueue.write { (db: Database) in
                try list.insert(db)
            }
        } catch {
            print("Failed to insert list: \(error)")
        }
    }
    
    func fetchAllLists() -> [List] {
        do {
            return try dbQueue.read { db in
                try List.fetchAll(db) // select * from lists
            }
            
        } catch {
            print("❌ Failed to fetch lists: \(error)")
            return []
        }
    }
    
    func updateList(_ list: List) {
        do {
            try dbQueue.write { db in
                try list.update(db)
            }
        } catch {
            print("❌ Failed to update list: \(error)")
        }
    }
    
    func deleteList(_ list: List) {
        do {
            _ = try dbQueue.write { db in
                try list.delete(db)
            }
        } catch {
            print("❌ Failed to delete list: \(error)")
        }
    }
    
    //
    // CRUD for tasks table
    //
    
    func createTask(_ task: Task) {
        do {
            try dbQueue.write { db in
                try task.insert(db)
            }
        } catch {
            print("❌ Failed to insert task: \(error)")
        }
    }
    
    func fetchTasks(for listId: UUID) -> [Task] {
        do {
            return try dbQueue.read { db in
                try Task
                    .filter(Column("list_id") == listId)
                    .fetchAll(db)
            }
        } catch {
            print("❌ Failed to fetch tasks for list: \(listId), error: \(error)")
            return []
        }
    }
    
    func updateTask(_ task: Task) {
        do {
            try dbQueue.write { db in
                try task.update(db)
            }
        } catch {
            print("❌ Failed to update task: \(error)")
        }
    }
    
    func deleteTask(_ task: Task) {
        do {
            _ = try dbQueue.write { db in
                try task.delete(db)
            }
        } catch {
            print("❌ Failed to delete task: \(error)")
        }
    }
    
    func taskCount(for listId: UUID) -> Int {
        do {
            return try dbQueue.read { db in
                try Task.filter(Column("list_id") == listId).fetchCount(db)
            }
        } catch {
            print("❌ Failed to count tasks for list \(listId): \(error)")
            return 0
        }
    }

    func completedTaskCount(for listId: UUID) -> Int {
        do {
            return try dbQueue.read { db in
                try Task
                    .filter(Column("list_id") == listId && Column("is_complete") == true)
                    .fetchCount(db)
            }
        } catch {
            print("❌ Failed to count completed tasks for list \(listId): \(error)")
            return 0
        }
    }
}
