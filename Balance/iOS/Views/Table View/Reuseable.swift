//
//  Reuseable.swift
//  Red Davis
//
//  Created by Red Davis on 02/11/2016.
//  Copyright © 2016 Red Davis. All rights reserved.
//

import UIKit


internal protocol Reusable: class
{
    static var reuseIdentifier: String { get }
}

internal extension Reusable
{
    static var reuseIdentifier: String { return String(describing: Self.self) }
}


internal extension UITableView
{
    func register<T: UITableViewCell>(reusableCell: T.Type) where T: Reusable
    {
        self.register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(at indexPath: IndexPath) -> T where T: Reusable
    {
        return self.dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}


internal extension UICollectionView
{
    func register<T: UICollectionReusableView>(reusableSupplementaryView: T.Type, kind: String) where T: Reusable
    {
        self.register(T.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(at indexPath: IndexPath, kind: String) -> T where T: Reusable
    {
        guard let view = self.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else
        {
            fatalError()
        }
        
        return view
    }
    
    func register<T: UICollectionViewCell>(reusableCell: T.Type) where T: Reusable
    {
        self.register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(at indexPath: IndexPath) -> T where T: Reusable
    {
        return self.dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}
