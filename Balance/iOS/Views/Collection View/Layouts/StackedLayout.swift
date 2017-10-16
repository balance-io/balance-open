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
    private var previousLayoutAttributes = [IndexPath : UICollectionViewLayoutAttributes]()
    private let closedItemHeight: CGFloat = 120.0
    private let stretchValue: CGFloat = 0.2
    
    private let afterSelectedItemOverlapHeight: CGFloat = 60.0
    private let afterUnselectedItemOverlapHeight: CGFloat = 40.0
    
    private var contentHeight: CGFloat = 0.0
    
    // MARK: Layout
    
    override var collectionViewContentSize: CGSize {
        guard let unwrappedCollectionView = self.collectionView else {
            return CGSize.zero
        }
        
        return CGSize(width: unwrappedCollectionView.bounds.width, height: max(self.contentHeight, unwrappedCollectionView.bounds.height))
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    internal override func prepare() {
        super.prepare()
        
        guard let unwrappedCollectionView = self.collectionView,
              let selectedIndexPaths = unwrappedCollectionView.indexPathsForSelectedItems else {
            return
        }
        
        var layoutAttributes = [IndexPath : UICollectionViewLayoutAttributes]()
        let numberOfItems = unwrappedCollectionView.numberOfItems(inSection: 0)
        var nextYCoor: CGFloat = 0.0
        
        for index in 0..<numberOfItems {
            let indexPath = IndexPath(row: index, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            let height: CGFloat
            let nextOverlap: CGFloat
            if selectedIndexPaths.contains(indexPath),
               let cell = unwrappedCollectionView.cellForItem(at: indexPath)
            {
                height = cell.intrinsicContentSize.height
                nextOverlap = 40.0
            }
            else
            {
                height = self.closedItemHeight
                nextOverlap = 60.0
            }
            
            self.contentHeight = nextYCoor + height
            
            attributes.frame = CGRect(x: 0.0, y: nextYCoor, width: unwrappedCollectionView.bounds.width, height: height)
            attributes.zIndex = index
            attributes.transform3D = CATransform3DMakeTranslation(0.0, 0.0, CGFloat(index - numberOfItems))
            
            // Collection view is at the top and the user continues to pull down
            if (unwrappedCollectionView.contentOffset.y + unwrappedCollectionView.contentInset.top < 0.0) {
                var frame = attributes.frame
                frame.origin.y -= self.stretchValue * unwrappedCollectionView.contentOffset.y * CGFloat(index)
                
                attributes.frame = frame
            }
            
            nextYCoor = nextYCoor + height - nextOverlap
            layoutAttributes[indexPath] = attributes
        }
        
        self.previousLayoutAttributes = self.layoutAttributes
        self.layoutAttributes = layoutAttributes
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.previousLayoutAttributes[itemIndexPath]
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.layoutAttributes[itemIndexPath]
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
