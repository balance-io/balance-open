//
//  ComboBox.swift
//  Bal
//
//  Created by Benjamin Baron on 2/23/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import AppKit

class ComboBox: NSComboBox {    
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
