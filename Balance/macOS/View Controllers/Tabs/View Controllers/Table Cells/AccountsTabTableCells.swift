//
//  AccountsTabTableCells.swift
//  Bal
//
//  Created by Benjamin Baron on 5/22/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation
import BalanceVectorGraphics
import SnapKit

fileprivate let padding = 18
fileprivate let linePadding = padding - 2

class AccountsTabGroupCell: View {
    var model: Institution?
    var topColor = NSColor.clear
    
    let logoView = PaintCodeView()
    let nameField = LabelField()
    let amountField = LabelField()
    let lineView = View()

    init() {
        super.init(frame: NSZeroRect)
        
        lineView.layerBackgroundColor = .white
        lineView.alphaValue = 0.06
        self.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(linePadding)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.right.equalToSuperview()
        }
        
        self.addSubview(amountField)
        amountField.font = CurrentTheme.accounts.headerCell.amountFont
        amountField.textColor = CurrentTheme.accounts.headerCell.amountColor
        amountField.verticalAlignment = .center
        amountField.alignment = .right
        amountField.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-linePadding)
            make.top.equalToSuperview().offset(-2)
            make.bottom.equalTo(lineView.snp.top).offset(-2)
        }
        
        self.addSubview(nameField)
        nameField.font = CurrentTheme.accounts.headerCell.nameFont
        nameField.textColor = CurrentTheme.accounts.headerCell.nameColor
        nameField.verticalAlignment = .center
        nameField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(padding)
            make.top.equalToSuperview()
            make.bottom.equalTo(lineView.snp.top)
            make.right.equalTo(amountField.snp.left).offset(5)
        }
        
        self.addSubview(logoView)
        logoView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(61)
            make.centerY.equalToSuperview().offset(-1)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    func updateModel(_ updatedModel: Institution, previousSectionColor: NSColor) {
        model = updatedModel
        topColor = previousSectionColor
        
        let sourceInstitutionId = updatedModel.source.description
        if let logoDrawFunction = InstitutionLogos.drawingFunctionForId(sourceInstitutionId: sourceInstitutionId) {
            logoView.isHidden = false
            nameField.isHidden = true
            logoView.drawingBlock = logoDrawFunction
        } else {
            logoView.isHidden = true
            nameField.isHidden = false
            nameField.stringValue = updatedModel.name
        }
        
        let accounts = AccountRepository.si.accounts(institutionId: updatedModel.institutionId, includeHidden: false)
        var totalAmount = 0
        for account in accounts {
            totalAmount += (account.displayAltBalance ?? 0)
        }
        amountField.stringValue = amountToString(amount: totalAmount, currency: defaults.masterCurrency, showNegative: true, showCodeAfterValue: true)
        
        self.alphaValue = (debugging.showAllInstitutionsAsIncorrectPassword || updatedModel.passwordInvalid) ? CurrentTheme.accounts.cell.passwordInvalidDimmedAlpha : 1.0
        
        self.setAccessibilityLabel("Section: " + updatedModel.name)
        self.needsDisplay = true
    }
}

typealias RowBackgroundColor = (_ index: TableIndex) -> NSColor?
class AccountsTabAccountCell: View {
    var model: Account?
    var index = TableIndex.none
    var rowBackgroundColor: RowBackgroundColor?
    
    let topContainer = View()
    let nameField = LabelField()
    let amountField = LabelField()
    let altAmountField = LabelField()
    let lineView = View()
    
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
        
        nameField.setAccessibilityLabel("Account Name")
        nameField.alphaValue = 0.80
        nameField.backgroundColor = CurrentTheme.defaults.cell.backgroundColor
        nameField.alignment = .left
        nameField.font = CurrentTheme.accounts.cell.nameFont
        nameField.textColor = CurrentTheme.accounts.cell.nameColor
        nameField.usesSingleLineMode = true
        nameField.cell?.lineBreakMode = .byTruncatingTail
        topContainer.addSubview(nameField)
        nameField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(padding)
            make.trailing.equalToSuperview().offset(-padding)
            make.top.equalToSuperview().offset(11)
        }
        
        amountField.setAccessibilityLabel("Account Total")
        amountField.alphaValue = 0.95
        amountField.backgroundColor = CurrentTheme.defaults.cell.backgroundColor
        amountField.font = CurrentTheme.accounts.cell.amountFont
        amountField.textColor = CurrentTheme.accounts.cell.amountColor
        amountField.usesSingleLineMode = true
        amountField.alignment = .left
        topContainer.addSubview(amountField)
        amountField.snp.makeConstraints { make in
            make.leading.equalTo(nameField)
            make.top.equalToSuperview().offset(31)
        }
        
        altAmountField.setAccessibilityLabel("Alternate Currency Amount Total")
        altAmountField.backgroundColor = CurrentTheme.defaults.cell.backgroundColor
        altAmountField.font = CurrentTheme.accounts.cell.altAmountFont
        altAmountField.textColor = CurrentTheme.accounts.cell.altAmountColor
        altAmountField.usesSingleLineMode = true
        topContainer.addSubview(altAmountField)
        altAmountField.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-padding)
            make.top.equalToSuperview().offset(31)
        }
        
        lineView.layerBackgroundColor = .white
        lineView.alphaValue = 0.06
        topContainer.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(linePadding)
            make.bottom.equalToSuperview().offset(-1)
            make.height.equalTo(1)
            make.right.equalToSuperview()
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
    
    func updateModel(_ updatedModel: Account, isLastRowInSection: Bool) {
        model = updatedModel
        
        let currency = Currency.rawValue(updatedModel.currency)
        amountField.stringValue = amountToString(amount: updatedModel.displayBalance, currency: currency, showNegative: true, showCodeAfterValue: true)
        
        if let displayAltBalance = updatedModel.displayAltBalance {
            altAmountField.stringValue = amountToString(amount: displayAltBalance, currency: defaults.masterCurrency, showNegative: true, showCodeAfterValue: defaults.masterCurrency.isCrypto)
            altAmountField.isHidden = false
        } else {
            altAmountField.isHidden = true
        }
        
        nameField.stringValue = updatedModel.displayName
        
        self.setAccessibilityLabel(updatedModel.displayName)
        
        if model?.accountType == .credit, let number = model?.number {
            nameField.stringValue = "\(nameField.stringValue) (\(number))"
        }
        
        self.alphaValue = (debugging.showAllInstitutionsAsIncorrectPassword || updatedModel.passwordInvalid)  ? CurrentTheme.accounts.cell.passwordInvalidDimmedAlpha : 1.0
        
        lineView.isHidden = isLastRowInSection
        
        updateBackgroundColors()
    }
    
    func updateBackgroundColors() {
        if let color = model?.source.color {
            self.layerBackgroundColor = color
            amountField.backgroundColor = color
            altAmountField.backgroundColor = color
            nameField.backgroundColor = color
        }
    }
    
    func showBottomContainer() {
        guard bottomContainer == nil, let model = model else {
            return
        }
        
        // Analytics
        analytics.trackEvent(withName: "Accounts tab cell expanded")
        
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
        includeInTotalButton.state = defaults.accountIdsExcludedFromTotal.contains(model.accountId) ? .off : .on
        includeInTotalButton.font = CurrentTheme.accounts.cellExpansion.font
        if includeInTotalButton.state == .on {
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
            make.leading.equalTo(bottomContainer).offset(2)
            make.trailing.equalTo(bottomContainer)
            make.height.equalTo(15)
            make.top.equalTo(includeInTotalButton.snp.bottom).offset(-5)
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
        
        includeInTotalButton.state = defaults.accountIdsExcludedFromTotal.contains(model.accountId) ? .off : .on
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
            if sender.state == .on {
                defaults.includeAccountIdInTotal(model.accountId)
                //TODO - is there a cleaner way to do this? I’m copying and pasting which feels wrong
                let circleRemoveImage = NSImage(named: NSImage.Name(rawValue: "CircleRemove"))!
                circleRemoveImage.size = NSSize(width: 18, height: 18)
                includeInTotalButton.image = tintImageWithColor(circleRemoveImage, color: CurrentTheme.defaults.foregroundColor)
                includeInTotalButton.title = "Exclude balance"
            } else {
                // Analytics
                analytics.trackEvent(withName: "Accounts tab cell excluded from balance")
                
                defaults.excludeAccountIdFromTotal(model.accountId)
                let circleAddImage = NSImage(named: NSImage.Name(rawValue: "CircleAdd"))!
                circleAddImage.size = NSSize(width: 18, height: 18)
                includeInTotalButton.image = tintImageWithColor(circleAddImage, color: CurrentTheme.defaults.foregroundColor)
                includeInTotalButton.title = "Include balance"
            }
        }
    }
    
    @objc fileprivate func searchTransactionsAction(_ sender: NSButton) {
        if let model = model {
            Search.searchTransactions(accountOrInstitutionName: model.name)
            
            // Analytics
            analytics.trackEvent(withName: "Accounts tab cell transactions searched")
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
