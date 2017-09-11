//
//  NSWindow.swift
//  Bal
//
//  Created by Benjamin Baron on 8/5/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Cocoa

extension NSWindow {
    // Adapted from http://stackoverflow.com/a/36006764/299262
    func shake(numberOfShakes: Int = 3, durationOfShake: Double = 0.5, vigorOfShake: CGFloat = 0.03) {
        let frame = self.frame
        let shakeAnimation  = CAKeyframeAnimation()
        
        let shakePath = CGMutablePath()
        shakePath.move(to: CGPoint(x: NSMinX(frame), y: NSMinY(frame)))
        for _ in 0...numberOfShakes-1 {
            shakePath.addLine(to: CGPoint(x: NSMinX(frame) - frame.size.width * vigorOfShake, y: NSMinY(frame)))
            shakePath.addLine(to: CGPoint(x: NSMinX(frame) + frame.size.width * vigorOfShake, y: NSMinY(frame)))
        }
        
        shakePath.closeSubpath();
        shakeAnimation.path = shakePath
        shakeAnimation.duration = durationOfShake
        
        self.animations = [NSAnimatablePropertyKey(rawValue: "frameOrigin"): shakeAnimation]
        self.animator().setFrameOrigin(self.frame.origin)
    }
}
