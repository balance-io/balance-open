//
//  StackedLayout.swift
//  BalanceiOS
//
//  Created by Red Davis on 11/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


internal final class StackedLayout: UICollectionViewLayout {
    // Private
    private var layoutAttributes = [IndexPath : UICollectionViewLayoutAttributes]()
    
    // MARK: Layout
    
    internal override func prepare() {
        guard let unwrappedCollection = self.collectionView else {
            return
        }
        
        var layoutAttributes = [IndexPath : UICollectionViewLayoutAttributes]()
        let numberOfItems = unwrappedCollection.numberOfItems(inSection: 0)
        
        for index in 0..<numberOfItems {
            let indexPath = IndexPath(row: index, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            let yOrigin = 20.0 * CGFloat(index)
            attributes.frame = CGRect(x: 0.0, y: yOrigin, width: unwrappedCollection.bounds.width, height: 50.0)
            attributes.zIndex = index
            attributes.transform3D = CATransform3DMakeTranslation(0.0, 0.0, CGFloat(index - numberOfItems))
            
            layoutAttributes[indexPath] = attributes
        }
        
        self.layoutAttributes = layoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.layoutAttributes[indexPath]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        self.layoutAttributes.filter { (indexPath, attributes) -> Bool in
            return rect.intersects(attributes.frame)
        }
    }
}
