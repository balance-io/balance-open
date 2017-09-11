//
//  TouchBarShared.swift
//  Bal
//
//  Created by Benjamin Baron on 12/10/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation
import BalanceVectorGraphics
import JMSRangeSlider

@available(OSX 10.12.2, *)
struct TouchBarShared {
    static func createAccountButtonsScrollview(target: AnyObject, accountButtonAction: Selector, showAddAccountButton: Bool = false, addAccountButtonAction: Selector? = nil, showAllAccountsButton: Bool = false, allAccountsButtonAction: Selector? = nil) -> NSScrollView {
        
        var buttons = [Button]()
        
        // Create all accounts button if needed
        if showAllAccountsButton, let allAccountsButtonAction = allAccountsButtonAction {
            let title = "All Accounts"
            let button = Button(title: title, target: target, action: allAccountsButtonAction)
            let width = title.size(font: CurrentTheme.defaults.touchBarFont).width + 20
            button.frame = NSRect(x: 0, y: 0, width: width, height: 30)
//            button.frame = NSRect(x: 0, y: 0, width: 130, height: 30)
//            button.image = #imageLiteral(resourceName: "tb-account")
//            button.imagePosition = .imageLeading
            buttons.append(button)
        }
        
        // Create account buttons
        let institutions = InstitutionRepository.si.allInstitutions(sorted: true)
        for (index, institution) in institutions.enumerated() {
            if let buttonDrawingFunction = TouchBarAccountButtons.drawingFunction(forType: institution.sourceInstitutionId) {
                let button = PaintCodeButton(frame: NSRect(x: 0, y: 0, width: 86, height: 30))
                button.drawingFunction = buttonDrawingFunction
                button.target = target
                button.action = accountButtonAction
                button.tag = index
                buttons.append(button)
            } else {
                let button = Button(title: institution.name, target: self, action: accountButtonAction)
                let width = institution.name.size(font: CurrentTheme.defaults.touchBarFont).width + 20
                button.frame = NSRect(x: 0, y: 0, width: width, height: 30)
                button.tag = index
                button.bezelColor = institution.displayColor
                buttons.append(button)
            }
        }
        
        // Create add account button if needed
        if showAddAccountButton, let addAccountButtonAction = addAccountButtonAction {
            let button = Button(title: "", target: target, action: addAccountButtonAction)
            button.frame = NSRect(x: 0, y: 0, width: 86, height: 30)
            button.image = #imageLiteral(resourceName: "tb-add-account")
            buttons.append(button)
        }
        
        // Calculate the size
        let spacing: CGFloat = 10.0
        let totalButtonWidth = buttons.reduce(0.0, {$0 + $1.frame.size.width})
        let width = totalButtonWidth + (CGFloat(buttons.count - 1) * spacing)
        
        // Setup the scrollview
        let scrollView = ScrollView()
        let documentView = View()
        
        // Add the buttons to the scrollview
        var leading: CGFloat = 0.0
        for button in buttons {
            documentView.addSubview(button)
            let buttonWidth = button.frame.size.width
            button.snp.makeConstraints { make in
                make.leading.equalTo(leading)
                make.width.equalTo(buttonWidth)
                make.height.equalTo(30)
                make.top.equalTo(documentView)
            }
            leading += buttonWidth + spacing
        }
        
        // Setup document view constraints
        scrollView.documentView = documentView
        documentView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(width)
            make.height.equalTo(30)
        }
        
        return scrollView
    }
}
