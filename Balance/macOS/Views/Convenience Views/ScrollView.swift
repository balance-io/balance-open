//
//  ScrollView.swift
//  Bal
//
//  Created by Benjamin Baron on 6/7/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import AppKit

class ScrollView: NSScrollView {
    var isUserInteractionEnabled = true
    var isScrollingEnabled = true
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        self.wantsLayer = true
        self.contentView.wantsLayer = true
        self.drawsBackground = false
        self.hasVerticalScroller = true
        self.hasHorizontalScroller = false
        self.automaticallyAdjustsContentInsets = false
    }
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        if isUserInteractionEnabled {
            return super.hitTest(point)
        }
        return nil
    }

    override func scrollWheel(with event: NSEvent) {
        if isScrollingEnabled {
            super.scrollWheel(with: event)
        }
    }
}
