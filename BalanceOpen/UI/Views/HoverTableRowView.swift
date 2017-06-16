//
//  HoverTableRowView.swift
//  Bal
//
//  Created by Benjamin Baron on 5/28/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import AppKit

class HoverTableRowView: TableRowView {
    
    var color = NSColor.clear {
        didSet {
            currentColor = color
            backgroundColor = color
        }
    }
    var hoverColor = NSColor(deviceWhiteInt: 255, alpha: 0.15)
    var currentColor = NSColor.clear
    var hovering = false {
        didSet {
            currentColor = hovering ? hoverColor : color
            backgroundColor = currentColor
            
            // Update cell background
            if let cell = self.subviews.first {
                cell.layerBackgroundColor = backgroundColor
            }
            
            // Update any subviews that are text fields so we get proper antialiasing on 1x screens
            // NOTE: The hoverColor must have an alpha value of 1.0 or this will not look right
            func updateSubviews(_ subviews: [NSView]) {
                for view in subviews {
                    if let textField = view as? TextField, textField.backgroundColor != nil && textField.backgroundColor == (hovering ? color : hoverColor) {
                        textField.backgroundColor = backgroundColor
                    }
                    
                    updateSubviews(view.subviews)
                }
            }
            updateSubviews(self.subviews)
        }
    }
    
    // Ignore backgroundColor because NSTableView likes to overwrite it
    override var backgroundColor: NSColor {
        get {
            return currentColor
        }
        set {
            super.backgroundColor = newValue
        }
    }
    
    // Override this because NSTableView will wipe out any backgroundColor we set on init. So we'll do it our way. Fucking AppKit...
    override func drawBackground(in dirtyRect: NSRect) {
        currentColor.setFill()
        NSRectFill(dirtyRect)
    }
}
