//
//  StackedLayout.swift
//  BalanceiOS
//
//  Created by Red Davis on 11/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


@objc protocol StackedLayoutDelegate: class {
    func closedHeightForItem(at indexPath: IndexPath, in collectionView: UICollectionView) -> CGFloat
    func expandedHeightForItem(at indexPath: IndexPath, in collectionView: UICollectionView) -> CGFloat
}


internal final class StackedLayout: UICollectionViewLayout {
    // Internal
    internal weak var delegate: StackedLayoutDelegate?
    
    // Private
    private var layoutAttributes = [IndexPath : UICollectionViewLayoutAttributes]()
    private var previousLayoutAttributes = [IndexPath : UICollectionViewLayoutAttributes]()
    private let stretchValue: CGFloat = 0.2
    
    private let itemOverlap: CGFloat = 40.0
    private var contentHeight: CGFloat = 0.0
    
    // MARK: Layout
    
    override var collectionViewContentSize: CGSize {
        guard let unwrappedCollectionView = self.collectionView else {
            return CGSize.zero
        }
        
        let minimumHeight: CGFloat
        if #available(iOS 11.0, *) {
            minimumHeight = unwrappedCollectionView.bounds.height - (unwrappedCollectionView.safeAreaInsets.bottom + unwrappedCollectionView.safeAreaInsets.top)
        } else {
            minimumHeight = unwrappedCollectionView.bounds.height
        }
        return CGSize(width: unwrappedCollectionView.bounds.width, height: max(self.contentHeight, minimumHeight))
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
        
        unwrappedCollectionView.layoutIfNeeded()
        
        var layoutAttributes = [IndexPath : UICollectionViewLayoutAttributes]()
        let numberOfItems = unwrappedCollectionView.numberOfItems(inSection: 0)
        var nextYCoor: CGFloat = 0.0
        
        for index in 0..<numberOfItems {
            guard let unwrappedDelegate = self.delegate else
            {
                continue
            }
            
            let indexPath = IndexPath(row: index, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let isLastItem = index == numberOfItems - 1
            
            var height: CGFloat
            if !selectedIndexPaths.contains(indexPath)
            {
                height = unwrappedDelegate.expandedHeightForItem(at: indexPath, in: unwrappedCollectionView)
                
                // If not the last item, add extra height so that the next cell
                // has space to overlap and not obstruct the cell details
                if !isLastItem {
                    height += self.itemOverlap
                }
            }
            else
            {
                height = unwrappedDelegate.closedHeightForItem(at: indexPath, in: unwrappedCollectionView)
            }
            
            attributes.frame = CGRect(x: 0.0, y: nextYCoor, width: unwrappedCollectionView.bounds.width, height: height)
            attributes.zIndex = index
            attributes.transform3D = CATransform3DMakeTranslation(0.0, 0.0, CGFloat(index - numberOfItems))
            
            // Collection view is at the top and the user continues to pull down
            if (unwrappedCollectionView.contentOffset.y + unwrappedCollectionView.contentInset.top < 0.0) {
                var frame = attributes.frame
                frame.origin.y -= self.stretchValue * unwrappedCollectionView.contentOffset.y * CGFloat(index)
                
                attributes.frame = frame
            }
            
            self.contentHeight = nextYCoor + height
            nextYCoor = nextYCoor + height - self.itemOverlap
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
