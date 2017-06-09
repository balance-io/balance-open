//
//  NSImage.swift
//  Bal
//
//  Created by Benjamin Baron on 9/10/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Cocoa

extension NSImage {
    func alphaImage(_ alpha: CGFloat) -> NSImage {
        let image = NSImage(size: self.size)
        image.lockFocus()
        self.draw(at: NSZeroPoint, from: NSZeroRect, operation: .sourceOver, fraction: alpha)
        image.unlockFocus()
        return image
    }
    
    // Simple image clipping
    func clippedImage(_ newSize: CGSize, startPoint: NSPoint = NSZeroPoint) -> NSImage {
        guard newSize.height <= self.size.height && newSize.width <= self.size.width else {
            return self
        }
        
        var point = startPoint
        if point == NSZeroPoint {
            // Calculate point so it draws from the top left
            point.y = newSize.height - self.size.height
        }
        
        let image = NSImage(size: newSize)
        image.lockFocus()
        self.draw(at: point, from: NSZeroRect, operation: .sourceOver, fraction: 1.0)
        image.unlockFocus()
        return image
    }
}
