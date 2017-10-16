//
//  PaintCodeView.swift
//  BalanceiOS
//
//  Created by Red Davis on 16/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit

internal class PaintCodeView: UIView {
    // Internal
    internal var drawingBlock: ((_ frame: CGRect) -> Void)? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    // MARK: Drawing
    
    internal override func draw(_ rect: CGRect) {
        self.drawingBlock?(rect)
    }
}
