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
    weak var delegate: StackedLayoutDelegate?
    
    // Private
    private let stretchValue: CGFloat = 0
    private let itemOverlap: CGFloat = 40.0
    private var layoutAttributes = [IndexPath : UICollectionViewLayoutAttributes]()
    private var previousLayoutAttributes = [IndexPath : UICollectionViewLayoutAttributes]()
    private var contentHeight: CGFloat = 0.0
    
    // MARK: Layout
    
    override var collectionViewContentSize: CGSize {
        guard let unwrappedCollectionView = collectionView else {
            return .zero
        }
        
        let minimumHeight: CGFloat
        if #available(iOS 11.0, *) {
            minimumHeight = unwrappedCollectionView.bounds.height - (unwrappedCollectionView.safeAreaInsets.bottom + unwrappedCollectionView.safeAreaInsets.top)
        } else {
            minimumHeight = unwrappedCollectionView.bounds.height
        }
        return CGSize(width: unwrappedCollectionView.bounds.width, height: max(contentHeight, minimumHeight))
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    internal override func prepare() {
        super.prepare()
        
        guard let collectionView = self.collectionView, let selectedIndexPaths = collectionView.indexPathsForSelectedItems else {
            return
        }
        
        collectionView.layoutIfNeeded()
        
        var layoutAttributes = [IndexPath : UICollectionViewLayoutAttributes]()
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        var nextYCoor: CGFloat = 0.0
        
        for index in 0 ..< numberOfItems {
            guard let delegate = delegate else {
                continue
            }
            
            let indexPath = IndexPath(row: index, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let isLastItem = index == numberOfItems - 1
            
            var height: CGFloat
            if !selectedIndexPaths.contains(indexPath) {
                height = delegate.expandedHeightForItem(at: indexPath, in: collectionView)
                
                // If not the last item, add extra height so that the next cell
                // has space to overlap and not obstruct the cell details
                if !isLastItem {
                    height += self.itemOverlap
                }
            } else {
                height = delegate.closedHeightForItem(at: indexPath, in: collectionView)
            }
            
            attributes.frame = CGRect(x: 0.0, y: nextYCoor, width: collectionView.bounds.width, height: height)
            attributes.zIndex = index
            attributes.transform3D = CATransform3DMakeTranslation(0.0, 0.0, CGFloat(index - numberOfItems))
            
            // Collection view is at the top and the user continues to pull down
            if (collectionView.contentOffset.y + collectionView.contentInset.top < 0.0) {
                attributes.frame.origin.y -= stretchValue * collectionView.contentOffset.y * CGFloat(index)
            }
            
            contentHeight = nextYCoor + height
            nextYCoor += (height - itemOverlap)
            layoutAttributes[indexPath] = attributes
        }
        
        previousLayoutAttributes = layoutAttributes
        self.layoutAttributes = layoutAttributes
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return previousLayoutAttributes[itemIndexPath]
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributes[itemIndexPath]
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributes[indexPath]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = layoutAttributes.filter {
            rect.intersects($1.frame)
        }.values
        
        return Array(attributes)
    }
}
