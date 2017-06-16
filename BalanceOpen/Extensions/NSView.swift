//
//  NSView.swift
//  Bal
//
//  Created by Benjamin Baron on 5/23/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import AppKit
import SnapKit

enum ViewAnimation {
    case none
    case slideInFromLeft
    case slideInFromRight
    case fade
}

extension NSView {
    var layerBackgroundColor: NSColor? {
        get {
            if let backgroundColor = self.layer?.backgroundColor {
                return NSColor(cgColor: backgroundColor)
            } else {
                return nil
            }
        }
        set {
            self.layer?.backgroundColor = newValue?.cgColor
        }
    }
    
    var cornerRadius: Float {
        get {
            if let layer = self.layer {
                return Float(layer.cornerRadius)
            } else {
                return 0.0
            }
        }
        set {
            self.layer?.cornerRadius = CGFloat(newValue)
        }
    }
    
    var borderWidth: Float {
        get {
            if let layer = self.layer {
                return Float(layer.borderWidth)
            } else {
                return 0.0
            }
        }
        set {
            self.layer?.borderWidth = CGFloat(newValue)
        }
    }
    
    var borderColor: NSColor? {
        get {
            if let borderColor = self.layer?.borderColor {
                return NSColor(cgColor: borderColor)
            } else {
                return nil
            }
        }
        set {
            self.layer?.borderColor = newValue?.cgColor
        }
    }
    
    func replaceSubview(_ oldView: NSView, with newView: NSView, animation: ViewAnimation, duration: Double = 0.2, constraints: ((_ make: ConstraintMaker) -> Void)? = nil, completionHandler: (() -> Void)? = nil) {
        let makeConstraints = {
            newView.snp.makeConstraints { make in
                if let constraints = constraints {
                    constraints(make)
                } else {
                    make.leading.equalTo(self)
                    make.trailing.equalTo(self)
                    make.top.equalTo(self)
                    make.bottom.equalTo(self)
                }
            }
        }
        
        if animation == .none {
            // Attempt to fix occational constraint crash
            if oldView.superview == self {
                self.replaceSubview(oldView, with: newView)
            } else {
                self.addSubview(newView)
            }
            
            makeConstraints()
            completionHandler?()
        } else {
            let transition = CATransition()
            if animation == .slideInFromRight {
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromRight
            } else if animation == .slideInFromLeft {
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromLeft
            } else if animation == .fade {
                transition.type = kCATransitionFade
            }
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            self.animations = ["subviews": transition]
            
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = duration
                // Attempt to fix occational constraint crash
                if oldView.superview == self {
                    self.animator().replaceSubview(oldView, with: newView)
                } else {
                    self.animator().addSubview(newView)
                }
                makeConstraints()
            }, completionHandler: completionHandler)
        }
    }
}
