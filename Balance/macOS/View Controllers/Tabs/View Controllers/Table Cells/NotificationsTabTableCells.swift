//
//  NotificationsTabTableCells.swift
//  Bal
//
//  Created by Benjamin Baron on 5/22/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation
import MapKit

class NotificationsTabGroupCell: View {
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
        blurryView.layerBackgroundColor = CurrentTheme.feed.headerCell.backgroundColor
        self.addSubview(blurryView)
        blurryView.snp.makeConstraints { make in
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
        }
        
        dateField.font = CurrentTheme.feed.headerCell.dateFont
        dateField.textColor = CurrentTheme.feed.headerCell.dateColor
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
        
        if model == Date.distantFuture {
            dateString = "Pending"
        } else if model.isToday{
            dateString = "Today"
        } else if model.isYesterday {
            dateString = "Yesterday"
        } else {
            dateFormatter.dateFormat = (model.isThisYear ? "EEEE MMM d" : "EEEE MMM d y")
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

class NotificationsTabTransactionCell: View {
    fileprivate let unreadIndicatorDiameter: Float = 8.0
    
    var model: Transaction?
    var index = TableIndex.none
    
    let topContainer = View()
    let nameField = LabelField()
    let ruleField = LabelField()
    let unreadIndicator = View()
    var unreadIndicatorShowing = false
    
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
            make.height.equalTo(CurrentTheme.feed.cell.height)
        }
        
        nameField.backgroundColor = CurrentTheme.defaults.cell.backgroundColor
        nameField.alignment = .left
        nameField.font = CurrentTheme.feed.cell.nameFont
        nameField.textColor = CurrentTheme.defaults.foregroundColor
        nameField.usesSingleLineMode = true
        nameField.cell?.lineBreakMode = .byTruncatingTail
        topContainer.addSubview(nameField)
        nameField.snp.makeConstraints { make in
            make.leading.equalTo(topContainer).offset(12)
            make.trailing.equalTo(topContainer).offset(-12)
            make.top.equalTo(topContainer).offset(8)
        }
        
        ruleField.backgroundColor = CurrentTheme.defaults.cell.backgroundColor
        ruleField.alignment = .left
        ruleField.alphaValue = 0.6
        ruleField.usesSingleLineMode = true
        topContainer.addSubview(ruleField)
        ruleField.snp.makeConstraints { make in
            make.leading.equalTo(nameField)
            make.trailing.equalTo(nameField)
            make.height.equalTo(14).priority(0.1)
            make.top.equalTo(nameField.snp.bottom).offset(2)
        }
        
        unreadIndicator.layerBackgroundColor = CurrentTheme.feed.cell.unreadIndicatorColor
        unreadIndicator.cornerRadius = unreadIndicatorDiameter / 2.0
        unreadIndicator.isHidden = true
        topContainer.addSubview(unreadIndicator)
        unreadIndicator.snp.makeConstraints { make in
            make.width.equalTo(unreadIndicatorDiameter)
            make.height.equalTo(unreadIndicatorDiameter)
            make.centerY.equalTo(topContainer)
            make.trailing.equalTo(-12)
        }
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(cellOpened(_:)), name: NotificationsTabViewController.InternalNotifications.CellOpened)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(cellClosed(_:)), name: NotificationsTabViewController.InternalNotifications.CellClosed)
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    deinit {
        NotificationCenter.removeObserverOnMainThread(self, name: NotificationsTabViewController.InternalNotifications.CellOpened)
        NotificationCenter.removeObserverOnMainThread(self, name: NotificationsTabViewController.InternalNotifications.CellClosed)
    }
    
    func updateModel(_ updatedModel: Transaction) {
        hideBottomContainer()
        
        model = updatedModel
        
        let show = defaults.unreadNotificationIds.contains(updatedModel.transactionId)
        showHideUnreadIndicator(show: show)
        
        let boldAttributes = [NSAttributedStringKey.font: CurrentTheme.feed.cell.nameBoldFont,
                              NSAttributedStringKey.foregroundColor: CurrentTheme.feed.cell.nameBoldColor]
        let regularAttributes = [NSAttributedStringKey.font: CurrentTheme.feed.cell.nameFont,
                                 NSAttributedStringKey.foregroundColor: CurrentTheme.feed.cell.nameColor]
        
        let nameAttributedString = NSMutableAttributedString()
        nameAttributedString.append(NSAttributedString(string: centsToString(-updatedModel.amount), attributes: boldAttributes))
        nameAttributedString.append(NSAttributedString(string: " for ", attributes: regularAttributes))
        nameAttributedString.append(NSAttributedString(string: updatedModel.displayName, attributes: boldAttributes))
        if let accountName = updatedModel.account?.displayName {
            nameAttributedString.append(NSAttributedString(string: " in \(accountName)", attributes: regularAttributes))
        }
        
        // Fix tail truncating because we're setting the attributedStringValue property directly
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byTruncatingTail
        nameAttributedString.addAttributes([NSAttributedStringKey.paragraphStyle:paragraph], range: NSRange(location: 0, length: nameAttributedString.length))
        
        nameField.attributedStringValue = nameAttributedString
        ruleField.stringValue = updatedModel.rulesDisplayName ?? ""
        
        self.toolTip = nameAttributedString.string
    }
    
    func showHideUnreadIndicator(show: Bool) {
        if show != unreadIndicatorShowing {
            unreadIndicatorShowing = show
            unreadIndicator.isHidden = !show
            
            nameField.snp.updateConstraints { make in
                if show {
                    make.trailing.equalTo(topContainer).offset(-40)
                } else {
                    make.trailing.equalTo(topContainer).offset(-12)
                }
            }
        }
    }
    
    func showBottomContainer() {
        guard bottomContainer == nil, let model = model else {
            return
        }
        
        // Analytics
        BITHockeyManager.shared()?.metricsManager?.trackEvent(withName: "Feed tab cell expanded")
        
        let userInfo = [NotificationsTabViewController.InternalNotifications.Keys.Cell: self]
        NotificationCenter.postOnMainThread(name: NotificationsTabViewController.InternalNotifications.CellOpened, object: nil, userInfo: userInfo)
        
        let hasCategory = (model.categoryId != nil)
        
        bottomContainer = View()
        self.addSubview(bottomContainer)
        bottomContainer.snp.makeConstraints { make in
            make.top.equalTo(topContainer.snp.bottom)
            make.leading.equalTo(topContainer).offset(12)
            make.trailing.equalTo(topContainer).offset(-12)
            make.height.equalTo(200)
        }
        
        infoContainer = View()
        bottomContainer.addSubview(infoContainer)
        infoContainer.snp.makeConstraints { make in
            make.leading.equalTo(bottomContainer)
            make.trailing.equalTo(bottomContainer)
            make.top.equalTo(bottomContainer).offset(1)
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
        institutionField.backgroundColor = CurrentTheme.feed.cellExpansion.institutionBackground
        institutionField.layerBackgroundColor = CurrentTheme.feed.cellExpansion.institutionBackground
        institutionField.alignment = .center
        institutionField.verticalAlignment = .center
        institutionField.font = CurrentTheme.feed.cellExpansion.institutionFont
        institutionField.textColor = CurrentTheme.feed.cellExpansion.fontColor
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
        accountField.font = CurrentTheme.feed.cellExpansion.accountFont
        accountField.textColor = CurrentTheme.feed.cellExpansion.fontColor.withAlphaComponent(0.9)
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
                make.leading.equalTo(infoContainer).offset(-5)
                make.trailing.equalTo(infoContainer)
                make.height.equalTo(30)
            }
        }
        
        categoryView?.category = model.category
        institutionField.stringValue = model.institution!.name
        accountField.stringValue = model.account!.name
    }
    
    func hideBottomContainer(notify: Bool = true) {
        if bottomContainer != nil {
            if notify {
                NotificationCenter.postOnMainThread(name: NotificationsTabViewController.InternalNotifications.CellClosed)
            }
            
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
    
    @objc fileprivate func cellOpened(_ notification: Notification) {
        if let cell = notification.userInfo?[NotificationsTabViewController.InternalNotifications.Keys.Cell] as? NotificationsTabTransactionCell {
            self.animator().alphaValue = cell == self ? 1.0 : CurrentTheme.feed.cell.dimmedAlpha
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
