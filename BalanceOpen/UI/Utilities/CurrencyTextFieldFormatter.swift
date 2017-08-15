//
//  CurrencyTextFieldFormatter.swift
//  BalanceOpen
//
//  Created by Red Davis on 15/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Cocoa


internal final class CurrencyTextFieldFormatter: NumberFormatter
{
    // Private
    private let nonDigitCharacterSet = CharacterSet.decimalDigits.inverted
    private let decimalPointCharacterSet = CharacterSet(charactersIn: ".")
    
    // MARK: -
    
    override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool
    {
        guard let lastCharacter = partialString.last else
        {
            return true
        }
        
        let currentString = String(partialString.dropLast())
        let newCharacterString = String(lastCharacter)
        
        // Validations
        let containsNonDigitCharacters = newCharacterString.rangeOfCharacter(from: self.nonDigitCharacterSet) != nil
        let containsDecimalPoint = newCharacterString.rangeOfCharacter(from: self.decimalPointCharacterSet) != nil
        let alreadyContainsDecimalPoint = currentString.rangeOfCharacter(from: self.decimalPointCharacterSet) != nil
        
        return (containsDecimalPoint && !alreadyContainsDecimalPoint) || !containsNonDigitCharacters
    }
}
