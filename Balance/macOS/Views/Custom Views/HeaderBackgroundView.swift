//
//  HeaderBackgroundView.swift
//  Bal
//
//  Created by Christian on 12/2/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Cocoa

class HeaderBackgroundView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        let grad = NSGradient(starting: CurrentTheme.tabs.header.bottomColor, ending: CurrentTheme.tabs.header.topColor)
        grad?.draw(in: self.frame, angle: -90)
    }
}
