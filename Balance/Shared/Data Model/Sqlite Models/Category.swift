//
//  Category.swift
//  Bal
//
//  Created by Benjamin Baron on 2/9/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

final class Category {
    let repository: CategoryRepository
    
    let categoryId: Int
    let source: Source
    let sourceCategoryId: String
    
    let name1: String
    let name2: String?
    let name3: String?
    
    required init(result: FMResultSet, repository: ItemRepository = CategoryRepository.si) {
        self.repository = repository as! CategoryRepository
        
        self.categoryId = result.long(forColumnIndex: 0)
        self.source = Source(rawValue: result.long(forColumnIndex: 1))!
        self.sourceCategoryId = result.string(forColumnIndex: 2)
        
        self.name1 = result.string(forColumnIndex: 3)
        self.name2 = result.string(forColumnIndex: 4)
        self.name3 = result.string(forColumnIndex: 5)
    }
    
    init(categoryId: Int, source: Source, sourceCategoryId: String, name1: String, name2: String?, name3: String?, repository: CategoryRepository = CategoryRepository.si) {
        self.repository = repository
        
        self.categoryId = categoryId
        self.source = source
        self.sourceCategoryId = sourceCategoryId
        
        self.name1 = name1
        self.name2 = name2
        self.name3 = name3
    }
}

extension Category: Item, Equatable {
    var itemId: Int { return categoryId }
    var itemName: String { return name1 }
}

extension Category: CustomStringConvertible {
    var description: String {
        return "\(categoryId): \(name1), \(String(describing: name2)), \(String(describing: name3))"
    }
}

extension Category {
    var names: [String] {
        var names = [name1]
        if let name2 = name2 {
            names.append(name2)
        }
        if let name3 = name3 {
            names.append(name3)
        }
        return names
    }
    
    #if os(OSX)
    static func touchBarImage(forCategory name: String) -> NSImage? {
        switch name {
        case "Bank Fees": return #imageLiteral(resourceName: "tb-category-bank-fees")
        case "Cash Advance": return #imageLiteral(resourceName: "tb-category-cash-advance")
        case "Community": return #imageLiteral(resourceName: "tb-category-community")
        case "Food and Drink": return #imageLiteral(resourceName: "tb-category-food-and-drink")
        case "Healthcare": return #imageLiteral(resourceName: "tb-category-healthcare")
        case "Interest": return #imageLiteral(resourceName: "tb-category-interest")
        case "Payment": return #imageLiteral(resourceName: "tb-category-payment")
        case "Recreation": return #imageLiteral(resourceName: "tb-category-recreation")
        case "Service": return #imageLiteral(resourceName: "tb-category-service")
        case "Shops": return #imageLiteral(resourceName: "tb-category-shops")
        case "Tax": return #imageLiteral(resourceName: "tb-category-tax")
        case "Transfer": return #imageLiteral(resourceName: "tb-category-transfer")
        case "Travel": return #imageLiteral(resourceName: "tb-category-travel")
        default: return nil
        }
    }
    #endif
}
