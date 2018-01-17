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
    internal let stackedLayout = StackedLayout()

    // Private
    
    // MARK: Initialization
    
    internal required init() {
        super.init(frame: .zero, collectionViewLayout: stackedLayout)
        
        allowsMultipleSelection = true
        
        // Select item gesture
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(tapGestureEngaged))
        addGestureRecognizer(tapGesture)
        layer.cornerRadius = 20
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    
}

private extension StackedCardCollectionView {
    // MARK: Presentation
    
    // Gestures
    
    @objc private func tapGestureEngaged(_ gesture: UITapGestureRecognizer) {
        guard let indexPath = indexPathForItem(at: gesture.location(in: self)),
            let selectedIndexPaths = indexPathsForSelectedItems else {
                return
        }
        
        if selectedIndexPaths.contains(indexPath) {
            deselectItem(at: indexPath, animated: false)
        } else {
            selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
        
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: [.curveEaseInOut, .allowUserInteraction],
                       animations: {
                        self.collectionViewLayout.invalidateLayout()
                        self.layoutIfNeeded()
        }) { _ in
            self.delegate?.collectionView!(self, didSelectItemAt: indexPath)
        }
    }

}
