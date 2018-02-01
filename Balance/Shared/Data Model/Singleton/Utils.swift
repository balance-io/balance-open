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
    if let info = Bundle.main.infoDictionary, let version = info["CFBundleShortVersionString"] as? String {
        return "Balance v\(version)"
    }
    return "Unknown"
}()

var appVersionAndBuildString: String = {
    return "\(appVersionString) (build \(appBuildString))"
}()

var osVersionString: String = {
    #if os(iOS)
        return "iOS " + ProcessInfo.processInfo.operatingSystemVersionString
    #else
        return "macOS " + ProcessInfo.processInfo.operatingSystemVersionString
    #endif
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
    try? fileManager.createDirectory(at: pathUrl, withIntermediateDirectories: true, attributes: nil)
    return pathUrl
}()

let jsonDateFormatter: DateFormatter = {
    let jsonDateFormatter = DateFormatter()
    jsonDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    jsonDateFormatter.timeZone = TimeZone(identifier: "UTC")
    return jsonDateFormatter
}()

let jsonWithMillisecondsDateFormatter: DateFormatter = {
    let jsonDateFormatter = DateFormatter()
    jsonDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    jsonDateFormatter.timeZone = TimeZone(identifier: "UTC")
    return jsonDateFormatter
}()

let centeredParagraphStyle: NSParagraphStyle = {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center
    return paragraphStyle
}()

let leftParagraphStyle: NSParagraphStyle = {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .left
    return paragraphStyle
}()

let rightParagraphStyle: NSParagraphStyle = {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .right
    return paragraphStyle
}()

fileprivate var decimalFormatter: NumberFormatter = {
    let decimalFormatter = NumberFormatter()
    decimalFormatter.numberStyle = .decimal
    decimalFormatter.maximumFractionDigits = 2
    return decimalFormatter
}()

@available(*, deprecated)
fileprivate var centsFormatter: NumberFormatter = {
    let centsFormatter = NumberFormatter()
    centsFormatter.currencySymbol = "$"
    centsFormatter.numberStyle = .currency
    centsFormatter.maximumFractionDigits = 2
    return centsFormatter
}()

@available(*, deprecated)
fileprivate var centsFormatterNoDecimal: NumberFormatter = {
    let centsFormatter = NumberFormatter()
    centsFormatter.currencySymbol = "$"
    centsFormatter.numberStyle = .currency
    centsFormatter.maximumFractionDigits = 0
    return centsFormatter
}()

// Takes in strings representing dollars like $300.00, $500, 40 and returns their value in cents
@available(*, deprecated)
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

@available(*, deprecated)
func centsToString(_ cents: Int, showNegative: Bool = false, showCents: Bool = true)  -> String {
    let amount = Double(cents) / 100.00
    let formatter = showCents ? centsFormatter : centsFormatterNoDecimal
    let amountString = formatter.string(from: NSNumber(value: amount))!
    let minusRemoved = showNegative ? amountString : amountString.replacingOccurrences(of: "-", with: "")
    
    return minusRemoved
}

fileprivate var amountFormatter: NumberFormatter = {
    let centsFormatter = NumberFormatter()
    centsFormatter.numberStyle = .currency
    return centsFormatter
}()

// TODO: Add proper locale support for currency symbol location
func amountToString(amount: Int, currency: Currency, decimalsOverride: Int? = nil, showNegative: Bool = false, showCodeAfterValue: Bool = false)  -> String {
    assert(Thread.isMainThread, "Must be used from main thread")
    
    let decimals = decimalsOverride ?? currency.decimals
    
    let amount = Double(amount) / pow(10.0, Double(decimals))
    amountFormatter.currencySymbol = showCodeAfterValue ? "" : currency.symbol
    amountFormatter.minimumFractionDigits = currency.isFiat ? currency.decimals : 1
    amountFormatter.maximumFractionDigits = decimals
    
    let amountString = amountFormatter.string(from: NSNumber(value: amount))!
    let minusRemoved = showNegative ? amountString : amountString.replacingOccurrences(of: "-", with: "")
    
    return showCodeAfterValue ? "\(minusRemoved) \(currency.code)" : minusRemoved
}

func paddedInteger(for amount: Double, currencyCode: String) -> Int {
    let decimals = Currency.rawValue(currencyCode).decimals
    return amount.integerValueWith(decimals: decimals)
}

// Returns NSNull if the input is nil. Useful for things like db queries.
// TODO: Figure out why FMDB in Swift won't take nil arguments in var args functions
func n2N(_ nullableObject: Any?) -> AnyObject {
    return nullableObject == nil ? NSNull() : nullableObject! as AnyObject
}

func <(lhs: Date, rhs: Date) -> Bool {
    return lhs.timeIntervalSince1970 < rhs.timeIntervalSince1970
}

// Color manipulator from: http://stackoverflow.com/questions/11598043/get-slightly-lighter-and-darker-color-from-uicolor

#if os(OSX)
    
    import Cocoa
    public  typealias PXColor = NSColor
    
#else
    
    import UIKit
    public  typealias PXColor = UIColor
    
#endif

extension PXColor {
    
    func lighter(_ amount : CGFloat = 0.25) -> PXColor {
        return hueColorWithBrightnessAmount(1 + amount)
    }
    
    func darker(_ amount : CGFloat = 0.25) -> PXColor {
        return hueColorWithBrightnessAmount(1 - amount)
    }
    
    fileprivate func hueColorWithBrightnessAmount(_ amount: CGFloat) -> PXColor {
        var hue         : CGFloat = 0
        var saturation  : CGFloat = 0
        var brightness  : CGFloat = 0
        var alpha       : CGFloat = 0
        
        #if os(iOS)
            
            if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
                return PXColor( hue: hue,
                                saturation: saturation,
                                brightness: brightness * amount,
                                alpha: alpha )
            } else {
                return self
            }
            
        #else
            
            if let rgbColor = self.usingColorSpaceName(NSColorSpaceName.calibratedRGB) {
                rgbColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
                return PXColor( hue: hue,
                                saturation: saturation,
                                brightness: brightness * amount,
                                alpha: alpha )
            } else {
                return self
            }
            
        #endif
        
    }
}

#if os(OSX)
//https://github.com/ricburton/NSImage-MISSINGTint
//TODO Turn this into an extension on NSImage
//
//        extension NSImage {
//
//            func tintWithColor(color: NSColor) -> NSImage {
//                image.lockFocus()
//                color.set()
//                var rect = NSZeroRect
//                rect.size = image.size
//                NSRectFillUsingOperation(rect, .CompositeSourceAtop)
//                image.unlockFocus()
//                return image
//            }
func tintImageWithColor(_ image: NSImage, color: NSColor) -> NSImage {
    image.lockFocus()
    color.set()
    var rect = NSZeroRect
    rect.size = image.size
    rect.fill(using: .sourceAtop)
    image.unlockFocus()
    return image
}
#endif
    
// Allows you to compare any two things, which is not possible with ==
func equals(_ lhs: Any?, _ rhs: Any?) -> Bool {
//    return isEqual(lhs as AnyObject?, rhs as AnyObject?)
//}
//func equals(_ lhs: AnyObject?, _ rhs: AnyObject?) -> Bool {
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

// Generic type checking, useful for JSON parsing
func checkType<T, U>(_ value: T?, name: String, file: String = #file, line: Int = #line, function: String = #function) throws -> U {
    let fileName = NSURL(fileURLWithPath: file).deletingPathExtension?.lastPathComponent ?? file
    let functionName = function.components(separatedBy: "(").first ?? function
    
    guard let value = value else {
        throw "[\(fileName):\(line) \(functionName) \"\(name)\"] Expected \(U.self), but value was nil"
    }
    
    guard let result = value as? U else {
        throw "[\(fileName):\(line) \(functionName) \"\(name)\"] Expected \(U.self), but it was an \(type(of: value)) with value: \(value)"
    }
    
    return result
}

/*
 * Crypto
 */

enum CryptoAlgorithm {
    case md5, sha1, sha224, sha256, sha384, sha512
    
    var hmacAlgorithm: CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .md5:      result = kCCHmacAlgMD5
        case .sha1:     result = kCCHmacAlgSHA1
        case .sha224:   result = kCCHmacAlgSHA224
        case .sha256:   result = kCCHmacAlgSHA256
        case .sha384:   result = kCCHmacAlgSHA384
        case .sha512:   result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    var digestLength: Int {
        var result: Int32 = 0
        switch self {
        case .md5:      result = CC_MD5_DIGEST_LENGTH
        case .sha1:     result = CC_SHA1_DIGEST_LENGTH
        case .sha224:   result = CC_SHA224_DIGEST_LENGTH
        case .sha256:   result = CC_SHA256_DIGEST_LENGTH
        case .sha384:   result = CC_SHA384_DIGEST_LENGTH
        case .sha512:   result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
    
    // TODO: Discuss pros/cons of using if/let pattern and optional return values for things that are
    // essentially guaranteed to always work... I hate force unwrapping, but also hate pushing optionals
    // around when unnecessary.
    func hmac(body: String, key: String) -> String {
        let cKey = key.cString(using: .utf8)!
        let str = body.cString(using: .utf8)!
        
        var result = [CUnsignedChar](repeating: 0, count: digestLength)
        
        CCHmac(hmacAlgorithm, cKey, strlen(cKey), str, strlen(str), &result)
        let digest = result.map {
            String(format: "%02hhx", $0)
        }
        
        return digest.joined()
    }
}
