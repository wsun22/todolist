//
//  DatabaseManager.swift
//  todo
//
//  Created by William Sun on 7/1/25.
//

import Foundation
import GRDB

class DatabaseManager {
    static let shared = DatabaseManager()
    var dbQueue: DatabaseQueue!
    
    private init() {
 //       deleteExistingDatabaseFile()
        setupDatabase()
    }
    
    private func setupDatabase() {
        do {
            // 1. create db fileURL in app's Documents folder
            let fileURL = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("todos.sqlite")
            
            // 2. initialize GDRB's db queue
            dbQueue = try DatabaseQueue(path: fileURL.path)
            
            // 3. create the table (if doesn't exist yet)
            try dbQueue.write { db in
                try db.create(table: "todoItem", ifNotExists: true) { t in
                    t.column("id").primaryKey()
                    t.column("task", .text).notNull()
                    t.column("isComplete", .boolean).notNull().defaults(to: false)
                }
                
       //         print("✅ Database setup complete")
            }
        } catch {
       //     print("❌ Database setup failed: \(error)")
        }
    }
    
    private func deleteExistingDatabaseFile() {
        do {
            let fileURL = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("todos.sqlite")

            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
                print("🗑️ Existing database deleted.")
            }
        } catch {
            print("⚠️ Failed to delete existing database: \(error)")
        }
    }
    
    func createTodo(_ todo: TodoItem) {
        do {
            try dbQueue.write { db in
                try todo.insert(db)
            }
            print("✅ Inserted todo: \(todo.task)")
        } catch {
            print("❌ Failed to insert todo: \(error)")
        }
    }
    
    func fetchAllTodos() -> [TodoItem] {
        do {
            return try dbQueue.read { db in
                try TodoItem.fetchAll(db)
            }
        } catch {
            print("❌ Failed to fetch todos: \(error)")
            return []
        }
    }

    func updateTodo(_ todo: TodoItem) {
        print("⚠️ Updating todo in DB to: \(todo.isComplete)")
        do {
            try dbQueue.write { db in
                try todo.update(db)
            }
        } catch {
            print("❌ Failed to update todo: \(error)")
        }
    }

    func deleteTodo(_ todo: TodoItem) {
        do {
            _ = try dbQueue.write { db in
                try todo.delete(db)
            }
        } catch {
            print("❌ Failed to delete todo: \(error)")
        }
    }
}

//
//extension UUID {
//    public var databaseValue: DatabaseValue {
//        uuidString.databaseValue  // store as .text
//    }
//
//    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> UUID? {
//        guard let string = String.fromDatabaseValue(dbValue) else { return nil }
//        return UUID(uuidString: string)
//    }
//}
