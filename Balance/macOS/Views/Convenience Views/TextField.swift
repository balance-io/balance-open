//
//  TextField.swift
//  Bal
//
//  Created by Benjamin Baron on 5/13/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//
//  Adapted from http://stackoverflow.com/a/9547002/299262
//

import Cocoa

enum VerticalAlignment {
    case `default`
    case top
    case bottom
    case center
}

@objc protocol TextFieldDelegate {
    func textFieldDidBecomeFirstResponder(_ textField: NSTextField)
}

class TextField: NSTextField {
    weak var customDelegate: TextFieldDelegate?
    
    var textInsets = NSEdgeInsetsZero
    
    var allowRichTextPasting = false
    
    var verticalAlignment: VerticalAlignment {
        get {
            if let cell = self.cell as? TextFieldCell {
                return cell.verticalAlignment
            } else {
                return .default
            }
        }
        set {
            if let cell = self.cell as? TextFieldCell {
                cell.verticalAlignment = newValue
                self.needsDisplay = true
            }
        }
    }
    
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
        self.backgroundColor = NSColor.clear
        self.drawsBackground = false
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let cell = self.cell as? TextFieldCell {
            cell.textField = self
        }
    }
    
    override class var cellClass: AnyClass? {
        get {
            return TextFieldCell.self
        }
        set { }
    }
    
    override func becomeFirstResponder() -> Bool {
        customDelegate?.textFieldDidBecomeFirstResponder(self)
        return super.becomeFirstResponder()
    }
}

fileprivate class TextFieldCell: NSTextFieldCell {
    var verticalAlignment: VerticalAlignment = .default
    weak var textField: TextField? = nil
    var fieldEditor: NSTextView?
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        // Fix subpixel antialiasing
        var backingScaleFactor = 1.0
        if let window = textField?.window {
            backingScaleFactor = Double(window.backingScaleFactor)
        }
        
        let titleRect = self.titleRect(forBounds: cellFrame)
        let frame = self.isEditable ? paddedRect(cellFrame) : titleRect
        if let context = NSGraphicsContext.current?.cgContext {
            // Save context state
            context.saveGState()
            
            if backingScaleFactor == 1.0 {
                // Subpixel antialiasing will turn on either way, but is vastly improved by setting a backgound color
                let backgroundColor = self.backgroundColor == NSColor.clear ? nil : self.backgroundColor
                if let backgroundCGColor = backgroundColor?.cgColor {
                    context.setFillColor(backgroundCGColor)
                    context.fill(frame)
                }
                
                // Enables subpixel antialiasing
                context.setShouldSmoothFonts(true)
            }
            
            // Draw the text
            super.drawInterior(withFrame: frame, in: controlView)
            
            // Restore context state
            context.restoreGState()
        } else {
            super.drawInterior(withFrame: frame, in: controlView)
        }
    }
    
    override func titleRect(forBounds theRect: NSRect) -> NSRect {
        var titleRect = super.titleRect(forBounds: theRect)
        if verticalAlignment != .default {
            // Find out how big the rendered text will be
            let attrString = self.attributedStringValue
            let options: NSString.DrawingOptions = [NSString.DrawingOptions.truncatesLastVisibleLine, NSString.DrawingOptions.usesLineFragmentOrigin]
            let textRect = attrString.boundingRect(with: titleRect.size, options: options)
            
            // If the height of the rendered text is less then the available height,
            // we modify the titleRect to align the text appropriately
            if textRect.size.height < titleRect.size.height {
                switch verticalAlignment {
                case .top:
                    titleRect.origin.y = theRect.origin.y
                case .bottom:
                    // Subtract 1 point from the y origin to align labels with bezeled text fields and combo boxes
                    titleRect.origin.y = theRect.origin.y + (theRect.size.height - textRect.size.height) - 1.0
                case .center:
                    titleRect.origin.y = theRect.origin.y + (theRect.size.height - textRect.size.height) / 2.0
                default: break
                }
                titleRect.size.height = textRect.size.height
            }
        }
        
        return paddedRect(titleRect)
    }
    
    override func edit(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
        super.edit(withFrame: paddedRect(rect), in: controlView, editor: textObj, delegate: delegate, event: event)
    }
    
    override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
        super.select(withFrame: paddedRect(rect), in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
    }
    
    func paddedRect(_ rect: NSRect) -> NSRect {
        var titleRect = rect
        if let textInsets = textField?.textInsets, !NSEdgeInsetsEqual(textInsets, NSEdgeInsetsZero) {
            titleRect.origin.x += textInsets.left
            titleRect.size.width -= (textInsets.left + textInsets.right)
            titleRect.origin.y += textInsets.top
            titleRect.size.height -= (textInsets.top + textInsets.bottom)
        }
        return titleRect
    }
    
    override func fieldEditor(for controlView: NSView) -> NSTextView? {
        if let textField = textField, textField.allowRichTextPasting {
            return super.fieldEditor(for: controlView)
        }
        
        if let fieldEditor = fieldEditor {
            return fieldEditor
        } else {
            fieldEditor = PlainTextPasteView()
            fieldEditor?.isFieldEditor = true
            return fieldEditor
        }
    }
}

fileprivate class PlainTextPasteView: NSTextView, NSTextViewDelegate {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override func paste(_ sender: Any?) {
        super.pasteAsPlainText(sender)
    }
}
