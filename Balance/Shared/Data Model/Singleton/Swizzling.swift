//
//  Swizzling.swift
//  Bal
//
//  Created by Benjamin Baron on 4/5/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

#if os(OSX)
import AppKit
#else
import UIKit
#endif

fileprivate func swizzling(forClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
    let originalMethod = class_getInstanceMethod(forClass, originalSelector)
    let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector)
    method_exchangeImplementations(originalMethod!, swizzledMethod!)
}

fileprivate var hasSwizzled = false
func swizzleMethods() {
    if !hasSwizzled {
        hasSwizzled = true
        
        #if os(OSX)
        NSEvent.swizzle()
        #endif
    }
}

#if os(OSX)
extension NSEvent {
    fileprivate class func swizzle() {
        let originalSelector = #selector(getter: hasPreciseScrollingDeltas)
        let swizzledSelector = #selector(swizzled_hasPreciseScrollingDeltas)
        swizzling(forClass: self, originalSelector: originalSelector, swizzledSelector: swizzledSelector)
    }
    
    // Fix AppKit's broken mouse scrolling (it was scrolling pages at a time)
    @objc fileprivate func swizzled_hasPreciseScrollingDeltas() -> Bool {
        return true
    }
}
#endif
