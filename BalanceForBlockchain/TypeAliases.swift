//
//  TypeAliases.swift
//  BalanceVectorGraphics
//
//  Created by Benjamin Baron on 12/10/16.
//  Copyright © 2016 Balanced Software. All rights reserved.
//

import Foundation

public typealias DrawingFunction = (_ frame: NSRect) -> (Void)
public typealias ButtonDrawingFunction = (_ frame: NSRect, _ original: Bool, _ pressed: Bool) -> Void
public typealias TextButtonDrawingFunction = (_ frame: NSRect, _ buttonText: String, _ original: Bool, _ pressed: Bool, _ buttonTextColor: NSColor) -> Void
