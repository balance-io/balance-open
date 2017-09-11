//
//  TokenTextField.swift
//  Bal
//
//  Created by Benjamin Baron on 11/28/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Cocoa

class TokenTextField: TextField {
    static let RoundedBackgroundColorAttributeName = NSAttributedStringKey("RoundedBackgroundColorAttributeName")
    static let LeftRoundedBackgroundColorAttributeName = NSAttributedStringKey("LeftRoundedBackgroundColorAttributeName")
    static let RightRoundedBackgroundColorAttributeName = NSAttributedStringKey("RightRoundedBackgroundColorAttributeName")
    
    var textCornerRadius: CGFloat = 4.5
    var kerningOffset: CGFloat = 0.0 // Temporary hack
    
    fileprivate var fieldEditorOrigin = NSZeroPoint
    
    override func draw(_ dirtyRect: CGRect) {
        let centeredBounds = NSRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: self.bounds.height)
        
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
                for (index, run) in runs.enumerated() {
                    let stringRange = CTRunGetStringRange(run)
                    var ascent: CGFloat = 0
                    var descent: CGFloat = 0
                    var leading: CGFloat = 0
                    let typographicBounds = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading)
                    let xOffset = CTLineGetOffsetForStringIndex(line, stringRange.location, nil) + (index == 0 ? 0.0 : kerningOffset)
                    ctx.textPosition = CGPoint(x: lineOrigin.x, y: lineOrigin.y + descent)
                    let currentLineHeight = ascent + descent + leading
                    if currentLineHeight > lineHeight {
                        lineHeight = currentLineHeight
                    }
                    let runBounds = NSIntegralRect(NSRect(x: lineOrigin.x + xOffset, y: lineOrigin.y, width: CGFloat(typographicBounds), height: ascent + descent))
                    let attributes = CTRunGetAttributes(run) as! [NSAttributedStringKey: Any]
                    if let color = attributes[TokenTextField.RoundedBackgroundColorAttributeName] as? NSColor {
                        let adjustedRunBounds = NSRect(x: runBounds.origin.x - 1.0 - fieldEditorOrigin.x + textInsets.left,
                                                       y: textInsets.top,
                                                       width: runBounds.size.width + 5.5,
                                                       height: self.bounds.size.height)
                        let path = NSBezierPath(roundedRect: adjustedRunBounds, xRadius: textCornerRadius, yRadius: textCornerRadius)
                        color.setFill()
                        path.fill()
                    }
                    
//                    if let color = attributes[TokenTextField.LeftRoundedBackgroundColorAttributeName] as? NSColor {
//                        let adjustedRunBounds = NSRect(x: runBounds.origin.x + 0.5 - fieldEditorOrigin.x,
//                                                       y: 0,
//                                                       width: runBounds.size.width + 5.0,
//                                                       height: 19.0)
//                        let path = NSBezierPath(roundedRect: adjustedRunBounds, xRadius: textCornerRadius, yRadius: textCornerRadius)
//                        
//                        color.setFill()
//                        path.fill()
//                    }
//                    
//                    if let color = attributes[TokenTextField.RightRoundedBackgroundColorAttributeName] as? NSColor {
//                        let adjustedRunBounds = NSRect(x: runBounds.origin.x + 2.0 - fieldEditorOrigin.x,
//                                                       y: 0,
//                                                       width: runBounds.size.width + 3.5,
//                                                       height: 19.0)
//                        let path = NSBezierPath(roundedRect: adjustedRunBounds, xRadius: textCornerRadius, yRadius: textCornerRadius)
//                        
//                        color.setFill()
//                        path.fill()
//                    }
                    //CTRunDraw(run, ctx, CFRangeMake(0, 0))
                }
            }
            ctx.restoreGState()
        }
        
        super.draw(dirtyRect)
    }
    
    func textView(_ textView: NSTextView, willChangeSelectionFromCharacterRange oldSelectedCharRange: NSRange, toCharacterRange newSelectedCharRange: NSRange) -> NSRange {
        startWatchingBounds(textView: textView)
        return newSelectedCharRange
    }
    
    override func textDidBeginEditing(_ notification: Notification) {
        super.textDidBeginEditing(notification)
        startWatchingBounds()
    }
    
    override func textDidEndEditing(_ notification: Notification) {
        super.textDidEndEditing(notification)
        fieldEditorOrigin = NSZeroPoint
        self.needsDisplay = true
        stopWatchingBounds()
    }
    
    // TODO: See if we need to stop this notification observer (or does the view just get deallocated)
    fileprivate var isWatchingBounds = false
    fileprivate var containerView: NSView?
    fileprivate func startWatchingBounds(textView: NSTextView? = nil) {
        let fieldEditor = textView ?? self.window?.fieldEditor(false, for: self)
        if let container = fieldEditor?.superview {
            container.postsBoundsChangedNotifications = true
            containerView = container
        }
        
        if !isWatchingBounds {
            isWatchingBounds = true
            NotificationCenter.addObserverOnMainThread(self, selector: #selector(boundsDidChange(_:)), name: NSView.boundsDidChangeNotification)
        }
    }
    
    fileprivate func stopWatchingBounds() {
        if isWatchingBounds {
            isWatchingBounds = false
            NotificationCenter.removeObserverOnMainThread(self, name: NSView.boundsDidChangeNotification)
        }
    }
    
    @objc fileprivate func boundsDidChange(_ notification: Notification) {
        if let containerView = containerView, notification.object as? NSView == containerView {
            fieldEditorOrigin = containerView.bounds.origin
            self.needsDisplay = true
        }
    }
}
