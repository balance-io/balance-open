//
//  StackedLayout.swift
//  CardCollectionViewLayout
//
//  Created by Red Davis on 26/10/2017.
//  Copyright © 2017 Red Davis LTD. All rights reserved.
//

import Cocoa


protocol StackedLayoutDelegate: class {
    func closedHeightForItem(at indexPath: IndexPath, in collectionView: NSCollectionView) -> CGFloat
    func expandedHeightForItem(at indexPath: IndexPath, in collectionView: NSCollectionView) -> CGFloat
}


final class StackedLayout: NSCollectionViewLayout {
    weak var delegate: StackedLayoutDelegate?
    
    private var layoutAttributes = [IndexPath : NSCollectionViewLayoutAttributes]()
    private var previousLayoutAttributes = [IndexPath : NSCollectionViewLayoutAttributes]()
    private let stretchValue: CGFloat = 0.2
    
    private let afterSelectedItemOverlapHeight: CGFloat = 60.0
    private let afterUnselectedItemOverlapHeight: CGFloat = 40.0
    private var contentHeight: CGFloat = 0.0
    
    // MARK: Layout
    
    override var collectionViewContentSize: NSSize {
        guard let collectionView = self.collectionView else {
            return .zero
        }
        
        let height = max(self.contentHeight, collectionView.bounds.height)
        return CGSize(width: collectionView.bounds.width, height: height)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: NSRect) -> Bool {
        return true
    }
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = self.collectionView else {
            return
        }

        let selectedIndexPaths = collectionView.selectionIndexPaths
        var newLayoutAttributes = [IndexPath : NSCollectionViewLayoutAttributes]()
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        var nextYCoor: CGFloat = 0.0

        for index in 0 ..< numberOfItems {
            let indexPath = IndexPath(item: index, section: 0)
            let attributes = NSCollectionViewLayoutAttributes(forItemWith: indexPath)
            
            guard let delegate = self.delegate else {
                continue
            }
            
            let height: CGFloat
            let nextOverlap: CGFloat
            if selectedIndexPaths.contains(indexPath) {
                height = delegate.expandedHeightForItem(at: indexPath, in: collectionView)
                nextOverlap = 40.0
            } else {
                height = delegate.closedHeightForItem(at: indexPath, in: collectionView)
                nextOverlap = 40.0
            }
            
            contentHeight = nextYCoor + height

            attributes.frame = CGRect(x: 0.0, y: nextYCoor, width: collectionView.bounds.width, height: height)
            attributes.zIndex = index

            if let scrollView = collectionView.enclosingScrollView, scrollView.documentVisibleRect.minY + scrollView.contentInsets.top < 0.0 {
                var frame = attributes.frame
                frame.origin.y -= stretchValue * scrollView.documentVisibleRect.minY * CGFloat(index)

                attributes.frame = frame
            }
            
            nextYCoor = nextYCoor + height - nextOverlap
            newLayoutAttributes[indexPath] = attributes
        }

        previousLayoutAttributes = layoutAttributes
        layoutAttributes = newLayoutAttributes
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        return previousLayoutAttributes[itemIndexPath]
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        return layoutAttributes[itemIndexPath]
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        return layoutAttributes[indexPath]
    }
    
    override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        let attributes = layoutAttributes.filter({rect.intersects($1.frame)}).values
        return Array(attributes)
    }
}
