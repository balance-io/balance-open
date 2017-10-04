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

class AccountsTabGroupCell: View {
    var model: Institution?
    var topColor = NSColor.clear
    
    let cardView = PaintCodeView()
    let logoView = PaintCodeView()
    let nameField = LabelField()
    let amountField = LabelField()

    init() {
        super.init(frame: NSZeroRect)
        
        cardView.drawingBlock = drawCardBorder
        self.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(-28)
            make.height.equalTo(44)
        }
        
        let cardBorderOffset = 15.0
        
        self.addSubview(amountField)
        amountField.font = CurrentTheme.accounts.headerCell.amountFont
        amountField.textColor = CurrentTheme.accounts.headerCell.amountColor
        amountField.verticalAlignment = .center
        amountField.alignment = .right
        amountField.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(cardBorderOffset)
            make.height.equalToSuperview().offset(-cardBorderOffset)
            make.width.equalTo(150)
        }
        
        self.addSubview(nameField)
        nameField.font = CurrentTheme.accounts.headerCell.nameFont
        nameField.textColor = CurrentTheme.accounts.headerCell.nameColor
        nameField.verticalAlignment = .center
        nameField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(cardBorderOffset)
            make.height.equalToSuperview().offset(-cardBorderOffset)
            make.right.equalTo(amountField.snp.left).offset(5)
        }
        
        self.addSubview(logoView)
        logoView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(cardBorderOffset)
            make.height.equalToSuperview().offset(-cardBorderOffset)
            make.right.equalTo(amountField.snp.left).offset(-10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    func updateModel(_ updatedModel: Institution, previousSectionColor: NSColor) {
        model = updatedModel
        topColor = previousSectionColor
        
        if false { // If let header view
            // Waiting for graphics
            logoView.isHidden = false
            nameField.isHidden = true
        } else {
            logoView.isHidden = true
            nameField.isHidden = false
            nameField.stringValue = updatedModel.name
        }
        
        amountField.stringValue = "10,000 USD"
        
        self.alphaValue = (debugging.showAllInstitutionsAsIncorrectPassword || updatedModel.passwordInvalid) ? CurrentTheme.accounts.cell.passwordInvalidDimmedAlpha : 1.0
        
        self.setAccessibilityLabel("Section: " + updatedModel.name)
        self.needsDisplay = true
    }
    
    fileprivate func drawCardBorder(frame targetFrame: NSRect = NSRect(x: 0, y: 0, width: 400, height: 44)) {
        //// General Declarations
        let context = NSGraphicsContext.current!.cgContext
        
        //// Resize to Target Frame
        NSGraphicsContext.saveGraphicsState()
        let resizing = ResizingBehavior.aspectFit
        let resizedFrame: NSRect = resizing.apply(rect: NSRect(x: 0, y: 0, width: 400, height: 44), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 400, y: resizedFrame.height / 44)
        let resizedShadowScale: CGFloat = min(resizedFrame.width / 400, resizedFrame.height / 44)
        
        
        //// Color Declarations
        let upperCardBackground = topColor
        let lowerCardBackground = model?.source.color ?? .clear
        
        //// Shadow Declarations
        let smallCardShadow = NSShadow()
        smallCardShadow.shadowColor = NSColor.black.withAlphaComponent(0.06)
        smallCardShadow.shadowOffset = NSSize(width: 0, height: 4)
        smallCardShadow.shadowBlurRadius = 12
        let largeCardShadow = NSShadow()
        largeCardShadow.shadowColor = NSColor.black.withAlphaComponent(0.05)
        largeCardShadow.shadowOffset = NSSize(width: 0, height: 7)
        largeCardShadow.shadowBlurRadius = 21
        
        //// upperCard Drawing
        let upperCardPath = NSBezierPath(rect: NSRect(x: 0, y: 0, width: 400, height: 44))
        upperCardBackground.setFill()
        upperCardPath.fill()
        
        
        //// lowerCardContainer
        NSGraphicsContext.saveGraphicsState()
        context.setShadow(offset: NSSize(width: largeCardShadow.shadowOffset.width * resizedShadowScale, height: largeCardShadow.shadowOffset.height * resizedShadowScale), blur: largeCardShadow.shadowBlurRadius * resizedShadowScale, color: largeCardShadow.shadowColor!.cgColor)
        context.beginTransparencyLayer(auxiliaryInfo: nil)
        
        
        //// lowerCard Drawing
        let lowerCardPath = NSBezierPath()
        lowerCardPath.move(to: NSPoint(x: 400, y: -100))
        lowerCardPath.line(to: NSPoint(x: 400, y: 0.62))
        lowerCardPath.curve(to: NSPoint(x: 398.4, y: 9.86), controlPoint1: NSPoint(x: 400, y: 5.97), controlPoint2: NSPoint(x: 399.44, y: 7.91))
        lowerCardPath.curve(to: NSPoint(x: 393.86, y: 14.4), controlPoint1: NSPoint(x: 397.35, y: 11.82), controlPoint2: NSPoint(x: 395.82, y: 13.35))
        lowerCardPath.curve(to: NSPoint(x: 384.62, y: 16), controlPoint1: NSPoint(x: 391.91, y: 15.44), controlPoint2: NSPoint(x: 389.97, y: 16))
        lowerCardPath.line(to: NSPoint(x: 15.38, y: 16))
        lowerCardPath.curve(to: NSPoint(x: 6.14, y: 14.4), controlPoint1: NSPoint(x: 10.03, y: 16), controlPoint2: NSPoint(x: 8.09, y: 15.44))
        lowerCardPath.curve(to: NSPoint(x: 1.6, y: 9.86), controlPoint1: NSPoint(x: 4.18, y: 13.35), controlPoint2: NSPoint(x: 2.65, y: 11.82))
        lowerCardPath.curve(to: NSPoint(x: 0, y: 0.62), controlPoint1: NSPoint(x: 0.56, y: 7.91), controlPoint2: NSPoint(x: 0, y: 5.97))
        lowerCardPath.line(to: NSPoint(x: 0, y: -100))
        lowerCardPath.line(to: NSPoint(x: 400, y: -100))
        lowerCardPath.close()
        NSGraphicsContext.saveGraphicsState()
        context.setShadow(offset: NSSize(width: smallCardShadow.shadowOffset.width * resizedShadowScale, height: smallCardShadow.shadowOffset.height * resizedShadowScale), blur: smallCardShadow.shadowBlurRadius * resizedShadowScale, color: smallCardShadow.shadowColor!.cgColor)
        lowerCardPath.windingRule = .evenOddWindingRule
        lowerCardBackground.setFill()
        lowerCardPath.fill()
        NSGraphicsContext.restoreGraphicsState()
        
        context.endTransparencyLayer()
        NSGraphicsContext.restoreGraphicsState()
        
        NSGraphicsContext.restoreGraphicsState()
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
        
        altAmountField.setAccessibilityLabel("Alternate Currency Amount Total")
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
        
        updateBackgroundColors()
        updateTopContainerOffset()
        updateInclusionIndicator()
    }
    
    func updateBackgroundColors() {
        if let color = model?.source.color {
            self.layerBackgroundColor = color
            amountField.backgroundColor = color
            altAmountField.backgroundColor = color
            nameField.backgroundColor = color
        }
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
        BITHockeyManager.shared()?.metricsManager?.trackEvent(withName: "Accounts tab cell expanded")
        
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
                BITHockeyManager.shared()?.metricsManager?.trackEvent(withName: "Accounts tab cell excluded from balance")
                
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
            BITHockeyManager.shared()?.metricsManager?.trackEvent(withName: "Accounts tab cell transactions searched")
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
