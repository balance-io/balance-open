//
//  InstitutionInitialsCircleView.swift
//  Bal
//
//  Created by Christian on 11/26/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Cocoa

class InstitutionInitialsCircleView: NSView {
    
    let initialsField = LabelField()
    
    var circleColor: NSColor? {
        didSet {
            self.needsDisplay = true
        }
    }
    
    var stringValue: String {
        get {
            return initialsField.stringValue
        } set {
            initialsField.stringValue = newValue
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame:frameRect)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        initialsField.font = CurrentTheme.transactions.cell.institutionInitialsFont
        initialsField.textColor = NSColor(deviceRedInt: 255, green: 255, blue: 255)
        //initialsField.textColor = CurrentTheme.transactions.cell.institutionInitialsColor
        initialsField.alignment = .center
        self.addSubview(initialsField)
        initialsField.snp.makeConstraints { make in
            make.width.equalTo(22)
            make.height.equalTo(12)
            make.centerX.equalTo(self)
            make.centerY.equalTo(self)
        }
        
//        let shadow = NSShadow()
//        shadow.shadowColor = CurrentTheme.defaults.foregroundColor.withAlphaComponent(0.5)
//        shadow.shadowOffset = NSMakeSize(0, 0)
//        shadow.shadowBlurRadius = 1
//        self.shadow = shadow
    }
    
    fileprivate let circlePath = NSBezierPath(ovalIn: NSRect(x: 0, y: 0, width: 22, height: 22))
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        circleColor?.setFill()
        circlePath.fill()
    }
}
