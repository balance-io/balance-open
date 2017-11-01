//
//  AccountsViewControllerTouchBar.swift
//  Bal
//
//  Created by Benjamin Baron on 5/22/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation
import BalanceVectorGraphics

@available(OSX 10.12.2, *)
fileprivate extension NSTouchBarItem.Identifier {
    static var searchTransactions = NSTouchBarItem.Identifier("software.balanced.balancemac.searchTransactions")
    static var accountsScrollView = NSTouchBarItem.Identifier("software.balanced.balancemac.accountsScrollView")
}

@available(OSX 10.12.2, *)
extension AccountsTabViewController : NSTouchBarDelegate {
    override func makeTouchBar() -> NSTouchBar? {
        return nil
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.defaultItemIdentifiers = [.searchTransactions, .accountsScrollView]
        return touchBar
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        let item = NSCustomTouchBarItem(identifier: identifier)
        let items = touchBar.defaultItemIdentifiers
        
        if identifier == .searchTransactions {
            let button = NSButton(title: "Transactions", target: self, action: #selector(touchBarSearchTransactions(_:)))
            button.imagePosition = .imageLeading
            button.image = #imageLiteral(resourceName: "tb-search")
            item.view = button
        } else if identifier == .accountsScrollView {
            item.view = TouchBarShared.createAccountButtonsScrollview(target: self,
                                                                      accountButtonAction:  #selector(touchBarSearchAccount(_:)),
                                                                      showAddAccountButton: true,
                                                                      addAccountButtonAction: #selector(touchBarAddAccount(_:)))
        } else if let itemIndex = items.index(of: identifier) {
            let accountIndex = itemIndex - 1
            let model = viewModel.data.keys[accountIndex]
            
            if let buttonDrawingFunction = TouchBarAccountButtons.drawingFunction(forType: model.sourceInstitutionId) {
                let button = PaintCodeButton(frame: NSRect(x: 0, y: 0, width: 86, height: 30))
                button.drawingFunction = buttonDrawingFunction
                button.target = self
                button.action = #selector(touchBarSearchTransactions(_:))
                button.tag = accountIndex
                item.view = button
            } else {
                let button = NSButton(title: model.name, target: self, action: #selector(touchBarSearchAccount(_:)))
                button.tag = accountIndex
                button.bezelColor = model.displayColor
                item.view = button
            }
        }
        
        return item
    }
    
    @objc fileprivate func touchBarSearchTransactions(_ sender: NSButton) {
        NotificationCenter.postOnMainThread(name: Notifications.ShowSearch)
    }
    
    @objc fileprivate func touchBarSearchAccount(_ sender: NSButton) {
        let institution = InstitutionRepository.si.allInstitutions(sorted: true)[sender.tag]
        Search.searchTransactions(accountOrInstitutionName: institution.name)
    }
    
    @objc fileprivate func touchBarAddAccount(_ sender: NSButton) {
        NotificationCenter.postOnMainThread(name: Notifications.ShowAddAccount)
    }
}
