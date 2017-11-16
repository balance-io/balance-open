//
//  UIFont+Balance.swift
//  BalanceiOS
//
//  Created by Red Davis on 08/11/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


internal extension UIFont {
    internal struct Balance {
        static func font(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
            return UIFont.systemFont(ofSize: size, weight: weight)
            
            // TODO: Custom font
//            switch weight {
//            case .regular:
//
//            case .light:
//
//            case .bold:
//
//            case .semibold:
//
//            case .black:
//
//            default:
//
//            }
        }
    }
}
