//
//  PaintCodeView.swift
//  Bal
//
//  Created by Benjamin Baron on 11/16/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Cocoa

class PaintCodeView: View {
    typealias DrawingBlock = (_ frame: NSRect) -> (Void)
    
    var drawingBlock: DrawingBlock? {
        didSet {
            self.needsDisplay = true
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        drawingBlock?(self.bounds)
    }
}
