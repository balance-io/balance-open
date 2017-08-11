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

fileprivate var amountFormatter: NumberFormatter = {
    let centsFormatter = NumberFormatter()
    centsFormatter.numberStyle = .currency
    return centsFormatter
}()

// TODO: Add proper locale support for currency symbol location
func amountToString(amount: Int, currency: Currency, showNegative: Bool = false)  -> String {
    assert(Thread.isMainThread, "Must be used from main thread")
    
    let amount = Double(amount) / pow(10.0, Double(currency.decimals))
    amountFormatter.currencySymbol = currency.symbol
    amountFormatter.minimumFractionDigits = currency.decimals
    amountFormatter.maximumFractionDigits = currency.decimals
    
    let amountString = amountFormatter.string(from: NSNumber(value: amount))!
    let minusRemoved = showNegative ? amountString : amountString.replacingOccurrences(of: "-", with: "")
    
    return minusRemoved
}

func amountToStringFormatted(amount: Int, currency: Currency, showNegative: Bool = false, colorPositive: Bool = true)  -> NSAttributedString {
    assert(Thread.isMainThread, "Must be used from main thread")
    
    let amountString = amountToString(amount: amount, currency: currency, showNegative: showNegative)
    let preparedString = NSMutableAttributedString(string: amountString, attributes: [NSAttributedStringKey.paragraphStyle: rightParagraphStyle])
    
    let count = preparedString.string.length
    let decimalCharsCount = count - currency.decimals - 1
    let showDecimal = currency.decimals > 0
    let firstCharacters = NSRange(location: 0, length: showDecimal ? decimalCharsCount : count)
    let decimalCharacters = NSRange(location: decimalCharsCount, length: currency.decimals + 1)
    
    // Negative numbers are presented as positive, and vice versa.
    let isNegative = (amount == 0 || amountString.hasPrefix("-"))
    if isNegative {
        // Set the color to white if it is a negative amount
        preparedString.addAttribute(NSAttributedStringKey.foregroundColor, value: CurrentTheme.accounts.cell.amountColor, range: firstCharacters)
        
        if showDecimal {
            // Add extra alpha to the cents
            preparedString.addAttribute(NSAttributedStringKey.foregroundColor, value: CurrentTheme.accounts.cell.amountColorCents, range: decimalCharacters)
        }
    } else {
        // Set the color to green if it is a positive amount
        let foregroundColor = colorPositive ? CurrentTheme.accounts.cell.amountColorPositive : CurrentTheme.accounts.cell.amountColor
        preparedString.addAttribute(NSAttributedStringKey.foregroundColor, value: foregroundColor, range: firstCharacters)
        
        if showDecimal {
            // Add extra alpha to the cents
            preparedString.addAttribute(NSAttributedStringKey.foregroundColor, value: foregroundColor.withAlphaComponent(0.75), range: decimalCharacters)
        }
    }
    
    return preparedString
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
            
            if let rgbColor = self.usingColorSpaceName(NSColorSpaceName.calibratedRGB) {
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

// Allow for simple string exceptions
extension String: LocalizedError {
    public var errorDescription: String? { return self }
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

func checkType<U>(_ dict: Dictionary<String, AnyObject>, file: String = #file, name: String, line: Int = #line, function: String = #function) throws -> U {
    let value = dict[name]
    return try checkType(value, name: name, file: file, line: line, function: function)
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
