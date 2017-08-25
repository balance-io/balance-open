//
//  NSTextView.swift
//  Bal
//
//  Created by Benjamin Baron on 12/11/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

// Fix for touch bar being overridden when using text fields
extension NSTextView {
    @available(OSX 10.12.2, *)
    override open func makeTouchBar() -> NSTouchBar? {
        let touchBar = super.makeTouchBar()
        touchBar?.delegate = self
        return touchBar
    }
}
