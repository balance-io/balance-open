//
//  NotificationsTabTouchBar.swift
//  Bal
//
//  Created by Benjamin Baron on 5/22/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

@available(OSX 10.12.2, *)
fileprivate extension NSTouchBarItem.Identifier {
    static var createRule = NSTouchBarItem.Identifier("software.balanced.balancemac.createRule")
}

@available(OSX 10.12.2, *)
extension NotificationsTabViewController : NSTouchBarDelegate {
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        
        var itemIdentifiers = [NSTouchBarItem.Identifier]()
        
        // Add create rule button
        itemIdentifiers.append(NSTouchBarItem.Identifier.createRule)
        
        touchBar.defaultItemIdentifiers = itemIdentifiers
        return touchBar
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        let item = NSCustomTouchBarItem(identifier: identifier)
        
        if identifier == NSTouchBarItem.Identifier.createRule {
            let button = NSButton(title: "Create a Rule", target: self, action: #selector(touchBarCreateRule(_:)))
            button.imagePosition = .imageLeading
            button.image = #imageLiteral(resourceName: "tb-create-rule")
            item.view = button
        }
        
        return item
    }
    
    @objc fileprivate func touchBarCreateRule(_ sender: NSButton) {
        addRule()
    }
}
