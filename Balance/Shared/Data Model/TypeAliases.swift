//
//  TypeAliases.swift
//  Bal
//
//  Created by Benjamin Baron on 7/14/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

#if os(OSX)
    import AppKit
    public typealias Rect  = NSRect
    public typealias Size  = NSSize
    public typealias Point = NSPoint
    public typealias Color = NSColor
    public typealias Font  = NSFont
#else
    import UIKit
    public typealias Rect  = CGRect
    public typealias Size  = CGSize
    public typealias Point = CGPoint
    public typealias Color = UIColor
    public typealias Font  = UIFont
#endif

// Various completion handlers depending on the data
typealias SuccessErrorHandler = (_ success: Bool, _ error: Error?) -> Void
typealias SuccessErrorsHandler = (_ success: Bool, _ errors: [Error]?) -> Void
