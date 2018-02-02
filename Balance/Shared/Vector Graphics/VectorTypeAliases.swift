//
//  VectorTypeAliases.swift
//  BalanceVectorGraphics
//
//  Created by Benjamin Baron on 12/10/16.
//  Copyright © 2016 Balanced Software. All rights reserved.
//

public typealias DrawingFunction = (_ frame: Rect) -> (Void)
public typealias ButtonDrawingFunction = (_ frame: Rect, _ original: Bool, _ pressed: Bool) -> Void
public typealias TextButtonDrawingFunction = (_ frame: Rect, _ buttonText: String, _ original: Bool, _ pressed: Bool, _ buttonTextColor: Color) -> Void
