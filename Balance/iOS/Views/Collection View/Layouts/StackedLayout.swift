//
//  StackedLayout.swift
//  BalanceiOS
//
//  Created by Red Davis on 11/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


internal final class StackedLayout: UICollectionViewLayout {
    // Internal
    
    // Private
    private var layoutAttributes = [IndexPath : UICollectionViewLayoutAttributes]()
    private let itemHeight: CGFloat = 120.0
    private let openRevealHeight: CGFloat = 40.0
    private let stretchValue: CGFloat = 0.2
    
    // MARK: Layout
    
    override var collectionViewContentSize: CGSize {
        guard let unwrappedCollectionView = self.collectionView else {
            return CGSize.zero
        }

        let numberOfItems = unwrappedCollectionView.numberOfItems(inSection: 0)
        let contentHeight = CGFloat(numberOfItems) * openRevealHeight
        
        return CGSize(width: unwrappedCollectionView.bounds.width, height: contentHeight)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    internal override func prepare() {
        guard let unwrappedCollection = self.collectionView else {
            return
        }
        
        var layoutAttributes = [IndexPath : UICollectionViewLayoutAttributes]()
        let numberOfItems = unwrappedCollection.numberOfItems(inSection: 0)
        
        for index in 0..<numberOfItems {
            let indexPath = IndexPath(row: index, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            let yOrigin = self.openRevealHeight * CGFloat(index)
            attributes.frame = CGRect(x: 0.0, y: yOrigin, width: unwrappedCollection.bounds.width, height: self.itemHeight)
            attributes.zIndex = index
            attributes.transform3D = CATransform3DMakeTranslation(0.0, 0.0, CGFloat(index - numberOfItems))
            
            // Collection view is at the top and the user continues to pull down
            if (unwrappedCollection.contentOffset.y + unwrappedCollection.contentInset.top < 0.0) {
                var frame = attributes.frame
                frame.origin.y -= self.stretchValue * unwrappedCollection.contentOffset.y * CGFloat(index)
                
                attributes.frame = frame
            }
            
            layoutAttributes[indexPath] = attributes
        }
        
        self.layoutAttributes = layoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.layoutAttributes[indexPath]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = self.layoutAttributes.filter { (indexPath, attributes) -> Bool in
            return rect.intersects(attributes.frame)
        }.values
        
        return Array(attributes)
    }
}
