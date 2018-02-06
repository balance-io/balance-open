//
//  UIView.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 1/10/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    // MARK: Size
    
    static var deviceWidth: CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    static var deviceHeight: CGFloat {
        return UIScreen.main.bounds.size.height
    }
    
    static func getHorizontalSize(with percentage: Float) -> CGFloat {
        guard percentage > 0, percentage < 100 else {
            return 0
        }
        
        return (deviceWidth / 100.0) * CGFloat(percentage)
    }
    
    static func getVerticalSize(with percentage: Float) -> CGFloat {
        guard percentage > 0, percentage < 100 else {
            return 0
        }
        
        return (deviceHeight / 100.0) * CGFloat(percentage)
    }
    
    // MARK: Shadow
    
    func dropShadow(scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 10
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
