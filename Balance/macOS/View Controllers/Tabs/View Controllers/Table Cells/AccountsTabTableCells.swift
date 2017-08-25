//
//  AccountsTabTableCells.swift
//  Bal
//
//  Created by Benjamin Baron on 5/22/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation
import BalanceVectorGraphics
import Crashlytics

class AccountsTabGroupCell: View {
    var headerView: NSView?
    
    init() {
        super.init(frame: NSZeroRect)
        self.layerBackgroundColor = CurrentTheme.defaults.cell.backgroundColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    func updateModel(_ model: Institution) {
        self.headerView?.removeFromSuperview()
        self.headerView = nil
        
        let sourceInstitutionId = institutionsDatabase.primarySourceInstitutionId(source: model.source, sourceInstitutionId: model.sourceInstitutionId) ?? model.sourceInstitutionId
        if let headerView = InstitutionHeaders.headerViewForId(sourceInstitutionId: sourceInstitutionId) {
            self.addSubview(headerView)
            self.headerView = headerView
        } else if let headerView = InstitutionHeaders.defaultHeaderView(backgroundColor: model.displayColor, foregroundColor: CurrentTheme.accounts.headerCell.genericInstitutionTextColor, font: CurrentTheme.accounts.headerCell.genericInstitutionFont, name: model.name) {
            self.addSubview(headerView)
            self.headerView = headerView
        }
        
        self.alphaValue = (debugging.showAllInstitutionsAsIncorrectPassword || model.passwordInvalid) ? CurrentTheme.accounts.cell.passwordInvalidDimmedAlpha : 1.0
        
        self.setAccessibilityLabel("Section: " + model.name)
    }
}

typealias RowBackgroundColor = (_ index: TableIndex) -> NSColor?
class AccountsTabAccountCell: View {
    var model: Account?
    var index = TableIndex.none
    var rowBackgroundColor: RowBackgroundColor?
    
    let topContainer = View()
    let nameField = LabelField()
    let inclusionIndicator = ImageView()
    let amountField = LabelField()
    let altAmountField = LabelField()
    
    var bottomContainer: View!
    var transactionDetailsField: LabelField!
    var includeInTotalButton: Button!
    var searchTransactionsButton: Button!
    
    static var dateFormatter = DateFormatter()
    
    init() {
        super.init(frame: NSZeroRect)
        self.layerBackgroundColor = CurrentTheme.defaults.cell.backgroundColor
        
        self.addSubview(topContainer)
        topContainer.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(CurrentTheme.accounts.cell.height)
        }
        
        amountField.setAccessibilityLabel("Account Total")
        amountField.backgroundColor = CurrentTheme.defaults.cell.backgroundColor
        amountField.font = CurrentTheme.accounts.cell.amountFont
        amountField.usesSingleLineMode = true
        topContainer.addSubview(amountField)
        amountField.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.trailing.equalToSuperview().inset(12)
            make.top.equalToSuperview().offset(8)
        }
        
        amountField.setAccessibilityLabel("Alternate Currency Amount Total")
        altAmountField.backgroundColor = CurrentTheme.defaults.cell.backgroundColor
        altAmountField.font = CurrentTheme.accounts.cell.altAmountFont
        altAmountField.textColor = CurrentTheme.accounts.cell.altAmountColor
        altAmountField.usesSingleLineMode = true
        self.addSubview(altAmountField)
        altAmountField.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        topContainer.addSubview(inclusionIndicator)
        
        inclusionIndicator.snp.makeConstraints { make in
            make.width.equalTo(15)
            make.height.equalTo(15)
            make.trailing.equalTo(amountField.snp.leading).offset(-5)
            make.centerY.equalTo(amountField)
        }
        
        nameField.setAccessibilityLabel("Account Name")
        nameField.backgroundColor = CurrentTheme.defaults.cell.backgroundColor
        nameField.alignment = .left
        nameField.font = CurrentTheme.accounts.cell.nameFont
        nameField.textColor = CurrentTheme.defaults.foregroundColor
        nameField.usesSingleLineMode = true
        nameField.cell?.lineBreakMode = .byTruncatingTail
        topContainer.addSubview(nameField)
        nameField.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.trailing.equalTo(inclusionIndicator.snp.leading).inset(-5)
            make.centerY.equalToSuperview()
        }
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(cellOpened(_:)), name: AccountsTabViewController.InternalNotifications.CellOpened)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(cellClosed(_:)), name: AccountsTabViewController.InternalNotifications.CellClosed)
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    deinit {
        NotificationCenter.removeObserverOnMainThread(self, name: AccountsTabViewController.InternalNotifications.CellOpened)
        NotificationCenter.removeObserverOnMainThread(self, name: AccountsTabViewController.InternalNotifications.CellClosed)
    }
    
    func updateModel(_ updatedModel: Account) {
        model = updatedModel
        
        let currency = Currency.rawValue(shortName: updatedModel.currency)
        amountField.attributedStringValue = amountToStringFormatted(amount: updatedModel.displayBalance, currency: currency, showNegative: true)
        amountField.setAccessibilityLabel("Account Total")
        amountField.snp.updateConstraints { make in
            let width = amountField.stringValue.size(font: CurrentTheme.accounts.cell.amountFont)
            make.width.equalTo(width)
        }
        
        if updatedModel.altCurrency != nil && updatedModel.currency != updatedModel.altCurrency {
            if let altCurrentBalance = updatedModel.altCurrentBalance {
                let altCurrency = Currency.rawValue(shortName: updatedModel.altCurrency!)
                altAmountField.stringValue = amountToString(amount: altCurrentBalance, currency: altCurrency, showNegative: true)
                altAmountField.setAccessibilityLabel("Account Total")
                altAmountField.snp.updateConstraints { make in
                    let width = altAmountField.stringValue.size(font: CurrentTheme.accounts.cell.amountFont)
                    make.width.equalTo(width)
                }
            }
            
            altAmountField.isHidden = false
            amountField.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(8)
            }
        } else {
            altAmountField.isHidden = true
            amountField.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(20)
            }
        }
        
        nameField.stringValue = updatedModel.displayName
        
        self.setAccessibilityLabel(updatedModel.displayName)
        
        if model?.accountType == .credit, let number = model?.number {
            nameField.stringValue = "\(nameField.stringValue) (\(number))"
        }
        
        self.alphaValue = (debugging.showAllInstitutionsAsIncorrectPassword || updatedModel.passwordInvalid)  ? CurrentTheme.accounts.cell.passwordInvalidDimmedAlpha : 1.0
        
        updateTopContainerOffset()
        updateInclusionIndicator()
    }
    
    func updateTopContainerOffset() {
        topContainer.snp.updateConstraints { make in
            make.top.equalTo(self).offset(index.row == 0 ? -4 : 0)
        }
    }
    
    func updateInclusionIndicator() {
        let isItIncludedBool = defaults.accountIdsExcludedFromTotal.contains(model!.accountId)
        if isItIncludedBool {
            inclusionIndicator.setAccessibilityLabel("Account included in total?")
            inclusionIndicator.image = tintImageWithColor(NSImage(named: NSImage.Name(rawValue: "CircleRemove"))!, color: CurrentTheme.defaults.foregroundColor)
        } else {
            inclusionIndicator.image = nil
        }
    }
    
    func showBottomContainer() {
        guard bottomContainer == nil, let model = model else {
            return
        }
        
        // Analytics
        Answers.logContentView(withName: "Accounts tab cell expanded", contentType: nil, contentId: nil, customAttributes: nil)
        
        let userInfo = [AccountsTabViewController.InternalNotifications.Keys.Cell: self]
        NotificationCenter.postOnMainThread(name: AccountsTabViewController.InternalNotifications.CellOpened, object: nil, userInfo: userInfo)
        
        bottomContainer = View()
        self.addSubview(bottomContainer)
        bottomContainer.snp.makeConstraints { make in
            make.top.equalTo(topContainer.snp.bottom)
            make.leading.equalTo(nameField)
            make.trailing.equalTo(amountField)
            make.height.equalTo(50)
        }
        
        searchTransactionsButton = Button()
        searchTransactionsButton.bezelStyle = .rounded
        let searchIcon = NSImage(named: NSImage.Name(rawValue: "search"))
        searchIcon!.size = NSSize(width: 18, height: 18)
        searchTransactionsButton.image = tintImageWithColor(searchIcon!, color: CurrentTheme.defaults.foregroundColor)
        searchTransactionsButton.imagePosition = .imageLeft
        searchTransactionsButton.title = "Search transactions"
        searchTransactionsButton.toolTip = "Search transactions"
        searchTransactionsButton.setAccessibilityLabel(searchTransactionsButton.title)
        searchTransactionsButton.font = CurrentTheme.accounts.cellExpansion.font
        searchTransactionsButton.target = self
        searchTransactionsButton.action = #selector(searchTransactionsAction(_:))
        bottomContainer.addSubview(searchTransactionsButton)
        searchTransactionsButton.snp.makeConstraints { make in
            make.height.equalTo(25)
            make.leading.equalTo(bottomContainer)
            make.top.equalTo(bottomContainer.snp.top)
            
        }
        
        includeInTotalButton = Button()
        includeInTotalButton.bezelStyle = .rounded
        includeInTotalButton.state = defaults.accountIdsExcludedFromTotal.contains(model.accountId) ? NSControl.StateValue.offState : NSControl.StateValue.onState
        includeInTotalButton.font = CurrentTheme.accounts.cellExpansion.font
        if includeInTotalButton.state == NSControl.StateValue.onState {
            let circleRemoveImage = NSImage(named: NSImage.Name(rawValue: "CircleRemove"))
            circleRemoveImage?.size = NSSize(width: 18, height: 18)
            includeInTotalButton.image = tintImageWithColor(circleRemoveImage!, color: CurrentTheme.defaults.foregroundColor)
            includeInTotalButton.title = "Exclude balance"
        } else {
            
            let circleAddImage = NSImage(named: NSImage.Name(rawValue: "CircleAdd"))
            circleAddImage?.size = NSSize(width: 18, height: 18)
            includeInTotalButton.image = tintImageWithColor(circleAddImage!, color: CurrentTheme.defaults.foregroundColor)
            includeInTotalButton.title = "Include balance"
        }
        
        includeInTotalButton.setAccessibilityLabel(includeInTotalButton.title)
        includeInTotalButton.imagePosition = .imageLeft
        includeInTotalButton.target = self
        includeInTotalButton.action = #selector(includeInTotalAction(_:))
        bottomContainer.addSubview(includeInTotalButton)
        includeInTotalButton.snp.makeConstraints { make in
            make.height.equalTo(25)
            make.leading.equalTo(searchTransactionsButton.snp.trailing).offset(10)
            make.top.equalTo(bottomContainer.snp.top)
        }
        
        transactionDetailsField = LabelField()
        transactionDetailsField.alignment = .left
        transactionDetailsField.font = CurrentTheme.accounts.cellExpansion.font
        transactionDetailsField.backgroundColor = rowBackgroundColor?(index)
        transactionDetailsField.textColor = CurrentTheme.defaults.foregroundColor
        transactionDetailsField.usesSingleLineMode = true
        transactionDetailsField.setAccessibilityLabel("Transaction details")
        transactionDetailsField.cell?.lineBreakMode = .byTruncatingTail
        bottomContainer.addSubview(transactionDetailsField)
        transactionDetailsField.snp.makeConstraints { make in
            make.leading.equalTo(bottomContainer).inset(2)
            make.trailing.equalTo(bottomContainer)
            make.height.equalTo(15)
            make.top.equalTo(includeInTotalButton.snp.bottom).inset(-5)
        }
        
        AccountsTabAccountCell.dateFormatter.dateFormat = "M/d/y"
        let count = model.numberOfTransactions
        let countString = count == 1 ? "\(count) transaction" : "\(count) transactions"
        if let date = model.oldestTransactionDate {
            let dateString = AccountsTabAccountCell.dateFormatter.string(from: date as Date)
            transactionDetailsField.stringValue = "\(countString) since \(dateString)"
        } else {
            transactionDetailsField.stringValue = "\(countString)"
        }
        
        includeInTotalButton.state = defaults.accountIdsExcludedFromTotal.contains(model.accountId) ? NSControl.StateValue.offState : NSControl.StateValue.onState
    }
    
    func hideBottomContainer(notify: Bool = true) {
        if bottomContainer != nil {
            if notify {
                NotificationCenter.postOnMainThread(name: AccountsTabViewController.InternalNotifications.CellClosed)
            }
            
            bottomContainer.removeFromSuperview()
            self.bottomContainer = nil
            transactionDetailsField = nil
            searchTransactionsButton = nil
        }
    }
    
    @objc fileprivate func includeInTotalAction(_ sender: NSButton) {
        if let model = model {
            if sender.state == NSControl.StateValue.onState {
                defaults.includeAccountIdInTotal(model.accountId)
                //TODO - is there a cleaner way to do this? I’m copying and pasting which feels wrong
                let circleRemoveImage = NSImage(named: NSImage.Name(rawValue: "CircleRemove"))!
                circleRemoveImage.size = NSSize(width: 18, height: 18)
                includeInTotalButton.image = tintImageWithColor(circleRemoveImage, color: CurrentTheme.defaults.foregroundColor)
                includeInTotalButton.title = "Exclude balance"
            } else {
                // Analytics
                Answers.logContentView(withName: "Accounts tab cell excluded from balance", contentType: nil, contentId: nil, customAttributes: nil)
                
                defaults.excludeAccountIdFromTotal(model.accountId)
                let circleAddImage = NSImage(named: NSImage.Name(rawValue: "CircleAdd"))!
                circleAddImage.size = NSSize(width: 18, height: 18)
                includeInTotalButton.image = tintImageWithColor(circleAddImage, color: CurrentTheme.defaults.foregroundColor)
                includeInTotalButton.title = "Include balance"
            }
            
            updateInclusionIndicator()
        }
    }
    
    @objc fileprivate func searchTransactionsAction(_ sender: NSButton) {
        if let model = model {
            Search.searchTransactions(accountOrInstitutionName: model.name)
            
            // Analytics
            Answers.logContentView(withName: "Accounts tab cell transactions searched", contentType: nil, contentId: nil, customAttributes: nil)
        }
    }
    
    @objc fileprivate func cellOpened(_ notification: Notification) {
        if let cell = notification.userInfo?[AccountsTabViewController.InternalNotifications.Keys.Cell] as? AccountsTabAccountCell {
            var alpha: CGFloat = 1.0
            if let model = model, (debugging.showAllInstitutionsAsIncorrectPassword || model.passwordInvalid)  {
                alpha = CurrentTheme.accounts.cell.passwordInvalidDimmedAlpha
            } else if cell != self {
                alpha = CurrentTheme.accounts.cell.dimmedAlpha
            }
            
            self.animator().alphaValue = alpha
        }
    }
    
    @objc fileprivate func cellClosed(_ notification: Notification) {
        var alpha: CGFloat = 1.0
        if let model = model, (debugging.showAllInstitutionsAsIncorrectPassword || model.passwordInvalid)  {
            alpha = CurrentTheme.accounts.cell.passwordInvalidDimmedAlpha
        }
        self.animator().alphaValue = alpha
    }
}
