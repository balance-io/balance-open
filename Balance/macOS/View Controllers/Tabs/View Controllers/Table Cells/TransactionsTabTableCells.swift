//
//  TransactionsTabTableCells.swift
//  Bal
//
//  Created by Benjamin Baron on 5/22/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation
import MapKit

class TransactionsTabGroupCell: View {
    var section = -1
    
    let dateField = LabelField()
    
    init() {
        super.init(frame: NSZeroRect)
        
        self.layerBackgroundColor = CurrentTheme.defaults.backgroundColor
        
        dateField.textColor = CurrentTheme.transactions.headerCell.dateColor
        dateField.font = CurrentTheme.transactions.headerCell.dateFont
        dateField.alphaValue = CurrentTheme.transactions.headerCell.dateAlpha
        dateField.backgroundColor = CurrentTheme.defaults.backgroundColor
        dateField.layerBackgroundColor = CurrentTheme.defaults.backgroundColor
        self.addSubview(dateField)
        dateField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalTo(self)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    fileprivate let dateFormatter = DateFormatter()
    func updateModel(_ model: Date) {
        var dateString = ""
        
        let calendar = Calendar.current
        let currentYear = (calendar as NSCalendar).component(.year, from: Date())
        
        if calendar.isDateInToday(model) {
            dateString = "Today"
        } else if calendar.isDateInYesterday(model) {
            dateString = "Yesterday"
        } else {
            let year = (Calendar.current as NSCalendar).component(.year, from: model)
            if year < currentYear {
                dateFormatter.dateFormat = "EEEE MMM d y"
            } else {
                dateFormatter.dateFormat = "EEEE MMM d"
            }
            
            dateString = dateFormatter.string(from: model)
        }
        
        dateField.stringValue = dateString.uppercased()
    }
}

// Don't respond to gestures or clicks
fileprivate class NoHitMapView: MKMapView {
    override func hitTest(_ aPoint: NSPoint) -> NSView? {
        return nil
    }
}

class TransactionsTabTransactionCell: View {
    var model: Transaction?
    var index = TableIndex.none
    
    let topContainer = View()
    let topBackgroundView = View()
    let typeField = LabelField()
    let amountField = LabelField()
    let institutionLogo = PaintCodeView()
    let institutionNameField = LabelField()
    let altAmountField = LabelField()
    
    var bottomContainerOpened = false
    var bottomContainer: View!
    var categoryView: CategoryView!
    var infoContainer: View!
    var accountContainer: View!
    var institutionField: LabelField!
    var accountField: LabelField!
    var mapView: MKMapView!

    init() {
        super.init(frame: NSZeroRect)
        
        self.addSubview(topContainer)
        topContainer.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(CurrentTheme.transactions.cell.height)
        }
        
        let topBackgroundViewFirstShadowView = View()
        topBackgroundViewFirstShadowView.layerBackgroundColor = CurrentTheme.transactions.cell.backgroundViewColor
        let firstDropShadow = NSShadow()
        firstDropShadow.shadowColor = NSColor(deviceWhiteInt: 0, alpha: 0.2)
        firstDropShadow.shadowOffset = NSSize(width: 0, height: 0)
        firstDropShadow.shadowBlurRadius = 0.5
        topBackgroundViewFirstShadowView.shadow = firstDropShadow
        topContainer.addSubview(topBackgroundViewFirstShadowView)
        topBackgroundViewFirstShadowView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalToSuperview().offset(-10)
        }
        
        topBackgroundView.layerBackgroundColor = CurrentTheme.transactions.cell.backgroundViewColor
        let secondDropShadow = NSShadow()
        secondDropShadow.shadowColor = NSColor(deviceWhiteInt: 0, alpha: 0.2)
        secondDropShadow.shadowOffset = NSSize(width: 0, height: -2)
        secondDropShadow.shadowBlurRadius = 4
        topBackgroundView.shadow = secondDropShadow
        topContainer.addSubview(topBackgroundView)
        topBackgroundView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalToSuperview().offset(-10)
        }
        
        typeField.backgroundColor = CurrentTheme.defaults.cell.backgroundColor
        typeField.font = CurrentTheme.transactions.cell.typeFont
        typeField.usesSingleLineMode = true
        typeField.alignment = .right
        topContainer.addSubview(typeField)
        typeField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(16)
        }
        
        amountField.backgroundColor = CurrentTheme.defaults.cell.backgroundColor
        amountField.font = CurrentTheme.transactions.cell.amountFont
        amountField.textColor = CurrentTheme.transactions.cell.amountColor
        amountField.usesSingleLineMode = true
        amountField.alignment = .right
        topContainer.addSubview(amountField)
        amountField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-17)
        }
        
        institutionNameField.backgroundColor = CurrentTheme.defaults.cell.backgroundColor
        institutionNameField.font = CurrentTheme.transactions.cell.typeFont
        institutionNameField.usesSingleLineMode = true
        institutionNameField.alignment = .right
        topContainer.addSubview(institutionNameField)
        institutionNameField.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(16)
        }

        altAmountField.backgroundColor = CurrentTheme.defaults.cell.backgroundColor
        altAmountField.font = CurrentTheme.transactions.cell.altAmountFont
        altAmountField.textColor = CurrentTheme.transactions.cell.altAmountColor
        altAmountField.usesSingleLineMode = true
        altAmountField.alignment = .right
        topContainer.addSubview(altAmountField)
        altAmountField.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-17)
        }
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(cellOpened(_:)), name: TransactionsTabViewController.InternalNotifications.CellOpened)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(cellClosed(_:)), name: TransactionsTabViewController.InternalNotifications.CellClosed)
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    deinit {
        NotificationCenter.removeObserverOnMainThread(self, name: TransactionsTabViewController.InternalNotifications.CellOpened)
        NotificationCenter.removeObserverOnMainThread(self, name: TransactionsTabViewController.InternalNotifications.CellClosed)
    }
    
    func updateModel(_ updatedModel: Transaction) {
        hideBottomContainer()
        
        model = updatedModel
        
        if updatedModel.amount > 0 {
            typeField.stringValue = "Received"
            typeField.textColor = CurrentTheme.transactions.cell.typeColorReceived
        } else {
            typeField.stringValue = "Sent"
            typeField.textColor = CurrentTheme.transactions.cell.typeColorSent
        }
        
        let currency = Currency.rawValue(updatedModel.currency)
        amountField.stringValue = amountToString(amount: updatedModel.amount, currency: currency, showNegative: false, showCodeAfterValue: true)
        
        institutionNameField.stringValue = updatedModel.institution?.name ?? ""
        
        if let displayAltAmount = updatedModel.displayAltAmount {
            altAmountField.stringValue = amountToString(amount: displayAltAmount, currency: defaults.masterCurrency, showNegative: true, showCodeAfterValue: true)
        } else {
            altAmountField.stringValue = ""
        }
        
        self.toolTip = DateFormatter.localizedString(from: updatedModel.date, dateStyle: .medium, timeStyle: .medium)
    }
    
    
    func loadBottomContainer() {
        guard bottomContainer == nil, let model = model else {
            return
        }
        
        bottomContainer = View()
        self.addSubview(bottomContainer)
        bottomContainer.snp.makeConstraints { make in
            make.top.equalTo(topContainer.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalTo(amountField)
            make.height.equalTo(229)
        }
        
        infoContainer = View()
        bottomContainer.addSubview(infoContainer)
        infoContainer.snp.makeConstraints { make in
            make.leading.equalTo(bottomContainer)
            make.trailing.equalTo(bottomContainer)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalTo(bottomContainer)
        }
        
        let displayColor = model.institution?.displayColor ?? NSColor.gray
        
        accountContainer = View()
        accountContainer.cornerRadius = 7.0
        accountContainer.layerBackgroundColor = displayColor.withAlphaComponent(1)
        infoContainer.addSubview(accountContainer)
        accountContainer.snp.makeConstraints { make in
            make.leading.equalTo(infoContainer)
            make.trailing.equalTo(infoContainer)
            make.top.equalTo(infoContainer)
            make.height.equalTo(50)
        }
        
        institutionField = LabelField()
        institutionField.backgroundColor = CurrentTheme.transactions.cellExpansion.institutionBackground
        institutionField.layerBackgroundColor = CurrentTheme.transactions.cellExpansion.institutionBackground
        institutionField.alignment = .center
        institutionField.verticalAlignment = .center
        institutionField.font = CurrentTheme.transactions.cellExpansion.institutionFont
        institutionField.textColor = CurrentTheme.transactions.cellExpansion.fontColor
        accountContainer.addSubview(institutionField)
        institutionField.snp.makeConstraints { make in
            make.leading.equalTo(accountContainer)
            make.trailing.equalTo(accountContainer)
            make.height.equalTo(27)
            make.top.equalTo(accountContainer).offset(-2)
        }
        
        accountField = LabelField()
        accountField.alignment = .center
        accountField.verticalAlignment = .center
        accountField.font = CurrentTheme.transactions.cellExpansion.accountFont
        accountField.textColor = CurrentTheme.transactions.cellExpansion.fontColor.withAlphaComponent(0.9)
        accountContainer.addSubview(accountField)
        accountField.snp.makeConstraints { make in
            make.leading.equalTo(accountContainer)
            make.trailing.equalTo(accountContainer)
            make.height.equalTo(22)
            make.top.equalTo(institutionField.snp.bottom)
        }
        
        institutionField.stringValue = model.institution!.name
        accountField.stringValue = model.account!.name
    }
    
    func unloadBottomContainer() {
        if bottomContainer != nil {
            bottomContainer?.removeFromSuperview()
            bottomContainer = nil
            categoryView = nil
            infoContainer = nil
            accountContainer = nil
            institutionField = nil
            accountField = nil
            mapView = nil
        }
    }
    
    func showBottomContainer() {
        bottomContainerOpened = true
        
        loadBottomContainer()
        
        // Analytics
        analytics.trackEvent(withName: "Transactions tab cell expanded")
        
        let userInfo = [TransactionsTabViewController.InternalNotifications.Keys.Cell: self]
        NotificationCenter.postOnMainThread(name: TransactionsTabViewController.InternalNotifications.CellOpened, object: nil, userInfo: userInfo)
    }
    
    func hideBottomContainer(notify: Bool = true) {
        if bottomContainer != nil {
            // Only notify if the container was actually opened, not just if we preloaded to prevent accidentally undimming the cells
            if notify && bottomContainerOpened {
                NotificationCenter.postOnMainThread(name: TransactionsTabViewController.InternalNotifications.CellClosed)
            }
            
            unloadBottomContainer()
        }
        
        bottomContainerOpened = false
    }
    
    @objc fileprivate func cellOpened(_ notification: Notification) {
        if let cell = notification.userInfo?[TransactionsTabViewController.InternalNotifications.Keys.Cell] as? TransactionsTabTransactionCell {
            self.animator().alphaValue = cell == self ? 1.0 : CurrentTheme.transactions.cell.dimmedAlpha
        }
    }
    
    //TODO: Ben I think this is the wrong way but wasn’t sure how to do it properly. I moved this function to Utils but it needed to be @objc to work in selector
    @objc fileprivate func webSearchTransactionsAction() {
        var searchString = ""
        searchString = (model?.displayName)!
        var searchEngineURL = ""
        switch (defaults.searchPreference) {
        case SearchPreference.google:
            searchEngineURL = "https://www.google.com/search?q="
        case SearchPreference.duckDuckGo:
            searchEngineURL = "https://duckduckgo.com/?q="
        case SearchPreference.bing:
            searchEngineURL = "https://www.bing.com/search?q="
        }
        let urlString = "\(searchEngineURL)\(searchString.capitalizedStringIfAllCaps.URLQueryStringEncodedValue)"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }
    
    let gmailSearchDateFormatter: DateFormatter = {
        let gmailSearchDateFormatter = DateFormatter()
        gmailSearchDateFormatter.dateFormat = "YYYY/M/d"
        return gmailSearchDateFormatter
    }()
    
    @objc fileprivate func receiptSearchTransactionsAction() {
        func performSearch() {
            guard let model = model else {
                return
            }
            
            var name = model.displayName.components(separatedBy: " ").first ?? model.displayName
            name = name.capitalizedStringIfAllCaps.URLQueryParameterEncodedValue
            
            let amount = String(format: "%.2f", Double(abs(model.amount)) / 100.0).URLQueryParameterEncodedValue
            let dateAfter = gmailSearchDateFormatter.string(from: model.date.addingTimeInterval(-3600.0 * 24 * 2) as Date).URLQueryParameterEncodedValue
            let dateBefore = gmailSearchDateFormatter.string(from: model.date.addingTimeInterval(3600.0 * 24 * 2) as Date).URLQueryParameterEncodedValue
            let urlBase: String
            let query = "\(name)%20\(amount)%20after:\(dateAfter)%20before:\(dateBefore)"
            switch defaults.emailPreference {
            case .gmail:
                urlBase = "https://mail.google.com/mail/u/0/#search"
            case .googleInbox:
                urlBase = "https://inbox.google.com/u/0/search"
            }
            
            if let url = URL(string: urlBase + "/" + query) {
                NSWorkspace.shared.open(url)
            }
        }
        
        if defaults.emailPreferenceModified {
            performSearch()
        } else {
            AppDelegate.sharedInstance.pinned = true
            let alert = NSAlert()
            alert.alertStyle = .informational
            alert.messageText = "Do you use another email provider?"
            alert.informativeText = "You can change this setting in Preferences."
            alert.addButton(withTitle: "No, I use Gmail")
            alert.addButton(withTitle: "Yes")
            if alert.runModal() == NSApplication.ModalResponse.alertSecondButtonReturn {
                AppDelegate.sharedInstance.showPreferences()
            } else {
                AppDelegate.sharedInstance.pinned = false
                performSearch()
            }
            defaults.emailPreference = .gmail
        }
    }
    
    @objc fileprivate func cellClosed(_ notification: Notification) {
        self.animator().alphaValue = 1.0
    }
    
    override func rightMouseDown(with theEvent: NSEvent) {
        if let model = model {
            TransactionContextMenu.showMenu(transaction: model, view: self)
        }
    }
}

fileprivate class Annotation: NSObject, MKAnnotation {
    @objc var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
