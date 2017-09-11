//
//  CategoryRepository.swift
//  Balance
//
//  Created by Benjamin Baron on 8/16/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct CategoryRepository: ItemRepository {
    static let si = CategoryRepository()
    fileprivate let gr = GenericItemRepository.si
    
    let table = "categories"
    let itemIdField = "categoryId"
    
    func category(categoryId: Int) -> Category? {
        return gr.item(repository: self, itemId: categoryId)
    }
    
    func category(source: Source, sourceCategoryId: String) -> Category? {
        var category: Category?
        database.read.inDatabase { db in
            do {
                let query = "SELECT * FROM categories WHERE sourceId = ? AND sourceCategoryId = ?"
                let result = try db.executeQuery(query, source.rawValue, sourceCategoryId)
                if result.next() {
                    category = Category(result: result, repository: self)
                }
                result.close()
            } catch {
                log.severe("DB Error: " + db.lastErrorMessage())
            }
        }
        return category
    }
    
    func category(source: Source, name1: String, name2: String?, name3: String?) -> Category? {
        var category: Category?
        database.read.inDatabase { db in
            do {
                let statement = "SELECT * FROM categories WHERE sourceId = ? AND name1 = ? AND name2 = ? AND name3 = ?"
                let result = try db.executeQuery(statement, source.rawValue, name1, n2N(name2), n2N(name3))
                if result.next() {
                    category = Category(result: result, repository: self)
                }
                result.close()
            } catch {
                log.severe("DB Error: " + db.lastErrorMessage())
            }
        }
        return category
    }
    
    @discardableResult func category(source: Source, sourceCategoryId: String, name1: String, name2: String?, name3: String?) -> Category? {
        // First check if a record for this category already exists
        var categoryIdFromDb: Int?
        database.read.inDatabase { db in
            let query = "SELECT categoryId FROM categories WHERE sourceId = ? AND sourceCategoryId = ?"
            
            if let categoryIdString = db.stringForQuery(query, source.rawValue, sourceCategoryId){
                // Record exists, so use the transaction id from the database
                categoryIdFromDb = (categoryIdString as NSString).integerValue
            }
        }
        
        if let categoryId = categoryIdFromDb {
            let category = Category(categoryId: categoryId, source: source, sourceCategoryId: sourceCategoryId, name1: name1, name2: name2, name3: name3, repository: self)
            category.replace()
            return category
        } else {
            // No record exists, so this is a new transaction. Insert the record and retrieve the transaction id
            var generatedId: Int?
            database.write.inDatabase { db in
                do {
                    let query = "INSERT INTO categories " +
                                "VALUES (?, ?, ?, ?, ?, ?)"
                    try db.executeUpdate(query, NSNull(), source.rawValue, sourceCategoryId, n2N(name1), n2N(name2), n2N(name3))
                    
                    generatedId = Int(db.lastInsertRowId())
                } catch {
                    log.severe("Error creating category: " + db.lastErrorMessage())
                }
            }
            
            if let categoryId = generatedId {
                let category = Category(categoryId: categoryId, source: source, sourceCategoryId: sourceCategoryId, name1: name1, name2: name2, name3: name3, repository: self)
                return category
            } else {
                // TODO: Handle this error better, this means a serious DB problem
                // Something went really wrong and we didn't get a categoryId id
                log.severe("Failed to create accountId for category \(name1), \(String(describing: name2)), \(String(describing: name3))")
                return nil
            }
        }
    }
    
    func isPersisted(category: Category) -> Bool {
        return gr.isPersisted(repository: self, item: category)
    }
    
    func isPersisted(categoryId: Int) -> Bool {
        return gr.isPersisted(repository: self, itemId: categoryId)
    }
    
    @discardableResult func replace(category: Category) -> Bool {
        var success = true
        database.write.inDatabase { db in
            do {
                let query = "INSERT OR REPLACE INTO categories " +
                            "VALUES (?, ?, ?, ?, ?, ?)"
                
                // Hack for compile time speed
                let categoryId: Any = category.categoryId
                let source: Any = category.source.rawValue
                let sourceCategoryId: Any = category.sourceCategoryId
                let name1: Any = category.name1
                let name2: Any = n2N(category.name2)
                let name3: Any = n2N(category.name3)
                
                try db.executeUpdate(query, categoryId, source, sourceCategoryId, name1, name2, name3)
            } catch {
                log.severe("Error replacing category \(category): " + db.lastErrorMessage())
                success = false
            }
        }
        return success
    }
    
    func delete(category: Category) -> Bool {
        return gr.delete(repository: self, item: category)
    }
    
    func allCategories() -> [Category] {
        var categories = [Category]()
        database.read.inDatabase { db in
            do {
                let query = "SELECT * FROM categories"
                let result = try db.executeQuery(query)
                while result.next() {
                    categories.append(Category(result: result, repository: self))
                }
                result.close()
            } catch {
                log.severe("DB Error: " + db.lastErrorMessage())
            }
        }
        return categories
    }
    
    func allCategoryNames() -> [String] {
        var names = Set<String>()
        database.read.inDatabase { db in
            do {
                let statement = "SELECT name1, name2, name3 FROM categories"
                let result = try db.executeQuery(statement)
                while result.next() {
                    if let name1 = result.string(forColumnIndex: 0) {
                        names.insert(name1)
                    }
                    //                    if let name2 = result.stringForColumnIndex(1) {
                    //                        names.insert(name2)
                    //                    }
                    //                    if let name3 = result.stringForColumnIndex(2) {
                    //                        names.insert(name3)
                    //                    }
                }
                result.close()
            } catch {
                log.severe("DB Error: " + db.lastErrorMessage())
            }
        }
        return Array(names).sorted()
    }
}

extension Category: PersistedItem {
    class func item(itemId: Int, repository: ItemRepository = CategoryRepository.si) -> Item? {
        return (repository as? CategoryRepository)?.category(categoryId: itemId)
    }
    
    var isPersisted: Bool {
        return repository.isPersisted(category: self)
    }
    
    @discardableResult func replace() -> Bool {
        return repository.replace(category: self)
    }
    
    @discardableResult func delete() -> Bool {
        return repository.delete(category: self)
    }
}
