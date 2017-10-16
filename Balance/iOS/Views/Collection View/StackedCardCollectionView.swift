//
//  StackedCardCollectionView.swift
//  BalanceiOS
//
//  Created by Red Davis on 12/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


internal class StackedCardCollectionView: UICollectionView {
    // Internal
    
    // Private
    private let stackedLayout = StackedLayout()
    
    // MARK: Initialization
    
    internal required init() {
        super.init(frame: .zero, collectionViewLayout: self.stackedLayout)
        
        self.allowsMultipleSelection = true
        
        // Select item gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureEngaged(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: Presentation
    
    // Gestures
    
    @objc private func tapGestureEngaged(_ gesture: UITapGestureRecognizer) {
        guard let indexPath = self.indexPathForItem(at: gesture.location(in: self)),
              let selectedIndexPaths = self.indexPathsForSelectedItems else {
            return
        }
        
        if selectedIndexPaths.contains(indexPath)
        {
            self.deselectItem(at: indexPath, animated: false)
            
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [.curveEaseInOut, .allowUserInteraction], animations: {
                self.collectionViewLayout.invalidateLayout()
                self.layoutIfNeeded()
            }, completion: { (_) in
                self.delegate?.collectionView!(self, didDeselectItemAt: indexPath)
            })
        }
        else
        {
            self.selectItem(at: indexPath, animated: false, scrollPosition: [])
            
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [.curveEaseInOut, .allowUserInteraction], animations: {
                self.collectionViewLayout.invalidateLayout()
                self.layoutIfNeeded()
            }, completion: { (_) in
                self.delegate?.collectionView!(self, didSelectItemAt: indexPath)
            })
        }
    }
}
