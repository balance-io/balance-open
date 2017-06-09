//
//  VerticallyCenteredLabelField.swift
//  Bal
//
//  Created by Benjamin Baron on 6/7/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import AppKit

/// Non-editable text field (use like UILabel), vertically centerable, not selectable by default
class LabelField: TextField {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        self.isBezeled = false
        self.isEditable = false
        self.isSelectable = false
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
