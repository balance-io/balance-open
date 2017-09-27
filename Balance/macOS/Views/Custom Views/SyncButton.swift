//
//  SyncButton.swift
//  Bal
//
//  Created by Benjamin Baron on 12/14/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation
import BalanceVectorGraphics
import NSDateTimeAgo

class SyncButton: View {
    let offlineText = "Network is offline"
    
    var syncCircle: SyncCircle!
    let statusLabel = LabelField()
    
    var disableMouseHandling = false
    var mouseTrackingArea: NSTrackingArea?
    
    var overrideText: String? {
        didSet {
            statusLabel.stringValue = overrideText ?? ""
        }
    }
    
    fileprivate var isAnimating = false
    fileprivate var stopSyncingAnimation = false
    fileprivate var manuallySynced = false
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    fileprivate func commonInit() {
        createSyncCircle()
        
        statusLabel.verticalAlignment = .center
        statusLabel.alignment = .left
        statusLabel.usesSingleLineMode = true
        statusLabel.cell?.lineBreakMode = .byTruncatingTail
        statusLabel.textColor = CurrentTheme.tabs.footer.syncButtonColor
        statusLabel.font = NSFont.systemFont(ofSize: 11)
        self.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.leading.equalToSuperview().offset(28)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
                
        registerForNotifications()
        if !networkStatus.isReachable {
            overrideText = offlineText
        }
    }
    
    deinit {
        unregisterForNotifications()
    }
    
    override func layout() {
        super.layout()
        setupMouseTrackingArea()
    }
    
    fileprivate func createSyncCircle() {
        if let syncCircle = syncCircle {
            syncCircle.removeFromSuperview()
        }
        
        syncCircle = SyncCircle(syncCircleColor: CurrentTheme.tabs.footer.syncButtonColor)
        self.addSubview(syncCircle)
        syncCircle.snp.makeConstraints { make in
            make.width.equalTo(26)
            make.height.equalTo(26)
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    fileprivate func startSyncAnimation() {
        isAnimating = true
        syncCircle.addStartSyncingAnimation { _ in
            self.continueSyncAnimation()
        }
    }
    
    fileprivate func continueSyncAnimation() {
        if stopSyncingAnimation {
            syncCircle.addFinishSyncingAnimation { _ in
                //self.syncCircle.resetLayerProperties(forLayerIdentifiers: nil)
                self.createSyncCircle()
                self.isAnimating = false
                self.overrideText = nil
            }
            stopSyncingAnimation = false
        } else {
            syncCircle.addSyncingAnimation { _ in
                self.continueSyncAnimation()
            }
        }
    }
    
    //
    // MARK: - Mouse Handling -
    //
    
    fileprivate var mouseHandlingEnabled: Bool {
        return !disableMouseHandling && !isAnimating && networkStatus.isReachable
    }
    
    fileprivate func setupMouseTrackingArea() {
        removeMouseTrackingArea()
        
        mouseTrackingArea = NSTrackingArea(rect: syncCircle.frame, options: [NSTrackingArea.Options.activeInKeyWindow, NSTrackingArea.Options.mouseEnteredAndExited], owner: self, userInfo: nil)
        self.addTrackingArea(mouseTrackingArea!)
    }
    
    fileprivate func removeMouseTrackingArea() {
        if let mouseTrackingArea = mouseTrackingArea {
            self.removeTrackingArea(mouseTrackingArea)
        }
        mouseTrackingArea = nil
    }
    
    override func mouseEntered(with event: NSEvent) {
        if mouseHandlingEnabled {
            overrideText = "Updates automatically every hour. Check now?"
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        if mouseHandlingEnabled {
            overrideText = nil
        }
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        if mouseHandlingEnabled {
            let windowLocation = theEvent.locationInWindow
            let localLocation = self.convert(windowLocation, from: nil)
            var clickFrame = self.frame
            clickFrame.size.width /= 2.0
            if clickFrame.contains(localLocation) {
                manuallySynced = true
                syncManager.sync(userInitiated: true)
                
                // Analytics
                BITHockeyManager.shared()?.metricsManager?.trackEvent(withName: "Synced manually")
            }
        }
    }
    
    //
    // MARK: - Notifications -
    //
    
    fileprivate func registerForNotifications() {
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(syncStarted), name: Notifications.SyncStarted)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(syncingInstitution(_:)), name: Notifications.SyncingInstitution)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(syncCompleted), name: Notifications.SyncCompleted)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(networkBecameReachable), name: Notifications.NetworkBecameReachable)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(networkBecameUnreachable), name: Notifications.NetworkBecameUnreachable)
    }
    
    fileprivate func unregisterForNotifications() {
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.SyncStarted)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.SyncingInstitution)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.SyncCompleted)
    }
    
    @objc fileprivate func syncStarted() {
        if manuallySynced {
            startSyncAnimation()
            overrideText = "Checking for transactions"
        }
    }
    
    // NOTE: Only changing on balances or now because they tend to take a while, but the transactions are very quick
    @objc fileprivate func syncingInstitution(_ notification: Notification) {
        if manuallySynced {
            if let institutionId = notification.userInfo?[Notifications.Keys.InstitutionId] as? Int {
                if let institution = InstitutionRepository.si.institution(institutionId: institutionId) {
                    overrideText = "Checking for transactions from \(institution.name)"
                }
            }
        }
    }
    
    @objc fileprivate func syncCompleted() {
        if manuallySynced {
            manuallySynced = false
            stopSyncingAnimation = true
            overrideText = "Syncing complete"
            async(after: 2.0) {
                self.overrideText = nil
            }
        }
    }
    
    @objc fileprivate func networkBecameReachable() {
        overrideText = nil
    }
    
    @objc fileprivate func networkBecameUnreachable() {
        overrideText = offlineText
    }
}
