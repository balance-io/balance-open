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
        return NSFont.systemFont(ofSize: size, weight: NSFontWeightSemibold)
    }
    
    static func mediumSystemFont(ofSize size: CGFloat) -> NSFont {
        return NSFont.systemFont(ofSize: size, weight: NSFontWeightMedium)
    }
    
    static func lightSystemFont(ofSize size: CGFloat) -> NSFont {
        return NSFont.systemFont(ofSize: size, weight: NSFontWeightLight)
    }
    
    // Cache fonts for performance
    fileprivate static var cachedMonospacedFonts = [CGFloat: NSFont]()
    static func monospacedDigitSystemFont(ofSize size: CGFloat) -> NSFont {
        if let cachedFont = cachedMonospacedFonts[size] {
            return cachedFont
        } else {
            let descriptor = NSFont.monospacedDigitSystemFont(ofSize: size, weight: NSFontWeightRegular).fontDescriptor
            let altDescriptor = descriptor.addingAttributes(
                [
                    NSFontFeatureSettingsAttribute: [
                        // Alternate 6 and 9
                        [ NSFontFeatureTypeIdentifierKey: kStylisticAlternativesType,
                          NSFontFeatureSelectorIdentifierKey: kStylisticAltOneOnSelector ],
                        // Alternate 4
                        [ NSFontFeatureTypeIdentifierKey: kStylisticAlternativesType,
                          NSFontFeatureSelectorIdentifierKey: kStylisticAltTwoOnSelector ]
                    ]
                ])
            
            let font = NSFont(descriptor: altDescriptor, size: size)!
            cachedMonospacedFonts[size] = font
            return font
        }
    }
}
