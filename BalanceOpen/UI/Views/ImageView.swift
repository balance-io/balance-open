//
//  ImageView.swift
//  Bal
//
//  Created by Benjamin Baron on 7/18/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import AppKit

class ImageView: NSImageView {
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
