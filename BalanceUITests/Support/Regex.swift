//
//  Regex.swift
//  Bal
//
//  Created by Jamie Rumbelow on 08/09/2016.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

class Regex {
    let regex: NSRegularExpression
    let pattern: String
    
    init(_ pattern: String) {
        self.pattern = pattern
        try! self.regex = NSRegularExpression(pattern: self.pattern, options: .anchorsMatchLines)
    }
    
    func matches(_ input: String) -> Bool {
        return (self.regex.matches(in: input, options: .reportCompletion, range: NSMakeRange(0, input.length))).count > 0
    }
}

infix operator =~

func =~ (input: String, pattern: String) -> Bool {
    return Regex(pattern).matches(input)
}
