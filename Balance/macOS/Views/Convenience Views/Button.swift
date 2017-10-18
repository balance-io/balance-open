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
    
    var titleColor: NSColor? {
        didSet {
            if let titleColor = titleColor {
                let attributedString = NSMutableAttributedString(attributedString: self.attributedStringValue)
                let range = NSRange(location: 0, length: self.title.length)
                attributedString.addAttribute(.foregroundColor, value: titleColor, range: range)
                self.attributedTitle = attributedString
            }
        }
    }
    
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
}
