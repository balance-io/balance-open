//
//  Reusable.swift
//  Red Davis
//
//  Created by Red Davis on 31/08/2017.
//  Copyright © 2017 Red Davis LTD. All rights reserved.
//

import Cocoa


// MARK: Reusable

protocol Reusable: class {
    static var reuseIdentifier: NSUserInterfaceItemIdentifier { get }
}

extension Reusable {
    static var reuseIdentifier: NSUserInterfaceItemIdentifier {
        return NSUserInterfaceItemIdentifier(String(describing: Self.self))
    }
}

// MARK: NSCollectionView

extension NSCollectionView {
    func register<T: NSCollectionViewItem>(reusableItem: T.Type) where T: Reusable {
        self.register(T.self, forItemWithIdentifier: T.reuseIdentifier)
    }
    
    func makeReusableItem<T: NSCollectionViewItem>(at indexPath: IndexPath) -> T where T: Reusable {
        return self.makeItem(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}
