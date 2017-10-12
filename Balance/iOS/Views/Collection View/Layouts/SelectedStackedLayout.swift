//
//  SelectedStackedLayout.swift
//  BalanceiOS
//
//  Created by Red Davis on 11/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


internal final class SelectedStackedLayout: UICollectionViewLayout {
    // Internal
    internal let selectedIndexPath: IndexPath
    
    // Private
    private var layoutAttributes = [IndexPath : UICollectionViewLayoutAttributes]()
    
    private let closedItemHeight: CGFloat = 120.0
    private let closedItemReveal: CGFloat = 10.0
    
    // MARK: Initialization
    
    internal required init(indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        super.init()
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: Layout
    
    override var collectionViewContentSize: CGSize {
        guard let unwrappedCollectionView = self.collectionView else {
            return .zero
        }
        
        var size = unwrappedCollectionView.bounds.size
        size.height -= unwrappedCollectionView.safeAreaInsets.bottom + unwrappedCollectionView.safeAreaInsets.top
        
        return size
    }
    
    internal override func prepare() {
        guard let unwrappedCollectionView = self.collectionView else {
            return
        }
        
        var layoutAttributes = [IndexPath : UICollectionViewLayoutAttributes]()
        let numberOfItems = unwrappedCollectionView.numberOfItems(inSection: 0)
        
        var numberOfStackedCards = 0
        for index in 0..<numberOfItems {
            let indexPath = IndexPath(row: index, section: 0)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.zIndex = index
            attributes.transform3D = CATransform3DMakeTranslation(0.0, 0.0, CGFloat(index - numberOfItems))
            
            if index != self.selectedIndexPath.row {
                let yOrigin = self.collectionViewContentSize.height - self.closedItemHeight + (CGFloat(numberOfStackedCards) * self.closedItemReveal)
                attributes.frame = CGRect(x: 0.0, y: yOrigin, width: unwrappedCollectionView.bounds.width, height: self.closedItemHeight)

                numberOfStackedCards += 1
            } else {
                guard let cell = unwrappedCollectionView.cellForItem(at: indexPath) else {
                    continue
                }
                
                attributes.frame = CGRect(x: 0.0, y: 0.0, width: unwrappedCollectionView.bounds.width, height: cell.intrinsicContentSize.height)
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
