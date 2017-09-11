//
//  NSAttributedString.swift
//  Bal
//
//  Created by Benjamin Baron on 6/28/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

#if os(OSX)
import Foundation

extension NSAttributedString {
    
    class func hyperlinkFromString(_ string: String, url: URL) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string)
        let range = NSMakeRange(0, attributedString.length)
        let attributes: [NSAttributedStringKey : Any] = [NSAttributedStringKey.link: url.absoluteString as AnyObject,
                                                         NSAttributedStringKey.foregroundColor: PXColor.blue,
                                                         NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle]
        attributedString.addAttributes(attributes, range: range)
        return attributedString
    }
}
#endif
