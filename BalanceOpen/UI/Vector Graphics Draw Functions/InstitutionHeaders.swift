//
//  InstitutionHeaders.swift
//  institutionheaders
//
//  Created by Benjamin Baron on 9/16/16.
//  Copyright © 2016 Balanced Software. All rights reserved.
//

import Cocoa

// Only need to create entries for primary institutions, the rest are looked up in the db
fileprivate let lookupTable: [String: DrawingFunction] = [
    "Coinbase":  InstitutionHeaderBars.drawCoinbase,
    "Poloniex":  InstitutionHeaderBars.drawPoloniex,
    "GDAX":      InstitutionHeaderBars.drawGdax,
    "Bitfinex":  InstitutionHeaderBars.drawBitfinex
]

public struct InstitutionHeaders {
    public static func headerViewForId(_ id: String) -> NSView? {
        if let drawingFunction = lookupTable[id] {
            return HeaderView(drawingFunction: drawingFunction)
        }
        
        return nil
    }
    
    public static func defaultHeaderView(backgroundColor: NSColor, foregroundColor: NSColor, font: NSFont, name: String) -> NSView? {
        let function = InstitutionHeaderBars.drawDefaultHeader(frame:backgroundColor:foregroundColor:font:name:)
        return HeaderView(colorDrawingFunction: function, backgroundColor: backgroundColor, foregroundColor: foregroundColor, font: font, name: name)
    }
}

fileprivate typealias ColorDrawingFunction = (_ frame: NSRect, _ backgroundColor: NSColor, _ foregroundColor: NSColor, _ font: NSFont, _ name: String) -> ()

fileprivate class HeaderView: NSView {
    fileprivate var drawingFunction: DrawingFunction?
    
    fileprivate var colorDrawingFunction: ColorDrawingFunction?
    fileprivate var backgroundColor: NSColor?
    fileprivate var foregroundColor: NSColor?
    fileprivate var font: NSFont?
    fileprivate var name: String?
    
    init(drawingFunction: @escaping DrawingFunction) {
        self.drawingFunction = drawingFunction
        super.init(frame: NSRect(x: 0, y: 0, width: 400, height: 28))
        self.wantsLayer = true
    }
    
    init(colorDrawingFunction: @escaping ColorDrawingFunction, backgroundColor: NSColor, foregroundColor: NSColor, font: NSFont, name: String) {
        self.colorDrawingFunction = colorDrawingFunction
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.font = font
        self.name = name
        super.init(frame: NSRect(x: 0, y: 0, width: 400, height: 28))
        self.wantsLayer = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate override func draw(_ dirtyRect: NSRect) {
        if let drawingFunction = drawingFunction {
            drawingFunction(self.bounds)
        }
        
        if let colorDrawingFunction = colorDrawingFunction, let backgroundColor = backgroundColor, let foregroundColor = foregroundColor, let font = font, let name = name {
            colorDrawingFunction(self.bounds, backgroundColor, foregroundColor, font, name)
        }
    }
}
