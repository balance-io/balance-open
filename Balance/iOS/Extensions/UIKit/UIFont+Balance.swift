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
        }
        
        static func monoFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
            switch weight {
            case .regular:
                return UIFont(name: "SFMono-Regular", size: size)!
            case .bold:
                return UIFont(name: "SFMono-Bold", size: size)!
            case .semibold:
                return UIFont(name: "SFMono-Semibold", size: size)!
            case .medium:
                return UIFont(name: "SFMono-Medium", size: size)!
            default:
                return UIFont(name: "SFMono-Regular", size: size)!
            }
        }
    }
}
