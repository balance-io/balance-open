//
//  GenericItemRepository.swift
//  Balance
//
//  Created by Benjamin Baron on 8/16/17.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

protocol ItemRepository {
    var table: String { get }
    var itemIdField: String { get }
}

class GenericItemRepository {
    static var si = GenericItemRepository()
    
    func item<T: PersistedItem>(repository: ItemRepository, itemId: Int) -> T? {
        func runQuery(db: FMDatabase, table: String) -> T? {
            var item: T? = nil
            let query = "SELECT * FROM \(table) WHERE \(repository.itemIdField) = ?"
            do {
                let result = try db.executeQuery(query, itemId)
                if result.next() {
                    item = T(result: result, repository: repository)
                }
                result.close()
            } catch {
                log.error("Error loading item \(String(describing: item)): \(error)")
            }
            return item
        }
        
        var item: T? = nil
        database.read.inDatabase { db in
            item = runQuery(db: db, table: repository.table)
        }
        
        return item
    }
    
    func allItems<T: PersistedItem>(repository: ItemRepository) -> [T] {
        var items = [T]()
        database.read.inDatabase { db in
            let query = "SELECT * FROM \(repository.table)"
            do {
                let result = try db.executeQuery(query)
                while result.next() {
                    let item = T(result: result, repository: repository)
                    items.append(item)
                }
                result.close()
            } catch {
                log.error("Error loading all items: \(error)")
            }
        }
        
        return items
    }
    
    func deleteAllItems(repository: ItemRepository) -> Bool {
        var success = true
        database.write.inDatabase { db in
            do {
                let query = "DELETE FROM \(repository.table)"
                try db.executeUpdate(query)
            } catch {
                success = false
                log.error("Error deleting all items: \(error)")
            }
        }
        return success
    }
    
    func isPersisted<T: PersistedItem>(repository: ItemRepository, item: T) -> Bool {
        return isPersisted(repository: repository, itemId: item.itemId)
    }
    
    func isPersisted(repository: ItemRepository, itemId: Int) -> Bool {
        let query = "SELECT COUNT(*) FROM \(repository.table) WHERE \(repository.itemIdField) = ?"
        return database.read.boolForQuery(query, itemId)
    }
    
    func delete<T: PersistedItem>(repository: ItemRepository, item: T) -> Bool {
        var success = true
        database.write.inDatabase { db in
            do {
                let query = "DELETE FROM \(repository.table) WHERE \(repository.itemIdField) = ?"
                try db.executeUpdate(query, item.itemId)
            } catch {
                success = false
                log.error("Error deleting item \(item): \(error)")
            }
        }
        return success
    }
}
