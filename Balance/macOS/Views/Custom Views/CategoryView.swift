//
//  CategoryView.swift
//  Bal
//
//  Created by Benjamin Baron on 5/12/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

/// Displays hierarchical list of categories horizontally 
class CategoryView: View {
    
    let colors = [NSColor(deviceRedInt: 45, green: 172, blue: 242),
                  NSColor(deviceRedInt: 31, green: 196, blue: 53),
                  NSColor(deviceRedInt: 150, green: 150, blue: 150)]
    
    var buttonHandler: ((_ name: String) -> Void)?
    
    var category: Category? {
        didSet {
            createButtons()
        }
    }
    
    fileprivate var buttons = [NSButton]()
    
    fileprivate func createButtons() {
        for button in buttons {
            button.removeFromSuperview()
        }
        buttons.removeAll()
        
        if let category = category {
            var i = 0
            for name in category.names {
                let color = colors.count > i ? colors[i] : NSColor.gray
                
                let button = CategoryViewButton()
                button.bezelStyle = .regularSquare
                button.setButtonType(.momentaryChange)
                button.isBordered = false
                button.isTransparent = false
                button.allowsMixedState = false
                button.layerBackgroundColor = color
                button.cornerRadius = 4.0
                //button.layer?.borderColor = color.darkerColor.CGColor
                //button.layer?.borderWidth = 1.0
                button.target = self
                button.action = #selector(buttonAction(_:))
                button.tag = i
                
                let attributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.foregroundColor: NSColor.white,
                                                                NSAttributedStringKey.font: NSFont.mediumSystemFont(ofSize: 11.5),
                                                                NSAttributedStringKey.paragraphStyle: centeredParagraphStyle,
                                                                NSAttributedStringKey.baselineOffset: 0.25]
                let attributedString = NSAttributedString(string: name, attributes: attributes)
                button.attributedTitle = attributedString
                
                self.addSubview(button)
                let size = (name as NSString).size(withAttributes: [NSAttributedStringKey.font: NSFont.mediumSystemFont(ofSize: 11.5)])
                button.snp.makeConstraints { make in
                    make.width.equalTo(size.width + 10)
                    make.height.equalTo(19)
                    make.centerY.equalTo(self)
                    if let previousButton = buttons.last {
                        make.leading.equalTo(previousButton.snp.trailing).offset(6)
                    } else {
                        make.leading.equalTo(self).offset(5)
                    }
                }
                
                buttons.append(button)
                i += 1
            }
        }
    }
    
    @objc fileprivate func buttonAction(_ sender: NSButton) {
        if let name = category?.names[sender.tag] {
            buttonHandler?(name)
        }
    }
}

private class CategoryViewButton: Button {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if let context = NSGraphicsContext.current?.cgContext {
            context.saveGState();
            
            var backingScaleFactor = 1.0
            if let window = self.window {
                backingScaleFactor = Double(window.backingScaleFactor)
            }
            
            // Fix font rendering on 1x and 2x screens
            context.setShouldSmoothFonts(backingScaleFactor == 1.0);
            
            // Draw the button.
            super.draw(dirtyRect)
            context.restoreGState();
        } else {
            super.draw(dirtyRect)
        }
    }
}
