//
//  StackedCardCollectionView.swift
//  BalanceiOS
//
//  Created by Red Davis on 12/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


internal class StackedCardCollectionView: UICollectionView {
    // Private
    private var stackedLayout = StackedLayout()
    
    private var selectedItemIndexPath: IndexPath? {
        guard let selectedStackLayout = self.collectionViewLayout as? SelectedStackedLayout else {
            return nil
        }
        
        return selectedStackLayout.selectedIndexPath
    }
    
    private var isItemSelected: Bool {
        return self.selectedItemIndexPath != nil
    }
    
    // MARK: Initialization
    
    internal required init() {
        super.init(frame: .zero, collectionViewLayout: self.stackedLayout)
        
        // Select item gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureEngaged(_:)))
        self.addGestureRecognizer(tapGesture)
        
        // Dismiss with drag gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureEngaged(_:)))
        panGesture.delegate = self
        self.addGestureRecognizer(panGesture)
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: Presentation
    
    private func closeStack() {
        self.setCollectionViewLayout(self.stackedLayout, animated: true)
    }
    
    // Gestures
    
    @objc private func tapGestureEngaged(_ gesture: UITapGestureRecognizer) {
        guard let indexPath = self.indexPathForItem(at: gesture.location(in: self)) else {
            if let indexPath = self.selectedItemIndexPath {
                self.closeStack()
                self.delegate?.collectionView!(self, didDeselectItemAt: indexPath)
            }
            
            return
        }
        
        if indexPath != self.selectedItemIndexPath {
            let selectedStackedLayout = SelectedStackedLayout(indexPath: indexPath)
            self.setCollectionViewLayout(selectedStackedLayout, animated: true)
            
            self.delegate?.collectionView!(self, didSelectItemAt: indexPath)
        }
    }
    
    @objc private func panGestureEngaged(_ gesture: UIPanGestureRecognizer) {
        if !self.isItemSelected {
            return
        }
        
        switch gesture.state {
        case .ended:
            let translation = gesture.translation(in: self)
            
            if translation.y > 100.0 {
                self.closeStack()
            }
        default:()
        }
    }
}

// MARK: UIGestureRecognizerDelegate

extension StackedCardCollectionView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
