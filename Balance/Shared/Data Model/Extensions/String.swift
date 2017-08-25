//
//  String.swift
//  Bal
//
//  Created by Benjamin Baron on 5/23/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

extension String {

    static func random(_ length: Int = 32) -> String {
        let chars = Array<Character>("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".characters)
        let charsCount = UInt32(chars.count)
        
        var string = ""
        for _ in 0..<length {
            let index = Int(arc4random_uniform(charsCount))
            let randomChar = chars[index]
            string.append(randomChar)
        }
        
        return string
    }
    
    //
    // MARK: - Capitalizion -
    //
    
    var capitalizedStringIfAllCaps: String {
        // For example, fixes ITUNES while preventing iTunes from becoming Itunes
        if self == uppercased() {
            // Capitalize the string
            var capitalized = self.capitalized
            
            // Make common website TLDs look right (i.e. Amazon.com instead of Amazon.Com)
            capitalized = capitalized.replacingOccurrences(of: ".Com", with: ".com")
            capitalized = capitalized.replacingOccurrences(of: ".Net", with: ".net")
            capitalized = capitalized.replacingOccurrences(of: ".Org", with: ".org")
            capitalized = capitalized.replacingOccurrences(of: "Www.", with: "www.")
            
            // Capitalize place abbreviations (i.e. NYC instead of Nyc)
            capitalized = capitalized.replacingOccurrences(of: "Nyc", with: "NYC")
            capitalized = capitalized.replacingOccurrences(of: "Jfk", with: "JFK")
            capitalized = capitalized.replacingOccurrences(of: "Sfo", with: "SFO")
            capitalized = capitalized.replacingOccurrences(of: "Cvs", with: "CVS")
            return capitalized
        } else {
            return self
        }
    }
    
    var capitalizedFirstLetterString: String {
        if characters.count > 1 {
            return "\(substring(to: 1).uppercased())\(substring(from: 1))"
        } else {
            return capitalized
        }
    }
    
    #if os(OSX)
    func size(font: NSFont, targetSize: CGSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)) -> NSSize {
        let attributedString = NSAttributedString(string: self, attributes: [NSAttributedStringKey.font: font])
        let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
        let size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, attributedString.length), nil, targetSize, nil);
        
        return size
    }
    #endif
    
    //
    // MARK: - Easier indexing -
    //
    
    var length: Int {
        return characters.count
    }
    
    func index(offset: Int) -> Index {
        return index(startIndex, offsetBy: offset)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(offset: from)
        return String(self[fromIndex..<endIndex])
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(offset: to)
        return String(self[startIndex..<toIndex])
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(offset: r.lowerBound)
        let endIndex = index(offset: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
    
    //
    // MARK: - URL Query Encoding -
    //
    
    // By default, the URLQueryAllowedCharacterSet is meant to allow encoding of entire query strings. This is
    // a problem because it won't handle, for example, a password containing an & character. So we need to remove
    // those characters from the character set. Then the stringByAddingPercentEncodingWithAllowedCharacters method
    // will work as expected.
    fileprivate static var URLQueryEncodedValueAllowedCharacters: CharacterSet = {
        var charSet = CharacterSet.urlQueryAllowed
        charSet.remove(charactersIn: "?&=@+/'")
        return charSet
    }()
    
    // Used to encode individual query parameters
    var URLQueryParameterEncodedValue: String {
        return self.addingPercentEncoding(withAllowedCharacters: String.URLQueryEncodedValueAllowedCharacters) ?? self
    }
    
    // Used to encode entire query strings
    var URLQueryStringEncodedValue: String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? self
    }
}
