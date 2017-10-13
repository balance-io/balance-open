//
//  ThemeGlobals.swift
//  Bal
//
//  Created by Benjamin Baron on 5/25/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

#if os(OSX)
import Foundation
#else
import UIKit
#endif

enum ThemeType: Int {
    case auto   = 0
    case light  = 1
    case dark   = 2
    case open   = 3
}

let primaryDefaultInstitutionColors: [PXColor] = [PXColor(deviceRedInt: 68, green: 180, blue: 195),
                                                  PXColor(deviceRedInt: 242, green: 170, blue: 79),
                                                  PXColor(deviceRedInt: 229, green: 87, blue: 66),
                                                  PXColor(deviceRedInt: 124, green: 138, blue: 142),
                                                  PXColor(deviceRedInt: 75, green: 87, blue: 94),
                                                  PXColor(deviceRedInt: 168, green: 46, blue: 61),
                                                  PXColor(deviceRedInt: 201, green: 44, blue: 44),
                                                  PXColor(deviceRedInt: 27, green: 70, blue: 130),
                                                  PXColor(deviceRedInt: 0, green: 176, blue: 114),
                                                  PXColor(deviceRedInt: 0, green: 148, blue: 255)]
let secondaryDefaultInstitutionColors: [PXColor]  = [PXColor(deviceRedInt: 93, green: 76, blue: 71),
                                                     PXColor(deviceRedInt: 56, green: 113, blue: 169),
                                                     PXColor(deviceRedInt: 5, green: 186, blue: 116),
                                                     PXColor(deviceRedInt: 72, green: 156, blue: 255),
                                                     PXColor(deviceRedInt: 115, green: 174, blue: 66),
                                                     PXColor(deviceRedInt: 189, green: 63, blue: 80),
                                                     PXColor(deviceRedInt: 83, green: 20, blue: 112),
                                                     PXColor(deviceRedInt: 21, green: 56, blue: 105),
                                                     PXColor(deviceRedInt: 55, green: 83, blue: 125),
                                                     PXColor(deviceRedInt: 110, green: 130, blue: 133)]
let defaultInstitutionColors = primaryDefaultInstitutionColors + secondaryDefaultInstitutionColors

let searchTokenTextColor = PXColor.white
let accountTokenColor = PXColor(deviceRedInt: 131, green: 152, blue: 163)
let categoryTokenColor = PXColor(deviceRedInt: 45, green: 172, blue: 242)
let nameTokenColor = PXColor(deviceRedInt: 139, green: 99, blue: 255)
let amountTokenColor = PXColor(deviceRedInt: 88, green: 184, blue: 33)
let whenTokenColor = PXColor(deviceRedInt: 179, green: 71, blue: 171)
let searchTokenBackgroundColors: [SearchToken: PXColor] = [.in: accountTokenColor,
                                                           .inNot: accountTokenColor,
                                                           .account: accountTokenColor,
                                                           .accountNot: accountTokenColor,
                                                           .accountMatches: accountTokenColor,
                                                           .accountMatchesNot: accountTokenColor,
                                                           .category: categoryTokenColor,
                                                           .categoryNot: categoryTokenColor,
                                                           .categoryMatches: categoryTokenColor,
                                                           .categoryMatchesNot: categoryTokenColor,
                                                           .name: nameTokenColor,
                                                           .nameNot: nameTokenColor,
                                                           .nameMatches: nameTokenColor,
                                                           .nameMatchesNot: nameTokenColor,
                                                           .amount: amountTokenColor,
                                                           .amountNot: amountTokenColor,
                                                           .under: amountTokenColor,
                                                           .over: amountTokenColor,
                                                           .when: whenTokenColor,
                                                           .whenNot: whenTokenColor,
                                                           .before: whenTokenColor,
                                                           .after: whenTokenColor]

func nextAvailableDefaultInstitutionColorIndex() -> Int {
    let usedIndexes = defaults.institutionColors.values
    let availablePrimaryIndexes = Array(0...9).filter({!usedIndexes.contains($0)})
    let availableSecondaryIndexes = Array(10...19).filter({!usedIndexes.contains($0)})
    
    return availablePrimaryIndexes.randomItem ?? availableSecondaryIndexes.randomItem!
}

func defaultInstitutionColorForIndex(_ index: Int) -> PXColor {
    if index < 10 {
        return primaryDefaultInstitutionColors[index]
    } else {
        let newIndex = index - 10
        return secondaryDefaultInstitutionColors[newIndex]
    }
}
