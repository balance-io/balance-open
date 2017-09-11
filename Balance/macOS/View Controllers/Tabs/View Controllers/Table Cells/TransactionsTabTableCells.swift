//
//  TransactionsTabTableCells.swift
//  Bal
//
//  Created by Benjamin Baron on 5/22/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation
import MapKit
import Crashlytics

class TransactionsTabGroupCell: View {
    var section = -1
    
    //        let blurryView = VisualEffectView()
    let blurryView = View()
    let dateField = LabelField()
    
    init() {
        super.init(frame: NSZeroRect)
        
        //            blurryView.blendingMode = .withinWindow
        //            blurryView.material = CurrentTheme.defaults.material
        blurryView.wantsLayer = true
        //            blurryView.state = .active
        blurryView.layerBackgroundColor = CurrentTheme.transactions.headerCell.backgroundColor
        self.addSubview(blurryView)
        blurryView.snp.makeConstraints { make in
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
        }
        
        dateField.textColor = CurrentTheme.transactions.headerCell.dateColor
        dateField.font = CurrentTheme.transactions.headerCell.dateFont
        self.addSubview(dateField)
        dateField.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(1)
            make.height.equalTo(14)
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
        
        blurryView.layerBackgroundColor = CurrentTheme.transactions.headerCell.backgroundColor
        dateField.textColor = CurrentTheme.transactions.headerCell.dateColor
        if model == Date.distantFuture {
            blurryView.layerBackgroundColor = CurrentTheme.transactions.headerCell.pendingBackgroundColor
            dateField.textColor = CurrentTheme.transactions.headerCell.pendingDateColor
            dateString = "Pending"
        } else if calendar.isDateInToday(model) {
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
        dateString = dateString.uppercased()
        
        dateField.attributedStringValue = NSAttributedString(string: dateString, attributes: [NSAttributedStringKey.kern: 0.82])
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
    let institutionInitialsCircleView = InstitutionInitialsCircleView()
    let amountField = LabelField()
    let centerNameField = LabelField()
    let nameField = LabelField()
    let addressField = LabelField()
    
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
            make.top.equalTo(self)
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
            make.height.equalTo(CurrentTheme.transactions.cell.height)
        }
        
        topContainer.addSubview(institutionInitialsCircleView)
        institutionInitialsCircleView.snp.makeConstraints { make in
            make.height.equalTo(22)
            make.centerY.equalTo(topContainer)
            make.leading.equalTo(topContainer).inset(10)
            make.width.equalTo(22)
        }
        
        amountField.backgroundColor = CurrentTheme.defaults.cell.backgroundColor
        amountField.font = CurrentTheme.transactions.cell.amountFont
        amountField.usesSingleLineMode = true
        amountField.alignment = .right
        topContainer.addSubview(amountField)
        amountField.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.trailing.equalTo(topContainer).inset(10)
            make.bottom.equalTo(-14)
        }
        
        centerNameField.backgroundColor = CurrentTheme.defaults.cell.backgroundColor
        centerNameField.alignment = .left
        centerNameField.font = CurrentTheme.transactions.cell.nameFont
        centerNameField.textColor = CurrentTheme.defaults.foregroundColor
        centerNameField.usesSingleLineMode = true
        centerNameField.cell?.lineBreakMode = .byTruncatingTail
        topContainer.addSubview(centerNameField)
        centerNameField.snp.makeConstraints { make in
            make.leading.equalTo(institutionInitialsCircleView.snp.trailing).offset(7)
            make.trailing.equalTo(amountField.snp.leading).inset(5)
            make.centerY.equalTo(topContainer).offset(-0.5)
        }
        
        nameField.backgroundColor = CurrentTheme.defaults.cell.backgroundColor
        nameField.alignment = .left
        nameField.font = CurrentTheme.transactions.cell.nameFont
        nameField.textColor = CurrentTheme.defaults.foregroundColor
        nameField.usesSingleLineMode = true
        nameField.cell?.lineBreakMode = .byTruncatingTail
        topContainer.addSubview(nameField)
        nameField.snp.makeConstraints { make in
            make.leading.equalTo(centerNameField)
            make.trailing.equalTo(centerNameField)
            make.top.equalTo(topContainer).offset(5)
        }
        
        addressField.backgroundColor = CurrentTheme.defaults.cell.backgroundColor
        addressField.alignment = .left
        addressField.font = CurrentTheme.transactions.cell.addressFont
        addressField.textColor = CurrentTheme.transactions.cell.addressColor
        addressField.usesSingleLineMode = true
        addressField.cell?.lineBreakMode = .byTruncatingTail
        topContainer.addSubview(addressField)
        addressField.snp.makeConstraints { make in
            make.leading.equalTo(nameField)
            make.trailing.equalTo(nameField)
            make.height.equalTo(14).priority(0.1)
            make.top.equalTo(nameField.snp.bottom).offset(2)
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
        
        institutionInitialsCircleView.circleColor = updatedModel.institution?.displayColor
        institutionInitialsCircleView.stringValue = updatedModel.institution?.initials ?? ""
        
        amountField.attributedStringValue = centsToStringFormatted(-updatedModel.amount)
        if updatedModel.hasLocation, let address = updatedModel.address {
            centerNameField.stringValue = ""
            nameField.stringValue = updatedModel.displayName
            
            if let city = updatedModel.city, let state = updatedModel.state, let zip = updatedModel.zip {
                addressField.stringValue = "\(address.capitalizedStringIfAllCaps) \(city.capitalizedStringIfAllCaps) \(state) \(zip)"
            } else {
                addressField.stringValue = address.capitalizedStringIfAllCaps
            }
            
            centerNameField.isHidden = true
            nameField.isHidden = false
            addressField.isHidden = false
        } else {
            centerNameField.stringValue = updatedModel.displayName
            nameField.stringValue = ""
            addressField.stringValue = ""
            
            centerNameField.isHidden = false
            nameField.isHidden = true
            addressField.isHidden = true
        }
        
        self.toolTip = updatedModel.displayName
    }
    
    
    func loadBottomContainer() {
        guard bottomContainer == nil, let model = model else {
            return
        }
        
        let hasCategory = (model.categoryId != nil)
        
        bottomContainer = View()
        self.addSubview(bottomContainer)
        bottomContainer.snp.makeConstraints { make in
            make.top.equalTo(topContainer.snp.bottom)
            make.leading.equalTo(institutionInitialsCircleView)
            make.trailing.equalTo(amountField)
            make.height.equalTo(229)
        }
        
        var searchPreference = ""
        var searchPreferenceIcon = NSImage()
        switch (defaults.searchPreference) {
        case SearchPreference.google:
            searchPreference = "Google"
            searchPreferenceIcon = NSImage(named: NSImage.Name(rawValue: "google-icon"))!
        case SearchPreference.duckDuckGo:
            searchPreference = "DuckDuckGo"
            searchPreferenceIcon = NSImage(named: NSImage.Name(rawValue: "duck-duck-go-icon"))!
        case SearchPreference.bing:
            searchPreference = "Bing"
            searchPreferenceIcon = NSImage(named: NSImage.Name(rawValue: "bing-icon"))!
        }
        
        let webSearchTransactionsButton = Button()
        webSearchTransactionsButton.bezelStyle = .rounded
        searchPreferenceIcon.size = NSSize(width: 16, height: 16)
        webSearchTransactionsButton.image = searchPreferenceIcon
        webSearchTransactionsButton.imagePosition = .imageLeft
        webSearchTransactionsButton.title = "Search \(searchPreference)"
        webSearchTransactionsButton.toolTip = "Search \(searchPreference)"
        webSearchTransactionsButton.setAccessibilityLabel(webSearchTransactionsButton.title)
        webSearchTransactionsButton.font = CurrentTheme.accounts.cellExpansion.font
        webSearchTransactionsButton.sizeToFit()
        webSearchTransactionsButton.target = self
        webSearchTransactionsButton.action = #selector(webSearchTransactionsAction)
        bottomContainer.addSubview(webSearchTransactionsButton)
        webSearchTransactionsButton.snp.makeConstraints { make in
            make.height.equalTo(25)
            make.leading.equalTo(bottomContainer)
            make.top.equalTo(bottomContainer.snp.top)
        }
        
        var emailPreference = ""
        var emailSearchIcon = NSImage()
        switch (defaults.emailPreference) {
        case EmailPreference.gmail:
            emailPreference = "Gmail"
            emailSearchIcon = NSImage(named: NSImage.Name(rawValue: "gmail-icon"))!
        case EmailPreference.googleInbox:
            emailPreference = "Inbox"
            emailSearchIcon = NSImage(named: NSImage.Name(rawValue: "google-inbox-icon"))!
        }
        
        let emailSearchTransactionsButton = Button()
        emailSearchTransactionsButton.bezelStyle = .rounded
        emailSearchIcon.size = NSSize(width: 16, height: 16)
        emailSearchTransactionsButton.image = emailSearchIcon
        emailSearchTransactionsButton.imagePosition = .imageLeft
        emailSearchTransactionsButton.title = "Search \(emailPreference)"
        emailSearchTransactionsButton.toolTip = "Search \(emailPreference)"
        emailSearchTransactionsButton.setAccessibilityLabel(emailSearchTransactionsButton.title)
        emailSearchTransactionsButton.font = CurrentTheme.accounts.cellExpansion.font
        emailSearchTransactionsButton.target = self
        emailSearchTransactionsButton.action = #selector(receiptSearchTransactionsAction)
        bottomContainer.addSubview(emailSearchTransactionsButton)
        emailSearchTransactionsButton.snp.makeConstraints { make in
            make.height.equalTo(25)
            make.leading.equalTo(webSearchTransactionsButton.snp.trailing).offset(10)
            make.top.equalTo(bottomContainer.snp.top)
        }
        
        infoContainer = View()
        bottomContainer.addSubview(infoContainer)
        infoContainer.snp.makeConstraints { make in
            make.leading.equalTo(bottomContainer)
            make.trailing.equalTo(bottomContainer)
            make.top.equalTo(webSearchTransactionsButton.snp.bottom).offset(8)
            make.bottom.equalTo(bottomContainer)
        }
        
        let displayColor = model.institution?.displayColor ?? NSColor.gray
        
        accountContainer = View()
        accountContainer.cornerRadius = 7.0
        accountContainer.layerBackgroundColor = displayColor.withAlphaComponent(1)
        // TODO: Figure out why this shadow won't draw
        //accountContainer.layer?.shadowOpacity = 0.7
        //accountContainer.layer?.shadowRadius = 15.0
        //accountContainer.layer?.shadowOffset = CGSize(width: 0, height: 2)
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
        //            accountField.backgroundColor = displayColor.lighterColor.withAlphaComponent(1)
        //            accountField.layerBackgroundColor = displayColor.lighterColor.withAlphaComponent(1)
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
        
        if hasCategory {
            categoryView = CategoryView()
            infoContainer.addSubview(categoryView)
            categoryView.buttonHandler = { name in
                let token = SearchToken.category.rawValue
                let searchString = "\(token):(\(name))"
                NotificationCenter.postOnMainThread(name: Notifications.PerformSearch, object: nil, userInfo: [Notifications.Keys.SearchString: searchString])
            }
        }
        
        if model.hasLocation, let latitude = model.latitude, let longitude = model.longitude {
            accountContainer.cornerRadius = 0.0
            infoContainer.cornerRadius = 7.0
            
            mapView = NoHitMapView()
            mapView.wantsLayer = true
            mapView.isZoomEnabled = false
            mapView.isScrollEnabled = false
            mapView.isPitchEnabled = false
            mapView.isRotateEnabled = false
            infoContainer.addSubview(mapView, positioned: .below, relativeTo: accountContainer)
            mapView.snp.makeConstraints { make in
                make.leading.equalTo(bottomContainer)
                make.trailing.equalTo(bottomContainer)
                make.top.equalTo(bottomContainer)
                make.bottom.equalTo(bottomContainer)
            }
            
            var coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let annotation = Annotation(coordinate: coordinate)
            mapView.addAnnotation(annotation)
            let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            coordinate.latitude += 0.0025
            let region = MKCoordinateRegion(center: coordinate, span: span)
            mapView.setRegion(region, animated: false)
            
            if hasCategory {
                categoryView.snp.makeConstraints { make in
                    make.bottom.equalTo(infoContainer)
                    make.leading.equalTo(infoContainer)
                    make.trailing.equalTo(infoContainer)
                    make.height.equalTo(30)
                }
            }
        } else if hasCategory {
            categoryView.snp.makeConstraints { make in
                make.top.equalTo(accountContainer.snp.bottom).offset(3)
                make.leading.equalTo(institutionInitialsCircleView).offset(-5)
                make.trailing.equalTo(infoContainer)
                make.height.equalTo(30)
            }
        }
        
        categoryView?.category = model.category
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
        Answers.logContentView(withName: "Transactions tab cell expanded", contentType: nil, contentId: nil, customAttributes: nil)
        
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
