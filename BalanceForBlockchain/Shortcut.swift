//
//  Shortcut.swift
//  Bal
//
//  Created by Benjamin Baron on 5/14/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import AppKit
import MASShortcut

class Shortcut {    
    static let shortcutUserDefaultsKey = "shortcutUserDefaultsKey"
    
    static var defaultShortcut: MASShortcut {
        // B
        let keyCode = UInt(kVK_ANSI_B)
        // Ctrl + Alt + CMD
        let keyMask: NSEventModifierFlags = [.command, .control, .option]
        return MASShortcut(keyCode: keyCode, modifierFlags: keyMask.rawValue)
    }
    
    static var customShortcutSaved: Bool {
        return UserDefaults.standard.object(forKey: shortcutUserDefaultsKey) == nil ? false : true
    }
    
    static func setupDefaultShortcut() {
        MASShortcutMonitor.shared().register(defaultShortcut) {
            shortcutAction()
        }
        MASShortcutBinder.shared().bindShortcut(withDefaultsKey: shortcutUserDefaultsKey) { 
            shortcutAction()
        }
    }
    
    static func shortcutAction() {
        NotificationCenter.postOnMainThread(name: Notifications.TogglePopover)
    }
}
