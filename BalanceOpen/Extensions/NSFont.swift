//
//  NSFont.swift
//  Bal
//
//  Created by Benjamin Baron on 5/23/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import AppKit

extension NSFont {
    
    static func semiboldSystemFont(ofSize size: CGFloat) -> NSFont {
        return NSFont.systemFont(ofSize: size, weight: NSFont.Weight.semibold)
    }
    
    static func mediumSystemFont(ofSize size: CGFloat) -> NSFont {
        return NSFont.systemFont(ofSize: size, weight: NSFont.Weight.medium)
    }
    
    static func lightSystemFont(ofSize size: CGFloat) -> NSFont {
        return NSFont.systemFont(ofSize: size, weight: NSFont.Weight.light)
    }
    
    // Cache fonts for performance
    fileprivate static var cachedMonospacedFonts = [CGFloat: NSFont]()
    static func monospacedDigitSystemFont(ofSize size: CGFloat) -> NSFont {
        if let cachedFont = cachedMonospacedFonts[size] {
            return cachedFont
        } else {
            let descriptor = NSFont.monospacedDigitSystemFont(ofSize: size, weight: NSFont.Weight.regular).fontDescriptor
            let altDescriptor = descriptor.addingAttributes(
                [
                    NSFontDescriptor.AttributeName.featureSettings: [
                        // Alternate 6 and 9
                        [ NSFontDescriptor.FeatureKey.typeIdentifier: kStylisticAlternativesType,
                          NSFontDescriptor.FeatureKey.selectorIdentifier: kStylisticAltOneOnSelector ],
                        // Alternate 4
                        [ NSFontDescriptor.FeatureKey.typeIdentifier: kStylisticAlternativesType,
                          NSFontDescriptor.FeatureKey.selectorIdentifier: kStylisticAltTwoOnSelector ]
                    ]
                ])
            
            let font = NSFont(descriptor: altDescriptor, size: size)!
            cachedMonospacedFonts[size] = font
            return font
        }
    }
}
