//
//  Item.swift
//  Balance
//
//  Created by Benjamin Baron on 8/16/17.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

protocol Item: CustomStringConvertible {
    var itemId: Int { get }
    var itemName: String { get }
    
//    var institutionId: String { get }
//    var source: Source { get }
//    var sourceItemId: String { get }
//    var sourceInstitutionId: String { get }
    
    
}

extension Item {
    var description: String {
        return "[\(String(describing: type(of: self)))] \(itemId) - \(itemName)"
    }
}

protocol PersistedItem: Item {
    var isPersisted: Bool { get }
    
    func replace() -> Bool
    func delete() -> Bool
    
    static func item(itemId: Int, repository: ItemRepository) -> Item?
    init(result: FMResultSet, repository: ItemRepository)
}

func ==<T: Item>(lhs: T, rhs: T) -> Bool {
    return lhs.itemId == rhs.itemId
}

//func ==<T: Item, U:Item>(lhs: T, rhs: U) -> Bool {
//    return lhs.itemId == rhs.itemId
//}
