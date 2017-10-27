//
//  StackedCollectionView.swift
//  CardCollectionViewLayout
//
//  Created by Red Davis on 26/10/2017.
//  Copyright © 2017 Red Davis LTD. All rights reserved.
//

import Cocoa

final class StackedCollectionView: NSCollectionView {
    override func mouseDown(with event: NSEvent) {
        let locationInWindow = event.locationInWindow
        let locationInView = self.convert(locationInWindow, to: nil)
        
        guard let indexPath = self.indexPathForItem(at: locationInView) else {
            super.mouseDown(with: event)
            return
        }
        
        if self.selectionIndexPaths.contains(indexPath) {
            self.deselectItems(at: Set([indexPath]))
        } else {
            self.selectItems(at: Set([indexPath]), scrollPosition: [])
        }
        
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.25
            context.allowsImplicitAnimation = true
            
            self.collectionViewLayout?.invalidateLayout()
            self.layoutSubtreeIfNeeded()
        }, completionHandler: nil)
    }
}
