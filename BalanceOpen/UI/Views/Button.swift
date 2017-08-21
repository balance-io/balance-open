//
//  Button.swift
//  Bal
//
//  Created by Benjamin Baron on 6/7/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import AppKit

class Button: NSButton {
    var object: Any?
    
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
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: Actions
    
    internal func set(target: AnyObject, action: Selector) {
        self.target = target
        self.action = action
    }
}
