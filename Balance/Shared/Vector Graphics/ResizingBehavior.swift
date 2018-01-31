//
//  ResizingBehavior.swift
//  BalanceVectorGraphics
//
//  Created by Benjamin Baron on 12/10/16.
//  Copyright © 2016 Balanced Software. All rights reserved.
//

import Foundation

internal enum ResizingBehavior: Int {
    case aspectFit /// The content is proportionally resized to fit into the target rectangle.
    case aspectFill /// The content is proportionally resized to completely fill the target rectangle.
    case stretch /// The content is stretched to match the entire target rectangle.
    case center /// The content is centered in the target rectangle, but it is NOT resized.
    
    internal func apply(rect: Rect, target: Rect) -> Rect {
        if rect == target || target == Rect.zero {
            return rect
        }
        
        var scales = Size.zero
        scales.width = abs(target.width / rect.width)
        scales.height = abs(target.height / rect.height)
        
        switch self {
        case .aspectFit:
            scales.width = min(scales.width, scales.height)
            scales.height = scales.width
        case .aspectFill:
            scales.width = max(scales.width, scales.height)
            scales.height = scales.width
        case .stretch:
            break
        case .center:
            scales.width = 1
            scales.height = 1
        }
        
        var result = rect.standardized
        result.size.width *= scales.width
        result.size.height *= scales.height
        result.origin.x = target.minX + (target.width - result.width) / 2
        result.origin.y = target.minY + (target.height - result.height) / 2
        return result
    }
}
