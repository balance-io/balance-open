//
//  String.swift
//  Bal
//
//  Created by Benjamin Baron on 5/23/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import AppKit

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
        if self == self.uppercased() {
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
        if self.characters.count > 1 {
            let index = self.characters.index(self.startIndex, offsetBy: 1)
            return "\(self.substring(to: index).uppercased())\(self.substring(from: index))"
        } else {
            return self.capitalized
        }
    }
    
    func size(font: NSFont, targetSize: CGSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)) -> NSSize {
        let attributedString = NSAttributedString(string: self, attributes: [NSAttributedStringKey.font: font])
        let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
        let size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, attributedString.length), nil, targetSize, nil);
        
        return size
    }
    
    // MARK: Easier indexing
    
    var length: Int {
        return self.characters.count
    }
    
    func index(offset: Int) -> Index {
        return self.index(startIndex, offsetBy: offset)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(offset: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(offset: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(offset: r.lowerBound)
        let endIndex = index(offset: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
}
