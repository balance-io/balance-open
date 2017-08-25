//
//  NSColor.swift
//  Bal
//
//  Created by Benjamin Baron on 5/23/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

#if os(OSX)
import AppKit
#else
import UIKit
#endif

extension PXColor {
    
    static func appleBlue() -> PXColor {
        return PXColor(deviceRedInt: 14, green: 122, blue: 254)
    }
    
    //
    // MARK: - Hex -
    //
    
    // Adapted from this example: https://developer.apple.com/library/mac/qa/qa1576/_index.html
    var hexString: String? {
        #if os(OSX)
        // Convert the NSColor to the RGB color space before we can access its components
        guard let rgbColor = self.usingColorSpaceName(NSColorSpaceName.calibratedRGB) else {
            return nil
        }
        #else
        let rgbColor = self
        #endif
        
        // Get the red, green, and blue components of the color
        var redFloatValue: CGFloat = 0, greenFloatValue: CGFloat = 0, blueFloatValue: CGFloat = 0
        rgbColor.getRed(&redFloatValue, green: &greenFloatValue, blue: &blueFloatValue, alpha: nil)
        
        // Convert the components to numbers (unsigned decimal integer) between 0 and 255
        let redIntValue = Int(redFloatValue * 255.99999)
        let greenIntValue = Int(greenFloatValue * 255.99999)
        let blueIntValue = Int(blueFloatValue * 255.99999)
        
        // Convert the numbers to hex strings
        let redHexValue = NSString(format: "%02x", redIntValue)
        let greenHexValue = NSString(format: "%02x", greenIntValue)
        let blueHexValue = NSString(format: "%02x", blueIntValue)
        
        // Concatenate the red, green, and blue components' hex strings together with a "#"
        return "#\(redHexValue)\(greenHexValue)\(blueHexValue)"
    }
    
    // Adapted from http://stackoverflow.com/a/27203691/299262
    convenience init?(hexString: String) {
        var cString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") {
            cString = cString.substring(from: 1)
        }
        
        if cString.characters.count != 6 {
            return nil
        }
        
        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    //
    // MARK: - Lighter / Darker -
    //
    
    // Adapted from http://stackoverflow.com/a/11598127/299262
    var lighterColor: PXColor {
        #if os(OSX)
        guard let rgbColor = self.usingColorSpaceName(NSColorSpaceName.calibratedRGB) else {
            return self
        }
        #else
        let rgbColor = self
        #endif
            
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        rgbColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return PXColor(hue: h, saturation: s, brightness: min(b * 1.3, 1.0), alpha: a)
    }
    
    var darkerColor: PXColor {
        #if os(OSX)
        guard let rgbColor = self.usingColorSpaceName(NSColorSpaceName.calibratedRGB) else {
            return self
        }
        #else
        let rgbColor = self
        #endif
        
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        rgbColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return PXColor(hue: h, saturation: s, brightness: (b * 0.75), alpha: a)
    }
    
    //
    // MARK: - Int Values -
    //
    
    // TODO: Look into what happened to calibratedRed and deviceRed on UIColor
    convenience init(calibratedRedInt red: Int, green: Int, blue: Int, alpha: Float = 1.0) {
        #if os(OSX)
        self.init(calibratedRed: CGFloat(red) / 255.0,
                          green: CGFloat(green) / 255.0,
                           blue: CGFloat(blue) / 255.0,
                          alpha: CGFloat(alpha))
        #else
        self.init(red: CGFloat(red) / 255.0,
                green: CGFloat(green) / 255.0,
                 blue: CGFloat(blue) / 255.0,
                alpha: CGFloat(alpha))
        #endif
    }
    
    convenience init(calibratedWhiteInt white: Int, alpha: Float = 1.0) {
        #if os(OSX)
        self.init(white: CGFloat(white) / 255.0,
                  alpha: CGFloat(alpha))
        #else
        self.init(white: CGFloat(white) / 255.0,
                  alpha: CGFloat(alpha))
        #endif
    }
    
    convenience init(deviceRedInt red: Int, green: Int, blue: Int, alpha: Float = 1.0) {
        #if os(OSX)
        self.init(deviceRed: CGFloat(red) / 255.0,
                      green: CGFloat(green) / 255.0,
                       blue: CGFloat(blue) / 255.0,
                      alpha: CGFloat(alpha))
        #else
        self.init(red: CGFloat(red) / 255.0,
                green: CGFloat(green) / 255.0,
                 blue: CGFloat(blue) / 255.0,
                alpha: CGFloat(alpha))
        #endif
    }
    
    convenience init(deviceWhiteInt white: Int, alpha: Float = 1.0) {
        #if os(OSX)
        self.init(deviceWhite: CGFloat(white) / 255.0,
                        alpha: CGFloat(alpha))
        #else
        self.init(white: CGFloat(white) / 255.0,
                  alpha: CGFloat(alpha))
        #endif
    }
    
    //
    // MARK: - Grayscale tinting -
    //
    
    // Based on information from https://ianstormtaylor.com/design-tip-never-use-black
    // Tints grayscale with a hue, using a saturation that's inversely proportional to the brightness
    convenience init(calibratedWhiteTintedInt white: Int, hue: Int, alpha: Float = 1.0) {
        // Adapted from https://blog.udemy.com/arduino-map/
        func map(_ x: Int, inMin: Int, inMax: Int, outMin: Int, outMax: Int) -> Int {
            return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
        }
        
        // Calculate saturation, higher for darker colors
        let minSaturation = 2
        let maxSaturation = 30
        let saturationPercent = maxSaturation - map(white, inMin: 0, inMax: 255, outMin: minSaturation, outMax: maxSaturation)
        
        #if os(OSX)
        self.init(calibratedHue: CGFloat(hue) / 360.0,
                     saturation: CGFloat(saturationPercent) / 100.0,
                     brightness: CGFloat(white) / 255.0,
                          alpha: CGFloat(alpha))
        #else
            self.init(hue: CGFloat(hue) / 360.0,
               saturation: CGFloat(saturationPercent) / 100.0,
               brightness: CGFloat(white) / 255.0,
                    alpha: CGFloat(alpha))
        #endif
    }
    
    // Use the same blue tint color throughout the app
    convenience init(calibratedWhiteTintedInt white: Int, alpha: Float = 1.0) {
        // Value between 0 and 360
        let grayscaleTintHue = 240
        self.init(calibratedWhiteTintedInt: white, hue: grayscaleTintHue, alpha: alpha)
    }
}
