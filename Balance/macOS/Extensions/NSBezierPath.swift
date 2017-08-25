//
//  NSBezierPath.swift
//  Bal
//
//  Created by Benjamin Baron on 12/10/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

// Adapted from https://github.com/johnmcneilstudio/JMSRangeSlider
extension NSBezierPath {
    var cgPath: CGPath {
        let path = CGMutablePath()
        let points = UnsafeMutablePointer<NSPoint>.allocate(capacity: 3)
        let numElements = self.elementCount
        
        if numElements > 0 {
            var didClosePath = true
            for index in 0..<numElements {
                let pathType = self.element(at: index, associatedPoints: points)
                switch pathType {
                case .moveToBezierPathElement:
                    path.move(to: points[0])
                case .lineToBezierPathElement:
                    path.addLine(to: points[0])
                    didClosePath = false
                case .curveToBezierPathElement:
                    path.addCurve(to: points[2], control1: points[0], control2: points[1])
                    didClosePath = false
                case .closePathBezierPathElement:
                    path.closeSubpath()
                    didClosePath = true
                }
            }
            
            if !didClosePath {
                path.closeSubpath()
            }
        }
        
        points.deallocate(capacity: 3)
        return path
    }
}
