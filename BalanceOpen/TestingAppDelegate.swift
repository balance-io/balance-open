//
//  TestingAppDelegate.swift
//  BalanceOpen
//
//  Created by Raimon Lapuente on 07/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation
import AppKit

class TestingAppDelegate: NSObject, NSApplicationDelegate {
    let window = NSWindow()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        window.makeKeyAndOrderFront(NSApp)
        window.center()
    }
}

