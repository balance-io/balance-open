//
//  Utils.swift
//  Bal
//
//  Created by Benjamin Baron on 2/3/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

var appBuildString: String = {
    if let info = Bundle.main.infoDictionary, let build = info["CFBundleVersion"] as? String {
        return build
    }
    return "Unknown"
}()

var appVersionString: String = {
    if let info = Bundle.main.infoDictionary, let version = info["CFBundleShortVersionString"] as? String, let build = info["CFBundleVersion"] as? String {
        return "Balance \(version) (\(build))"
    }
    return "Unknown"
}()

var osVersionString: String = {
    return "macOS " + ProcessInfo.processInfo.operatingSystemVersionString
}()

var hardwareModelString: String = {
    return Sysctl.model
}()

func validateEmail(_ email: String) -> Bool {
    let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
    return emailPredicate.evaluate(with: email)
}

var appSupportPathUrl: URL = {
    let fileManager = FileManager.default
    
    let appSupportUrl = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    let pathUrl = appSupportUrl.appendingPathComponent("Balance", isDirectory: true)
    
    do {
        try fileManager.createDirectory(at: pathUrl, withIntermediateDirectories: true, attributes: nil)
    } catch {
        // Nothing to do here, it's not like we can log it! This should never happen.
    }
    
    return pathUrl
}()

var centeredParagraphStyle: NSParagraphStyle {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center
    return paragraphStyle
}

var leftParagraphStyle: NSParagraphStyle {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .left
    return paragraphStyle
}

var rightParagraphStyle: NSParagraphStyle {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .right
    return paragraphStyle
}

// Takes a decimal dollar amount and converts it to an integer cents amount.
// Using string conversion because Double/Int conversion is fuzzy
func decimalDollarAmountToCents(_ amount: Double) -> Int {
    let amountString = String(format: "%.2f", amount)
    var amountParts = amountString.components(separatedBy: ".")
    var amountCents = 0
    if amountParts.count > 0 {
        if let dollars = Int(amountParts[0]) {
            amountCents = dollars * 100
        }
    }
    if amountParts.count > 1 {
        let isNegative = amountParts[0].hasPrefix("-")
        if let cents = Int(amountParts[1]) {
            amountCents += isNegative ? -cents : cents
        }
    }
    return amountCents
}

fileprivate var centsFormatterNoDecimal: NumberFormatter = {
    let centsFormatter = NumberFormatter()
    centsFormatter.currencySymbol = "$"
    centsFormatter.numberStyle = .currency
    centsFormatter.maximumFractionDigits = 0
    return centsFormatter
}()

fileprivate var centsFormatter: NumberFormatter = {
    let centsFormatter = NumberFormatter()
    centsFormatter.currencySymbol = "$"
    centsFormatter.numberStyle = .currency
    centsFormatter.maximumFractionDigits = 2
    return centsFormatter
}()

fileprivate var decimalFormatter: NumberFormatter = {
    let centsFormatter = NumberFormatter()
    centsFormatter.numberStyle = .decimal
    centsFormatter.maximumFractionDigits = 2
    return centsFormatter
}()

// Takes in strings representing dollars like $300.00, $500, 40 and returns their value in cents
func stringToCents(_ amountString: String) -> Int? {
    if let number = centsFormatter.number(from: amountString) {
        let cents = Int(number.doubleValue * 100.0)
        return cents
    } else if let number = decimalFormatter.number(from: amountString) {
        let cents = Int(number.doubleValue * 100.0)
        return cents
    }
    return nil
}

func centsToString(_ cents: Int, showNegative: Bool = false, showCents: Bool = true)  -> String {
    let amount = Double(cents) / 100.00
    let formatter = showCents ? centsFormatter : centsFormatterNoDecimal
    let amountString = formatter.string(from: NSNumber(value: amount))!
    let minusRemoved = showNegative ? amountString : amountString.replacingOccurrences(of: "-", with: "")
    
    return minusRemoved
}


func centsToStringFormatted(_ cents: Int, showNegative: Bool = false, showCents: Bool = true, colorPositive: Bool = true)  -> NSAttributedString {
    let amount = Double(cents) / 100.00
    let formatter = showCents ? centsFormatter : centsFormatterNoDecimal
    let amountString = formatter.string(from: NSNumber(value: amount))!
    let minusRemoved = showNegative ? amountString : amountString.replacingOccurrences(of: "-", with: "")
    
    let preparedString = NSMutableAttributedString(string: minusRemoved, attributes: [NSParagraphStyleAttributeName: rightParagraphStyle])
    
    let count = preparedString.string.length
    let firstCharacters = NSRange(location: 0, length: showCents ? count - 3 : count)
    let lastTwoCharacters = NSRange(location: count - 3, length: 3)
    
    // Negative numbers are presented as positive, and vice versa.
    let isNegative = (cents == 0 || amountString.hasPrefix("-"))
    if isNegative {
        // Set the color to white if it is a negative amount
        preparedString.addAttribute(NSForegroundColorAttributeName, value: CurrentTheme.accounts.cell.amountColor, range: firstCharacters)
            
        if showCents {
            // Add extra alpha to the cents
            preparedString.addAttribute(NSForegroundColorAttributeName, value: CurrentTheme.accounts.cell.amountColorCents, range: lastTwoCharacters)
        }
    } else {
        // Set the color to green if it is a positive amount
        let foregroundColor = colorPositive ? CurrentTheme.accounts.cell.amountColorPositive : CurrentTheme.accounts.cell.amountColor
        preparedString.addAttribute(NSForegroundColorAttributeName, value: foregroundColor, range: firstCharacters)
        
        if showCents {
            // Add extra alpha to the cents
            preparedString.addAttribute(NSForegroundColorAttributeName, value: foregroundColor.withAlphaComponent(0.75), range: lastTwoCharacters)
        }
    }
    
    return preparedString
}

func roundCentsToNearestDollar(_ cents: Int) -> Int {
    return Int(round((Double(cents) / 100.0)) * 100.0)
}

// Returns NSNull if the input is nil. Useful for things like db queries.
func n2N(_ nullableObject: Any?) -> AnyObject {
    return nullableObject == nil ? NSNull() : nullableObject! as AnyObject
}

func <(lhs: Date, rhs: Date) -> Bool {
    return lhs.timeIntervalSince1970 < rhs.timeIntervalSince1970
}

// Color manipulator from: http://stackoverflow.com/questions/11598043/get-slightly-lighter-and-darker-color-from-uicolor

extension NSColor {
    
    func lighter(_ amount : CGFloat = 0.25) -> NSColor {
        return hueColorWithBrightnessAmount(1 + amount)
    }
    
    func darker(_ amount : CGFloat = 0.25) -> NSColor {
        return hueColorWithBrightnessAmount(1 - amount)
    }
    
    fileprivate func hueColorWithBrightnessAmount(_ amount: CGFloat) -> NSColor {
        var hue         : CGFloat = 0
        var saturation  : CGFloat = 0
        var brightness  : CGFloat = 0
        var alpha       : CGFloat = 0
        
        #if os(iOS)
            
            if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
                return NSColor( hue: hue,
                                saturation: saturation,
                                brightness: brightness * amount,
                                alpha: alpha )
            } else {
                return self
            }
            
        #else
            
            if let rgbColor = self.usingColorSpaceName(NSCalibratedRGBColorSpace) {
                rgbColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
                return NSColor( hue: hue,
                                saturation: saturation,
                                brightness: brightness * amount,
                                alpha: alpha )
            } else {
                return self
            }
            
        #endif
        
    }
}
    
// Allows you to compare any two things, which is not possible with ==
func equals(_ lhs: Any?, _ rhs: Any?) -> Bool {
    if lhs as AnyObject? === rhs as AnyObject? {
        return true
    }
    
    if lhs == nil && rhs == nil {
        return true
    }
    
    if (lhs == nil && rhs != nil) || (lhs != nil && rhs == nil) {
        return false
    }
    
    if let lhs = lhs as? String, let rhs = rhs as? String {
        return lhs == rhs
    }
    
    if let lhs = lhs as? Date, let rhs = rhs as? Date {
        return lhs == rhs
    }
    
    if let lhs = lhs as? Data, let rhs = rhs as? Data {
        return lhs == rhs
    }
    
    if let lhs = lhs as? URL, let rhs = rhs as? URL {
        return lhs == rhs
    }
    
    if let lhs = lhs as? Bool, let rhs = rhs as? Bool {
        return lhs == rhs
    }
    
    if let lhs = lhs as? Int, let rhs = rhs as? Int {
        return lhs == rhs
    }
    
    if let lhs = lhs as? Float, let rhs = rhs as? Float {
        return lhs == rhs
    }
    
    if let lhs = lhs as? Double, let rhs = rhs as? Double {
        return lhs == rhs
    }
    
    if let lhs = lhs as? NSArray, let rhs = rhs as? NSArray {
        return lhs.isEqual(rhs)
    }
    
    if let lhs = lhs as? NSDictionary, let rhs = rhs as? NSDictionary {
        return lhs.isEqual(rhs)
    }
    
    return false
}
