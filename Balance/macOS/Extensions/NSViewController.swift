//
//  NSViewController.swift
//  Bal
//
//  Created by Benjamin Baron on 12/11/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

extension NSViewController {
    func invalidateTouchBar() {
        if #available(OSX 10.12.2, *) {
            self.touchBar = nil
        }
    }
}
