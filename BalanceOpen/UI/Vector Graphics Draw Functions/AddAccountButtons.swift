//
//  AddAccountButtons.swift
//  BalanceForBlockchain
//
//  Created by Benjamin Baron on 6/9/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Cocoa

// TODO: Implement this
struct AddAccountButtons {
    static func drawBoaButton(bounds: NSRect = NSRect(x: 0, y: 0, width: 191, height: 56), original: Bool = true, hover: Bool = false, pressed: Bool = false) {
        //// General Declarations
        let context = NSGraphicsContext.current()!.cgContext
        
        //// Color Declarations
        let highlightGradientColor = NSColor(deviceRed: 1, green: 1, blue: 1, alpha: 0.09)
        let highlightGradientColor2 = NSColor(deviceRed: 1, green: 1, blue: 1, alpha: 0)
        let shadow2Color = NSColor(deviceRed: 1, green: 1, blue: 1, alpha: 0.36)
        let bankOfAmericaBackground = NSColor(deviceRed: 0.875, green: 0.051, blue: 0.165, alpha: 1)
        let logoWhite = NSColor(deviceRed: 1, green: 1, blue: 1, alpha: 1)
        
        //// Gradient Declarations
        let highlightGradient = NSGradient(starting: highlightGradientColor, ending: highlightGradientColor2)!
        
        //// Shadow Declarations
        let outerShadow = NSShadow()
        outerShadow.shadowColor = NSColor.black
        outerShadow.shadowOffset = NSSize(width: 0, height: 0)
        outerShadow.shadowBlurRadius = 0.5
        let innerStroke = NSShadow()
        innerStroke.shadowColor = shadow2Color
        innerStroke.shadowOffset = NSSize(width: 0, height: 0)
        innerStroke.shadowBlurRadius = 0.5
        
        if (original) {
            //// bankOfAmerica
            NSGraphicsContext.saveGraphicsState()
            context.translateBy(x: bounds.minX + 95.5, y: bounds.maxY - 28)
            
            outerShadow.set()
            context.beginTransparencyLayer(auxiliaryInfo: nil)
            
            
            //// bankOfAmericaBase Drawing
            let bankOfAmericaBasePath = NSBezierPath(roundedRect: NSRect(x: -88.5, y: -21, width: 177, height: 42), xRadius: 5, yRadius: 5)
            bankOfAmericaBackground.setFill()
            bankOfAmericaBasePath.fill()
            
            
            //// bankOfAmericaHighlight Drawing
            let bankOfAmericaHighlightPath = NSBezierPath(roundedRect: NSRect(x: -88.5, y: -21, width: 177, height: 42), xRadius: 5, yRadius: 5)
            highlightGradient.draw(in: bankOfAmericaHighlightPath, angle: -45)
            
            ////// bankOfAmericaHighlight Inner Shadow
            NSGraphicsContext.saveGraphicsState()
            NSRectClip(bankOfAmericaHighlightPath.bounds)
            context.setShadow(offset: NSSize.zero, blur: 0, color: nil)
            
            context.setAlpha(innerStroke.shadowColor!.alphaComponent)
            context.beginTransparencyLayer(auxiliaryInfo: nil)
            let bankOfAmericaHighlightOpaqueShadow = NSShadow()
            bankOfAmericaHighlightOpaqueShadow.shadowColor = innerStroke.shadowColor!.withAlphaComponent(1)
            bankOfAmericaHighlightOpaqueShadow.shadowOffset = innerStroke.shadowOffset
            bankOfAmericaHighlightOpaqueShadow.shadowBlurRadius = innerStroke.shadowBlurRadius
            bankOfAmericaHighlightOpaqueShadow.set()
            
            context.setBlendMode(.sourceOut)
            context.beginTransparencyLayer(auxiliaryInfo: nil)
            
            bankOfAmericaHighlightOpaqueShadow.shadowColor!.setFill()
            bankOfAmericaHighlightPath.fill()
            
            context.endTransparencyLayer()
            context.endTransparencyLayer()
            NSGraphicsContext.restoreGraphicsState()
            
            
            
            context.endTransparencyLayer()
            
            NSGraphicsContext.restoreGraphicsState()
        }
        
        
        if (hover) {
            //// bankOfAmericaHover
            NSGraphicsContext.saveGraphicsState()
            context.translateBy(x: bounds.minX + 95.5, y: bounds.maxY - 28)
            context.scaleBy(x: 1.05, y: 1.05)
            
            outerShadow.set()
            context.beginTransparencyLayer(auxiliaryInfo: nil)
            
            
            //// bankOfAmericaBase 2 Drawing
            let bankOfAmericaBase2Path = NSBezierPath(roundedRect: NSRect(x: -88.5, y: -21, width: 177, height: 42), xRadius: 5, yRadius: 5)
            bankOfAmericaBackground.setFill()
            bankOfAmericaBase2Path.fill()
            
            
            //// bankOfAmericaHighlight 2 Drawing
            let bankOfAmericaHighlight2Path = NSBezierPath(roundedRect: NSRect(x: -88.1, y: -20.95, width: 177, height: 42), xRadius: 5, yRadius: 5)
            highlightGradient.draw(in: bankOfAmericaHighlight2Path, angle: -45)
            
            ////// bankOfAmericaHighlight 2 Inner Shadow
            NSGraphicsContext.saveGraphicsState()
            NSRectClip(bankOfAmericaHighlight2Path.bounds)
            context.setShadow(offset: NSSize.zero, blur: 0, color: nil)
            
            context.setAlpha(innerStroke.shadowColor!.alphaComponent)
            context.beginTransparencyLayer(auxiliaryInfo: nil)
            let bankOfAmericaHighlight2OpaqueShadow = NSShadow()
            bankOfAmericaHighlight2OpaqueShadow.shadowColor = innerStroke.shadowColor!.withAlphaComponent(1)
            bankOfAmericaHighlight2OpaqueShadow.shadowOffset = innerStroke.shadowOffset
            bankOfAmericaHighlight2OpaqueShadow.shadowBlurRadius = innerStroke.shadowBlurRadius
            bankOfAmericaHighlight2OpaqueShadow.set()
            
            context.setBlendMode(.sourceOut)
            context.beginTransparencyLayer(auxiliaryInfo: nil)
            
            bankOfAmericaHighlight2OpaqueShadow.shadowColor!.setFill()
            bankOfAmericaHighlight2Path.fill()
            
            context.endTransparencyLayer()
            context.endTransparencyLayer()
            NSGraphicsContext.restoreGraphicsState()
            
            
            
            context.endTransparencyLayer()
            
            NSGraphicsContext.restoreGraphicsState()
        }
        
        
        if (pressed) {
            //// bankOfAmericaPressed
            NSGraphicsContext.saveGraphicsState()
            context.translateBy(x: bounds.minX + 95.5, y: bounds.maxY - 28)
            
            outerShadow.set()
            context.beginTransparencyLayer(auxiliaryInfo: nil)
            
            
            //// bankOfAmericaBase 3 Drawing
            let bankOfAmericaBase3Path = NSBezierPath(roundedRect: NSRect(x: -88.5, y: -21, width: 177, height: 42), xRadius: 5, yRadius: 5)
            bankOfAmericaBackground.setFill()
            bankOfAmericaBase3Path.fill()
            
            
            //// bankOfAmericaHighlight 3 Drawing
            let bankOfAmericaHighlight3Path = NSBezierPath(roundedRect: NSRect(x: -88.5, y: -21, width: 177, height: 42), xRadius: 5, yRadius: 5)
            highlightGradient.draw(in: bankOfAmericaHighlight3Path, angle: -45)
            
            ////// bankOfAmericaHighlight 3 Inner Shadow
            NSGraphicsContext.saveGraphicsState()
            NSRectClip(bankOfAmericaHighlight3Path.bounds)
            context.setShadow(offset: NSSize.zero, blur: 0, color: nil)
            
            context.setAlpha(innerStroke.shadowColor!.alphaComponent)
            context.beginTransparencyLayer(auxiliaryInfo: nil)
            let bankOfAmericaHighlight3OpaqueShadow = NSShadow()
            bankOfAmericaHighlight3OpaqueShadow.shadowColor = innerStroke.shadowColor!.withAlphaComponent(1)
            bankOfAmericaHighlight3OpaqueShadow.shadowOffset = innerStroke.shadowOffset
            bankOfAmericaHighlight3OpaqueShadow.shadowBlurRadius = innerStroke.shadowBlurRadius
            bankOfAmericaHighlight3OpaqueShadow.set()
            
            context.setBlendMode(.sourceOut)
            context.beginTransparencyLayer(auxiliaryInfo: nil)
            
            bankOfAmericaHighlight3OpaqueShadow.shadowColor!.setFill()
            bankOfAmericaHighlight3Path.fill()
            
            context.endTransparencyLayer()
            context.endTransparencyLayer()
            NSGraphicsContext.restoreGraphicsState()
            
            
            
            context.endTransparencyLayer()
            
            NSGraphicsContext.restoreGraphicsState()
        }
        
        
        //// bankOfAmericaLogo Drawing
        let bankOfAmericaLogoPath = NSBezierPath()
        bankOfAmericaLogoPath.move(to: NSPoint(x: bounds.minX + 143.23, y: bounds.maxY - 23.46))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 146.08, y: bounds.maxY - 24.66), controlPoint1: NSPoint(x: bounds.minX + 144.19, y: bounds.maxY - 23.83), controlPoint2: NSPoint(x: bounds.minX + 145.14, y: bounds.maxY - 24.23))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 137.47, y: bounds.maxY - 28.88), controlPoint1: NSPoint(x: bounds.minX + 143.1, y: bounds.maxY - 25.85), controlPoint2: NSPoint(x: bounds.minX + 140.22, y: bounds.maxY - 27.27))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 134.64, y: bounds.maxY - 27.52), controlPoint1: NSPoint(x: bounds.minX + 136.54, y: bounds.maxY - 28.4), controlPoint2: NSPoint(x: bounds.minX + 135.6, y: bounds.maxY - 27.95))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 143.23, y: bounds.maxY - 23.46), controlPoint1: NSPoint(x: bounds.minX + 137.38, y: bounds.maxY - 25.95), controlPoint2: NSPoint(x: bounds.minX + 140.26, y: bounds.maxY - 24.59))
        bankOfAmericaLogoPath.close()
        bankOfAmericaLogoPath.move(to: NSPoint(x: bounds.minX + 139.68, y: bounds.maxY - 22.23))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 130.79, y: bounds.maxY - 25.99), controlPoint1: NSPoint(x: bounds.minX + 136.59, y: bounds.maxY - 23.19), controlPoint2: NSPoint(x: bounds.minX + 133.61, y: bounds.maxY - 24.45))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 133.46, y: bounds.maxY - 27.02), controlPoint1: NSPoint(x: bounds.minX + 131.69, y: bounds.maxY - 26.31), controlPoint2: NSPoint(x: bounds.minX + 132.58, y: bounds.maxY - 26.65))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 142.09, y: bounds.maxY - 23.03), controlPoint1: NSPoint(x: bounds.minX + 136.19, y: bounds.maxY - 25.43), controlPoint2: NSPoint(x: bounds.minX + 139.09, y: bounds.maxY - 24.09))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 139.68, y: bounds.maxY - 22.23), controlPoint1: NSPoint(x: bounds.minX + 141.3, y: bounds.maxY - 22.75), controlPoint2: NSPoint(x: bounds.minX + 140.49, y: bounds.maxY - 22.48))
        bankOfAmericaLogoPath.close()
        bankOfAmericaLogoPath.move(to: NSPoint(x: bounds.minX + 149.69, y: bounds.maxY - 23.34))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 142.14, y: bounds.maxY - 20.43), controlPoint1: NSPoint(x: bounds.minX + 147.26, y: bounds.maxY - 22.18), controlPoint2: NSPoint(x: bounds.minX + 144.74, y: bounds.maxY - 21.21))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 139.43, y: bounds.maxY - 21.28), controlPoint1: NSPoint(x: bounds.minX + 141.23, y: bounds.maxY - 20.69), controlPoint2: NSPoint(x: bounds.minX + 140.33, y: bounds.maxY - 20.97))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 147.2, y: bounds.maxY - 24.23), controlPoint1: NSPoint(x: bounds.minX + 142.1, y: bounds.maxY - 22.06), controlPoint2: NSPoint(x: bounds.minX + 144.7, y: bounds.maxY - 23.04))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 149.69, y: bounds.maxY - 23.34), controlPoint1: NSPoint(x: bounds.minX + 148.02, y: bounds.maxY - 23.91), controlPoint2: NSPoint(x: bounds.minX + 148.86, y: bounds.maxY - 23.62))
        bankOfAmericaLogoPath.close()
        bankOfAmericaLogoPath.move(to: NSPoint(x: bounds.minX + 153.66, y: bounds.maxY - 22.18))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 145.97, y: bounds.maxY - 19.5), controlPoint1: NSPoint(x: bounds.minX + 151.17, y: bounds.maxY - 21.11), controlPoint2: NSPoint(x: bounds.minX + 148.6, y: bounds.maxY - 20.21))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 143.48, y: bounds.maxY - 20.07), controlPoint1: NSPoint(x: bounds.minX + 145.13, y: bounds.maxY - 19.67), controlPoint2: NSPoint(x: bounds.minX + 144.3, y: bounds.maxY - 19.86))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 151.07, y: bounds.maxY - 22.91), controlPoint1: NSPoint(x: bounds.minX + 146.09, y: bounds.maxY - 20.82), controlPoint2: NSPoint(x: bounds.minX + 148.63, y: bounds.maxY - 21.77))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 153.66, y: bounds.maxY - 22.18), controlPoint1: NSPoint(x: bounds.minX + 151.93, y: bounds.maxY - 22.64), controlPoint2: NSPoint(x: bounds.minX + 152.79, y: bounds.maxY - 22.4))
        bankOfAmericaLogoPath.close()
        bankOfAmericaLogoPath.move(to: NSPoint(x: bounds.minX + 160.03, y: bounds.maxY - 24.28))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 142.65, y: bounds.maxY - 33.01), controlPoint1: NSPoint(x: bounds.minX + 153.79, y: bounds.maxY - 26.36), controlPoint2: NSPoint(x: bounds.minX + 147.94, y: bounds.maxY - 29.31))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 146.52, y: bounds.maxY - 35.55), controlPoint1: NSPoint(x: bounds.minX + 143.97, y: bounds.maxY - 33.81), controlPoint2: NSPoint(x: bounds.minX + 145.26, y: bounds.maxY - 34.66))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 163, y: bounds.maxY - 25.94), controlPoint1: NSPoint(x: bounds.minX + 151.51, y: bounds.maxY - 31.65), controlPoint2: NSPoint(x: bounds.minX + 157.04, y: bounds.maxY - 28.41))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 160.03, y: bounds.maxY - 24.28), controlPoint1: NSPoint(x: bounds.minX + 162.03, y: bounds.maxY - 25.36), controlPoint2: NSPoint(x: bounds.minX + 161.03, y: bounds.maxY - 24.81))
        bankOfAmericaLogoPath.close()
        bankOfAmericaLogoPath.move(to: NSPoint(x: bounds.minX + 155.74, y: bounds.maxY - 22.28))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 137.65, y: bounds.maxY - 30.29), controlPoint1: NSPoint(x: bounds.minX + 149.25, y: bounds.maxY - 23.97), controlPoint2: NSPoint(x: bounds.minX + 143.15, y: bounds.maxY - 26.7))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 141.3, y: bounds.maxY - 32.21), controlPoint1: NSPoint(x: bounds.minX + 138.89, y: bounds.maxY - 30.89), controlPoint2: NSPoint(x: bounds.minX + 140.1, y: bounds.maxY - 31.53))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 159.05, y: bounds.maxY - 23.79), controlPoint1: NSPoint(x: bounds.minX + 146.69, y: bounds.maxY - 28.54), controlPoint2: NSPoint(x: bounds.minX + 152.67, y: bounds.maxY - 25.67))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 155.74, y: bounds.maxY - 22.28), controlPoint1: NSPoint(x: bounds.minX + 157.96, y: bounds.maxY - 23.25), controlPoint2: NSPoint(x: bounds.minX + 156.86, y: bounds.maxY - 22.74))
        bankOfAmericaLogoPath.close()
        bankOfAmericaLogoPath.move(to: NSPoint(x: bounds.minX + 66.28, y: bounds.maxY - 25.01))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 62.91, y: bounds.maxY - 28.85), controlPoint1: NSPoint(x: bounds.minX + 64.03, y: bounds.maxY - 25.01), controlPoint2: NSPoint(x: bounds.minX + 62.91, y: bounds.maxY - 26.65))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 66.28, y: bounds.maxY - 32.75), controlPoint1: NSPoint(x: bounds.minX + 62.91, y: bounds.maxY - 31.15), controlPoint2: NSPoint(x: bounds.minX + 63.98, y: bounds.maxY - 32.75))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 69.65, y: bounds.maxY - 28.85), controlPoint1: NSPoint(x: bounds.minX + 68.58, y: bounds.maxY - 32.75), controlPoint2: NSPoint(x: bounds.minX + 69.65, y: bounds.maxY - 31.15))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 66.28, y: bounds.maxY - 25.01), controlPoint1: NSPoint(x: bounds.minX + 69.65, y: bounds.maxY - 26.65), controlPoint2: NSPoint(x: bounds.minX + 68.53, y: bounds.maxY - 25.01))
        bankOfAmericaLogoPath.close()
        bankOfAmericaLogoPath.move(to: NSPoint(x: bounds.minX + 66.28, y: bounds.maxY - 31.25))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 65.42, y: bounds.maxY - 28.85), controlPoint1: NSPoint(x: bounds.minX + 65.68, y: bounds.maxY - 31.25), controlPoint2: NSPoint(x: bounds.minX + 65.42, y: bounds.maxY - 30.72))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 66.28, y: bounds.maxY - 26.51), controlPoint1: NSPoint(x: bounds.minX + 65.42, y: bounds.maxY - 27.14), controlPoint2: NSPoint(x: bounds.minX + 65.59, y: bounds.maxY - 26.51))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 67.15, y: bounds.maxY - 28.85), controlPoint1: NSPoint(x: bounds.minX + 66.97, y: bounds.maxY - 26.51), controlPoint2: NSPoint(x: bounds.minX + 67.15, y: bounds.maxY - 27.14))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 66.28, y: bounds.maxY - 31.25), controlPoint1: NSPoint(x: bounds.minX + 67.15, y: bounds.maxY - 30.72), controlPoint2: NSPoint(x: bounds.minX + 66.88, y: bounds.maxY - 31.25))
        bankOfAmericaLogoPath.close()
        bankOfAmericaLogoPath.move(to: NSPoint(x: bounds.minX + 71.21, y: bounds.maxY - 24.38))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 71.21, y: bounds.maxY - 25.21))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 70.23, y: bounds.maxY - 25.21))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 70.23, y: bounds.maxY - 26.89))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 71.21, y: bounds.maxY - 26.89))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 71.21, y: bounds.maxY - 32.59))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 73.63, y: bounds.maxY - 32.59))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 73.63, y: bounds.maxY - 26.89))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 74.95, y: bounds.maxY - 26.89))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 74.95, y: bounds.maxY - 25.21))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 73.63, y: bounds.maxY - 25.21))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 73.63, y: bounds.maxY - 24.46))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 74.5, y: bounds.maxY - 23.77), controlPoint1: NSPoint(x: bounds.minX + 73.63, y: bounds.maxY - 24.01), controlPoint2: NSPoint(x: bounds.minX + 73.86, y: bounds.maxY - 23.77))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 74.94, y: bounds.maxY - 23.82), controlPoint1: NSPoint(x: bounds.minX + 74.63, y: bounds.maxY - 23.77), controlPoint2: NSPoint(x: bounds.minX + 74.81, y: bounds.maxY - 23.79))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 74.94, y: bounds.maxY - 22))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 73.72, y: bounds.maxY - 21.91), controlPoint1: NSPoint(x: bounds.minX + 74.55, y: bounds.maxY - 21.96), controlPoint2: NSPoint(x: bounds.minX + 74.2, y: bounds.maxY - 21.91))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 71.21, y: bounds.maxY - 24.38), controlPoint1: NSPoint(x: bounds.minX + 72.12, y: bounds.maxY - 21.91), controlPoint2: NSPoint(x: bounds.minX + 71.21, y: bounds.maxY - 22.57))
        bankOfAmericaLogoPath.close()
        bankOfAmericaLogoPath.move(to: NSPoint(x: bounds.minX + 45.43, y: bounds.maxY - 27.28))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 42.48, y: bounds.maxY - 25.03), controlPoint1: NSPoint(x: bounds.minX + 45.43, y: bounds.maxY - 25.65), controlPoint2: NSPoint(x: bounds.minX + 43.93, y: bounds.maxY - 25.03))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 39.49, y: bounds.maxY - 27.08), controlPoint1: NSPoint(x: bounds.minX + 41.11, y: bounds.maxY - 25.03), controlPoint2: NSPoint(x: bounds.minX + 39.76, y: bounds.maxY - 25.62))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 41.6, y: bounds.maxY - 27.5))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 42.39, y: bounds.maxY - 26.53), controlPoint1: NSPoint(x: bounds.minX + 41.62, y: bounds.maxY - 27.07), controlPoint2: NSPoint(x: bounds.minX + 41.81, y: bounds.maxY - 26.53))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 43.02, y: bounds.maxY - 27.27), controlPoint1: NSPoint(x: bounds.minX + 42.81, y: bounds.maxY - 26.53), controlPoint2: NSPoint(x: bounds.minX + 43.02, y: bounds.maxY - 26.83))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 43.02, y: bounds.maxY - 27.9))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 39.16, y: bounds.maxY - 30.57), controlPoint1: NSPoint(x: bounds.minX + 41.42, y: bounds.maxY - 28.08), controlPoint2: NSPoint(x: bounds.minX + 39.22, y: bounds.maxY - 28.65))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 41.25, y: bounds.maxY - 32.73), controlPoint1: NSPoint(x: bounds.minX + 39.13, y: bounds.maxY - 31.93), controlPoint2: NSPoint(x: bounds.minX + 40.04, y: bounds.maxY - 32.73))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 43.09, y: bounds.maxY - 31.92), controlPoint1: NSPoint(x: bounds.minX + 41.96, y: bounds.maxY - 32.73), controlPoint2: NSPoint(x: bounds.minX + 42.68, y: bounds.maxY - 32.34))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 43.17, y: bounds.maxY - 32.59), controlPoint1: NSPoint(x: bounds.minX + 43.1, y: bounds.maxY - 32.04), controlPoint2: NSPoint(x: bounds.minX + 43.12, y: bounds.maxY - 32.39))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 45.66, y: bounds.maxY - 32.59))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 45.43, y: bounds.maxY - 31.4), controlPoint1: NSPoint(x: bounds.minX + 45.57, y: bounds.maxY - 32.49), controlPoint2: NSPoint(x: bounds.minX + 45.43, y: bounds.maxY - 32.24))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 45.43, y: bounds.maxY - 27.28))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 45.43, y: bounds.maxY - 27.28))
        bankOfAmericaLogoPath.close()
        bankOfAmericaLogoPath.move(to: NSPoint(x: bounds.minX + 43.02, y: bounds.maxY - 30.71))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 42.24, y: bounds.maxY - 31.17), controlPoint1: NSPoint(x: bounds.minX + 42.81, y: bounds.maxY - 30.98), controlPoint2: NSPoint(x: bounds.minX + 42.52, y: bounds.maxY - 31.17))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 41.54, y: bounds.maxY - 30.39), controlPoint1: NSPoint(x: bounds.minX + 41.81, y: bounds.maxY - 31.17), controlPoint2: NSPoint(x: bounds.minX + 41.54, y: bounds.maxY - 30.9))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 43.02, y: bounds.maxY - 29.05), controlPoint1: NSPoint(x: bounds.minX + 41.54, y: bounds.maxY - 29.44), controlPoint2: NSPoint(x: bounds.minX + 42.17, y: bounds.maxY - 29.13))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 43.02, y: bounds.maxY - 30.71))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 43.02, y: bounds.maxY - 30.71))
        bankOfAmericaLogoPath.close()
        bankOfAmericaLogoPath.move(to: NSPoint(x: bounds.minX + 51.36, y: bounds.maxY - 25.03))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 49.26, y: bounds.maxY - 25.96), controlPoint1: NSPoint(x: bounds.minX + 50.42, y: bounds.maxY - 25.03), controlPoint2: NSPoint(x: bounds.minX + 49.75, y: bounds.maxY - 25.46))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 49.23, y: bounds.maxY - 25.96))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 49.21, y: bounds.maxY - 25.21))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 46.85, y: bounds.maxY - 25.21))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 46.85, y: bounds.maxY - 32.59))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 49.26, y: bounds.maxY - 32.59))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 49.26, y: bounds.maxY - 27.31))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 50.05, y: bounds.maxY - 26.85), controlPoint1: NSPoint(x: bounds.minX + 49.49, y: bounds.maxY - 27.03), controlPoint2: NSPoint(x: bounds.minX + 49.78, y: bounds.maxY - 26.85))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 50.61, y: bounds.maxY - 27.51), controlPoint1: NSPoint(x: bounds.minX + 50.46, y: bounds.maxY - 26.85), controlPoint2: NSPoint(x: bounds.minX + 50.61, y: bounds.maxY - 27.09))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 50.61, y: bounds.maxY - 32.59))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 53.03, y: bounds.maxY - 32.59))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 53.03, y: bounds.maxY - 26.75))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 51.36, y: bounds.maxY - 25.03), controlPoint1: NSPoint(x: bounds.minX + 53.03, y: bounds.maxY - 25.74), controlPoint2: NSPoint(x: bounds.minX + 52.42, y: bounds.maxY - 25.03))
        bankOfAmericaLogoPath.close()
        bankOfAmericaLogoPath.move(to: NSPoint(x: bounds.minX + 61.16, y: bounds.maxY - 25.21))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 58.76, y: bounds.maxY - 25.21))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 56.98, y: bounds.maxY - 27.44))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 56.95, y: bounds.maxY - 27.44))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 56.95, y: bounds.maxY - 22.12))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 54.53, y: bounds.maxY - 22.12))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 54.53, y: bounds.maxY - 32.59))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 56.95, y: bounds.maxY - 32.59))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 56.95, y: bounds.maxY - 29.95))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 57.46, y: bounds.maxY - 29.37))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 57.49, y: bounds.maxY - 29.37))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 58.66, y: bounds.maxY - 32.59))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 61.17, y: bounds.maxY - 32.59))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 59.14, y: bounds.maxY - 27.48))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 61.16, y: bounds.maxY - 25.21))
        bankOfAmericaLogoPath.close()
        bankOfAmericaLogoPath.move(to: NSPoint(x: bounds.minX + 36.59, y: bounds.maxY - 27.14))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 36.59, y: bounds.maxY - 27.06))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 38.32, y: bounds.maxY - 24.68), controlPoint1: NSPoint(x: bounds.minX + 37.36, y: bounds.maxY - 26.77), controlPoint2: NSPoint(x: bounds.minX + 38.32, y: bounds.maxY - 26.05))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 35.2, y: bounds.maxY - 22.12), controlPoint1: NSPoint(x: bounds.minX + 38.32, y: bounds.maxY - 23.23), controlPoint2: NSPoint(x: bounds.minX + 37.08, y: bounds.maxY - 22.12))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 31, y: bounds.maxY - 22.12))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 31, y: bounds.maxY - 32.59))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 35.09, y: bounds.maxY - 32.59))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 38.57, y: bounds.maxY - 29.79), controlPoint1: NSPoint(x: bounds.minX + 37.11, y: bounds.maxY - 32.59), controlPoint2: NSPoint(x: bounds.minX + 38.57, y: bounds.maxY - 31.58))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 36.59, y: bounds.maxY - 27.14), controlPoint1: NSPoint(x: bounds.minX + 38.57, y: bounds.maxY - 28.45), controlPoint2: NSPoint(x: bounds.minX + 37.74, y: bounds.maxY - 27.52))
        bankOfAmericaLogoPath.close()
        bankOfAmericaLogoPath.move(to: NSPoint(x: bounds.minX + 33.61, y: bounds.maxY - 23.97))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 34.55, y: bounds.maxY - 23.97))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 35.84, y: bounds.maxY - 25.13), controlPoint1: NSPoint(x: bounds.minX + 35.16, y: bounds.maxY - 23.97), controlPoint2: NSPoint(x: bounds.minX + 35.84, y: bounds.maxY - 24.13))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 34.49, y: bounds.maxY - 26.27), controlPoint1: NSPoint(x: bounds.minX + 35.84, y: bounds.maxY - 25.75), controlPoint2: NSPoint(x: bounds.minX + 35.46, y: bounds.maxY - 26.27))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 33.61, y: bounds.maxY - 26.27))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 33.61, y: bounds.maxY - 23.97))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 33.61, y: bounds.maxY - 23.97))
        bankOfAmericaLogoPath.close()
        bankOfAmericaLogoPath.move(to: NSPoint(x: bounds.minX + 34.6, y: bounds.maxY - 30.65))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 33.61, y: bounds.maxY - 30.65))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 33.61, y: bounds.maxY - 28.03))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 34.6, y: bounds.maxY - 28.03))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 35.95, y: bounds.maxY - 29.33), controlPoint1: NSPoint(x: bounds.minX + 35.46, y: bounds.maxY - 28.03), controlPoint2: NSPoint(x: bounds.minX + 35.95, y: bounds.maxY - 28.55))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 34.6, y: bounds.maxY - 30.65), controlPoint1: NSPoint(x: bounds.minX + 35.95, y: bounds.maxY - 30.4), controlPoint2: NSPoint(x: bounds.minX + 35.18, y: bounds.maxY - 30.65))
        bankOfAmericaLogoPath.close()
        bankOfAmericaLogoPath.move(to: NSPoint(x: bounds.minX + 126.37, y: bounds.maxY - 31.4))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 126.37, y: bounds.maxY - 27.28))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 123.41, y: bounds.maxY - 25.03), controlPoint1: NSPoint(x: bounds.minX + 126.37, y: bounds.maxY - 25.65), controlPoint2: NSPoint(x: bounds.minX + 124.86, y: bounds.maxY - 25.03))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 120.43, y: bounds.maxY - 27.08), controlPoint1: NSPoint(x: bounds.minX + 122.04, y: bounds.maxY - 25.03), controlPoint2: NSPoint(x: bounds.minX + 120.7, y: bounds.maxY - 25.62))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 122.53, y: bounds.maxY - 27.5))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 123.33, y: bounds.maxY - 26.53), controlPoint1: NSPoint(x: bounds.minX + 122.56, y: bounds.maxY - 27.07), controlPoint2: NSPoint(x: bounds.minX + 122.74, y: bounds.maxY - 26.53))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 123.95, y: bounds.maxY - 27.27), controlPoint1: NSPoint(x: bounds.minX + 123.74, y: bounds.maxY - 26.53), controlPoint2: NSPoint(x: bounds.minX + 123.95, y: bounds.maxY - 26.83))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 123.95, y: bounds.maxY - 27.9))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 120.1, y: bounds.maxY - 30.57), controlPoint1: NSPoint(x: bounds.minX + 122.35, y: bounds.maxY - 28.08), controlPoint2: NSPoint(x: bounds.minX + 120.15, y: bounds.maxY - 28.65))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 122.19, y: bounds.maxY - 32.73), controlPoint1: NSPoint(x: bounds.minX + 120.06, y: bounds.maxY - 31.93), controlPoint2: NSPoint(x: bounds.minX + 120.98, y: bounds.maxY - 32.73))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 124.03, y: bounds.maxY - 31.92), controlPoint1: NSPoint(x: bounds.minX + 122.9, y: bounds.maxY - 32.73), controlPoint2: NSPoint(x: bounds.minX + 123.61, y: bounds.maxY - 32.34))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 124.1, y: bounds.maxY - 32.59), controlPoint1: NSPoint(x: bounds.minX + 124.04, y: bounds.maxY - 32.04), controlPoint2: NSPoint(x: bounds.minX + 124.06, y: bounds.maxY - 32.39))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 126.59, y: bounds.maxY - 32.59))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 126.37, y: bounds.maxY - 31.4), controlPoint1: NSPoint(x: bounds.minX + 126.5, y: bounds.maxY - 32.49), controlPoint2: NSPoint(x: bounds.minX + 126.37, y: bounds.maxY - 32.24))
        bankOfAmericaLogoPath.close()
        bankOfAmericaLogoPath.move(to: NSPoint(x: bounds.minX + 123.95, y: bounds.maxY - 30.71))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 123.18, y: bounds.maxY - 31.17), controlPoint1: NSPoint(x: bounds.minX + 123.74, y: bounds.maxY - 30.98), controlPoint2: NSPoint(x: bounds.minX + 123.45, y: bounds.maxY - 31.17))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 122.47, y: bounds.maxY - 30.39), controlPoint1: NSPoint(x: bounds.minX + 122.74, y: bounds.maxY - 31.17), controlPoint2: NSPoint(x: bounds.minX + 122.47, y: bounds.maxY - 30.9))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 123.95, y: bounds.maxY - 29.05), controlPoint1: NSPoint(x: bounds.minX + 122.47, y: bounds.maxY - 29.44), controlPoint2: NSPoint(x: bounds.minX + 123.11, y: bounds.maxY - 29.13))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 123.95, y: bounds.maxY - 30.71))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 123.95, y: bounds.maxY - 30.71))
        bankOfAmericaLogoPath.close()
        bankOfAmericaLogoPath.move(to: NSPoint(x: bounds.minX + 100.01, y: bounds.maxY - 25.01))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 96.68, y: bounds.maxY - 28.87), controlPoint1: NSPoint(x: bounds.minX + 97.78, y: bounds.maxY - 25.01), controlPoint2: NSPoint(x: bounds.minX + 96.68, y: bounds.maxY - 26.78))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 100.03, y: bounds.maxY - 32.75), controlPoint1: NSPoint(x: bounds.minX + 96.68, y: bounds.maxY - 30.91), controlPoint2: NSPoint(x: bounds.minX + 97.72, y: bounds.maxY - 32.75))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 103.04, y: bounds.maxY - 30.73), controlPoint1: NSPoint(x: bounds.minX + 102.19, y: bounds.maxY - 32.75), controlPoint2: NSPoint(x: bounds.minX + 102.93, y: bounds.maxY - 31.07))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 101.41, y: bounds.maxY - 30.15))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 100.21, y: bounds.maxY - 31.16), controlPoint1: NSPoint(x: bounds.minX + 101.29, y: bounds.maxY - 30.74), controlPoint2: NSPoint(x: bounds.minX + 100.79, y: bounds.maxY - 31.16))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 99.09, y: bounds.maxY - 29.41), controlPoint1: NSPoint(x: bounds.minX + 99.24, y: bounds.maxY - 31.16), controlPoint2: NSPoint(x: bounds.minX + 99.06, y: bounds.maxY - 30.07))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 103.14, y: bounds.maxY - 29.41))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 103.14, y: bounds.maxY - 28.91))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 100.01, y: bounds.maxY - 25.01), controlPoint1: NSPoint(x: bounds.minX + 103.14, y: bounds.maxY - 26.98), controlPoint2: NSPoint(x: bounds.minX + 102.34, y: bounds.maxY - 25.01))
        bankOfAmericaLogoPath.close()
        bankOfAmericaLogoPath.move(to: NSPoint(x: bounds.minX + 100.9, y: bounds.maxY - 28))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 99.09, y: bounds.maxY - 28))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 99.99, y: bounds.maxY - 26.51), controlPoint1: NSPoint(x: bounds.minX + 99.06, y: bounds.maxY - 27.3), controlPoint2: NSPoint(x: bounds.minX + 99.3, y: bounds.maxY - 26.51))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 100.9, y: bounds.maxY - 28), controlPoint1: NSPoint(x: bounds.minX + 100.83, y: bounds.maxY - 26.51), controlPoint2: NSPoint(x: bounds.minX + 100.92, y: bounds.maxY - 27.31))
        bankOfAmericaLogoPath.close()
        bankOfAmericaLogoPath.move(to: NSPoint(x: bounds.minX + 109.66, y: bounds.maxY - 25.21))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 112.08, y: bounds.maxY - 25.21))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 112.08, y: bounds.maxY - 32.59))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 109.66, y: bounds.maxY - 32.59))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 109.66, y: bounds.maxY - 25.21))
        bankOfAmericaLogoPath.close()
        bankOfAmericaLogoPath.move(to: NSPoint(x: bounds.minX + 109.66, y: bounds.maxY - 22.12))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 112.08, y: bounds.maxY - 22.12))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 112.08, y: bounds.maxY - 24.24))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 109.66, y: bounds.maxY - 24.24))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 109.66, y: bounds.maxY - 22.12))
        bankOfAmericaLogoPath.close()
        bankOfAmericaLogoPath.move(to: NSPoint(x: bounds.minX + 116.62, y: bounds.maxY - 26.51))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 117.32, y: bounds.maxY - 27.01), controlPoint1: NSPoint(x: bounds.minX + 117.01, y: bounds.maxY - 26.51), controlPoint2: NSPoint(x: bounds.minX + 117.21, y: bounds.maxY - 26.72))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 117.44, y: bounds.maxY - 27.94), controlPoint1: NSPoint(x: bounds.minX + 117.43, y: bounds.maxY - 27.29), controlPoint2: NSPoint(x: bounds.minX + 117.44, y: bounds.maxY - 27.64))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 119.51, y: bounds.maxY - 27.94))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 116.55, y: bounds.maxY - 25.01), controlPoint1: NSPoint(x: bounds.minX + 119.51, y: bounds.maxY - 27.2), controlPoint2: NSPoint(x: bounds.minX + 119.12, y: bounds.maxY - 25.01))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 113.13, y: bounds.maxY - 29.04), controlPoint1: NSPoint(x: bounds.minX + 114.27, y: bounds.maxY - 25.01), controlPoint2: NSPoint(x: bounds.minX + 113.13, y: bounds.maxY - 27.03))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 116.45, y: bounds.maxY - 32.75), controlPoint1: NSPoint(x: bounds.minX + 113.13, y: bounds.maxY - 30.87), controlPoint2: NSPoint(x: bounds.minX + 114.27, y: bounds.maxY - 32.75))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 119.43, y: bounds.maxY - 30.01), controlPoint1: NSPoint(x: bounds.minX + 118.21, y: bounds.maxY - 32.75), controlPoint2: NSPoint(x: bounds.minX + 119.25, y: bounds.maxY - 31.81))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 117.55, y: bounds.maxY - 29.75))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 116.62, y: bounds.maxY - 31.16), controlPoint1: NSPoint(x: bounds.minX + 117.55, y: bounds.maxY - 30.31), controlPoint2: NSPoint(x: bounds.minX + 117.48, y: bounds.maxY - 31.16))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 115.73, y: bounds.maxY - 28.95), controlPoint1: NSPoint(x: bounds.minX + 116, y: bounds.maxY - 31.16), controlPoint2: NSPoint(x: bounds.minX + 115.73, y: bounds.maxY - 30.62))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 116.62, y: bounds.maxY - 26.51), controlPoint1: NSPoint(x: bounds.minX + 115.73, y: bounds.maxY - 27.48), controlPoint2: NSPoint(x: bounds.minX + 115.82, y: bounds.maxY - 26.51))
        bankOfAmericaLogoPath.close()
        bankOfAmericaLogoPath.move(to: NSPoint(x: bounds.minX + 79.15, y: bounds.maxY - 22.12))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 76.66, y: bounds.maxY - 32.59))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 78.98, y: bounds.maxY - 32.59))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 79.45, y: bounds.maxY - 30.47))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 81.91, y: bounds.maxY - 30.47))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 82.33, y: bounds.maxY - 32.59))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 84.94, y: bounds.maxY - 32.59))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 82.67, y: bounds.maxY - 22.12))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 79.15, y: bounds.maxY - 22.12))
        bankOfAmericaLogoPath.close()
        bankOfAmericaLogoPath.move(to: NSPoint(x: bounds.minX + 79.82, y: bounds.maxY - 28.62))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 80.72, y: bounds.maxY - 24.35))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 80.77, y: bounds.maxY - 24.35))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 81.54, y: bounds.maxY - 28.62))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 79.82, y: bounds.maxY - 28.62))
        bankOfAmericaLogoPath.close()
        bankOfAmericaLogoPath.move(to: NSPoint(x: bounds.minX + 106.54, y: bounds.maxY - 26.21))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 106.5, y: bounds.maxY - 26.21))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 106.48, y: bounds.maxY - 25.21))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 104.14, y: bounds.maxY - 25.21))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 104.14, y: bounds.maxY - 32.59))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 106.56, y: bounds.maxY - 32.59))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 106.56, y: bounds.maxY - 27.81))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 107.88, y: bounds.maxY - 27.24), controlPoint1: NSPoint(x: bounds.minX + 106.84, y: bounds.maxY - 27.48), controlPoint2: NSPoint(x: bounds.minX + 107.27, y: bounds.maxY - 27.24))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 108.87, y: bounds.maxY - 27.44), controlPoint1: NSPoint(x: bounds.minX + 108.3, y: bounds.maxY - 27.24), controlPoint2: NSPoint(x: bounds.minX + 108.59, y: bounds.maxY - 27.34))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 108.87, y: bounds.maxY - 25.03))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 106.54, y: bounds.maxY - 26.21), controlPoint1: NSPoint(x: bounds.minX + 107.94, y: bounds.maxY - 25.03), controlPoint2: NSPoint(x: bounds.minX + 107.03, y: bounds.maxY - 25.43))
        bankOfAmericaLogoPath.close()
        bankOfAmericaLogoPath.move(to: NSPoint(x: bounds.minX + 93.94, y: bounds.maxY - 25.03))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 91.78, y: bounds.maxY - 26.02), controlPoint1: NSPoint(x: bounds.minX + 92.93, y: bounds.maxY - 25.03), controlPoint2: NSPoint(x: bounds.minX + 92.2, y: bounds.maxY - 25.57))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 91.75, y: bounds.maxY - 26.02))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 90.3, y: bounds.maxY - 25.03), controlPoint1: NSPoint(x: bounds.minX + 91.52, y: bounds.maxY - 25.45), controlPoint2: NSPoint(x: bounds.minX + 91.03, y: bounds.maxY - 25.03))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 88.13, y: bounds.maxY - 25.96), controlPoint1: NSPoint(x: bounds.minX + 89.4, y: bounds.maxY - 25.03), controlPoint2: NSPoint(x: bounds.minX + 88.64, y: bounds.maxY - 25.49))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 88.1, y: bounds.maxY - 25.96))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 88.09, y: bounds.maxY - 25.21))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 85.73, y: bounds.maxY - 25.21))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 85.73, y: bounds.maxY - 32.59))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 88.1, y: bounds.maxY - 32.59))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 88.1, y: bounds.maxY - 27.33))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 88.92, y: bounds.maxY - 26.87), controlPoint1: NSPoint(x: bounds.minX + 88.31, y: bounds.maxY - 27.05), controlPoint2: NSPoint(x: bounds.minX + 88.67, y: bounds.maxY - 26.87))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 89.49, y: bounds.maxY - 27.53), controlPoint1: NSPoint(x: bounds.minX + 89.37, y: bounds.maxY - 26.87), controlPoint2: NSPoint(x: bounds.minX + 89.49, y: bounds.maxY - 27.13))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 89.49, y: bounds.maxY - 32.59))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 91.86, y: bounds.maxY - 32.59))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 91.86, y: bounds.maxY - 27.33))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 92.69, y: bounds.maxY - 26.87), controlPoint1: NSPoint(x: bounds.minX + 92.02, y: bounds.maxY - 27.12), controlPoint2: NSPoint(x: bounds.minX + 92.37, y: bounds.maxY - 26.87))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 93.25, y: bounds.maxY - 27.53), controlPoint1: NSPoint(x: bounds.minX + 93.13, y: bounds.maxY - 26.87), controlPoint2: NSPoint(x: bounds.minX + 93.25, y: bounds.maxY - 27.13))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 93.25, y: bounds.maxY - 32.59))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 95.62, y: bounds.maxY - 32.59))
        bankOfAmericaLogoPath.line(to: NSPoint(x: bounds.minX + 95.62, y: bounds.maxY - 26.71))
        bankOfAmericaLogoPath.curve(to: NSPoint(x: bounds.minX + 93.94, y: bounds.maxY - 25.03), controlPoint1: NSPoint(x: bounds.minX + 95.62, y: bounds.maxY - 25.69), controlPoint2: NSPoint(x: bounds.minX + 94.94, y: bounds.maxY - 25.03))
        bankOfAmericaLogoPath.close()
        bankOfAmericaLogoPath.windingRule = .evenOddWindingRule
        logoWhite.setFill()
        bankOfAmericaLogoPath.fill()
    }

}
