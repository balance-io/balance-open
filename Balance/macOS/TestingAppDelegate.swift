//
//  TestingAppDelegate.swift
//  Bal
//
//  Created by Raimon Lapuente on 30/05/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

class TestingAppDelegate: NSObject, NSApplicationDelegate {
    let window = NSWindow()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        window.styleMask = [.closable, .titled, .miniaturizable]
        window.makeKeyAndOrderFront(NSApp)
        window.center()
    }
}
