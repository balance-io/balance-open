//
//  StackedCardCollectionView.swift
//  BalanceiOS
//
//  Created by Red Davis on 12/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit

final class StackedCardCollectionView: UICollectionView {
    let stackedLayout = StackedLayout()
        
    required init() {
        super.init(frame: .zero, collectionViewLayout: stackedLayout)
        
        self.allowsMultipleSelection = true
        self.layer.cornerRadius = 20
        
        // Select item gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction))
        self.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("unsupported")
    }
    
    func reloadData(shouldPersistSelection: Bool, with indexes: [IndexPath]) {
        self.reloadData()
        
        guard !indexes.isEmpty,
            shouldPersistSelection else {
            return
        }
        
        indexes.forEach {
            self.selectItem(at: $0, animated: false, scrollPosition: [])
        }
    }
    
    @objc private func tapGestureAction(_ gesture: UITapGestureRecognizer) {
        guard let indexPath = indexPathForItem(at: gesture.location(in: self)), let selectedIndexPaths = indexPathsForSelectedItems else {
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
        }, completion: { _ in
            self.delegate?.collectionView?(self, didSelectItemAt: indexPath)
        })
    }
}
