//
//  RoundedBackgroundAttributeView.swift
//  Bal
//
//  Created by Benjamin Baron on 11/27/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Cocoa

// Adapted from https://github.com/MrMatthias/BackgroundDrawingAttribute/blob/master/BackgroundDrawingAttribute/BackgroundAttributeView.swift
class RoundedBackgroundAttributeView: View {
    
    static let RoundedBackgroundColorAttributeName = "RoundedBackgroundColorAttributeName"
    
    var verticalAlignment: VerticalAlignment = .default
    
    var textCornerRadius: CGFloat = 5.0
    
    var attributedStringValue: NSAttributedString? {
        didSet {
            self.needsDisplay = true
        }
    }
    
    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)
        
        guard let attributedStringValue = attributedStringValue else {
            return
        }
        
        let centeredBounds = titleRect(forBounds: self.bounds)
        let frameSetter = CTFramesetterCreateWithAttributedString(attributedStringValue)
        let framePath = CGMutablePath()
        framePath.addRect(centeredBounds)
        let ctFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), framePath, nil)
        if let ctx = NSGraphicsContext.current?.cgContext {
            let lines = CTFrameGetLines(ctFrame) as NSArray
            guard lines.count > 0 else {
                super.draw(dirtyRect)
                return
            }
            
            ctx.saveGState()
            
            ctx.textMatrix = .identity
            ctx.translateBy(x: 0, y: centeredBounds.origin.y)
            
            var lineOrigins = [CGPoint](repeating: CGPoint.zero, count: lines.count)
            CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), &lineOrigins)
            var lineHeight: CGFloat = 0
            for i in 0..<lines.count {
                let line = lines[i] as! CTLine
                let lineOrigin = lineOrigins[i]
                
                let runs = CTLineGetGlyphRuns(line) as! [CTRun]
                for run in runs {
                    let stringRange = CTRunGetStringRange(run)
                    var ascent: CGFloat = 0
                    var descent: CGFloat = 0
                    var leading: CGFloat = 0
                    let typographicBounds = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading)
                    let xOffset = CTLineGetOffsetForStringIndex(line, stringRange.location, nil)
                    ctx.textPosition = CGPoint(x: lineOrigin.x, y: lineOrigin.y + descent)
                    let currentLineHeight = ascent + descent + leading
                    if currentLineHeight > lineHeight {
                        lineHeight = currentLineHeight
                    }
                    let runBounds = NSRect(x: lineOrigin.x + xOffset, y: lineOrigin.y, width: CGFloat(typographicBounds), height: ascent + descent)
                    let attributes = CTRunGetAttributes(run) as! [String: AnyObject]
                    if let color = attributes[RoundedBackgroundAttributeView.RoundedBackgroundColorAttributeName] as? NSColor {
                        let sizeIncrease: CGFloat = 4.0
                        let adjustedRunBounds = NSRect(x: runBounds.origin.x - sizeIncrease, y: runBounds.origin.y - sizeIncrease, width: runBounds.size.width + (sizeIncrease * 2), height: runBounds.size.height + (sizeIncrease * 2))
                        let path = NSBezierPath(roundedRect: adjustedRunBounds, xRadius: textCornerRadius, yRadius: textCornerRadius)
                        color.setFill()
                        path.fill()
                    }
                    CTRunDraw(run, ctx, CFRangeMake(0, 0))
                }
            }
            ctx.restoreGState()
        }
    }
    
    // Doesn't center correctly
    func titleRect(forBounds theRect: NSRect) -> NSRect {
        if verticalAlignment != .default, let attributedStringValue = attributedStringValue {
            // Get the standard text content rectangle
            var titleFrame = theRect
            
            // Find out how big the rendered text will be
            let options: NSString.DrawingOptions = [NSString.DrawingOptions.truncatesLastVisibleLine, NSString.DrawingOptions.usesLineFragmentOrigin]
            let textRect = attributedStringValue.boundingRect(with: titleFrame.size, options: options)
            
            // If the height of the rendered text is less then the available height,
            // we modify the titleRect to align the text appropriately
            if textRect.size.height < titleFrame.size.height {
                switch verticalAlignment {
                case .top:
                    titleFrame.origin.y = theRect.origin.y
                case .bottom:
                    // Subtract 1 point from the y origin to align labels with bezeled text fields and combo boxes
                    titleFrame.origin.y = theRect.origin.y + (theRect.size.height - textRect.size.height) - 1.0
                case .center:
                    titleFrame.origin.y = theRect.origin.y + (theRect.size.height - textRect.size.height) / 2.0
                default: break
                }
                titleFrame.size.height = textRect.size.height
            }
            
            return titleFrame;
        }
        
        return theRect
    }
}
