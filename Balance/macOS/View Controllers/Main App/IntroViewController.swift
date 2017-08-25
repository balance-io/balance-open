//
//  IntroViewController.swift
//  Bal
//
//  Created by Benjamin Baron on 9/18/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation
import AppKit
import SwiftyStoreKit
import StoreKit
import BalanceVectorGraphics

fileprivate enum SubscriptionType: Int {
    case lightMonthly  = 1
    case basicMonthly  = 2
    case basicAnnual   = 3
    case mediumMonthly = 4
    case mediumAnnual  = 5
    
    var productId: ProductId {
        switch self {
        case .lightMonthly:  return ProductId.lightMonthly
        case .basicMonthly:  return ProductId.basicMonthly
        case .basicAnnual:   return ProductId.basicAnnual
        case .mediumMonthly: return ProductId.mediumMonthly
        case .mediumAnnual:  return ProductId.mediumAnnual
        }
    }
}

class IntroViewController: NSViewController {
    fileprivate let height: CGFloat = 641
    fileprivate let isLight = (CurrentTheme.type == .light)
    
    let autoRenewLabel = LabelField()
    
    fileprivate let containerView  = View()
    fileprivate let accountsContainerView = View()
    
    fileprivate var subscribeButtons = [Button]()
    
    fileprivate var searchController: AddAccountViewController?
    fileprivate var feedbackViewController: EmailIssueController?
    
    fileprivate let closeBlock: () -> Void
    
    fileprivate var subscribeFailed = false
    
    // MARK: - Lifecycle -
    
    init(closeBlock: @escaping () -> Void) {
        self.closeBlock = closeBlock
        super.init(nibName: nil, bundle: nil)
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(close), name: Notifications.ProductPurchased)
        
        addShortcutMonitor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    deinit {
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.ProductPurchased)
        removeShortcutMonitor()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        let backgroundColor = isLight ? NSColor(deviceRedInt: 245, green: 247, blue: 250) : NSColor(deviceRedInt: 26, green: 37, blue: 51)
        AppDelegate.sharedInstance.statusItem.arrowColor = backgroundColor
        self.view.layerBackgroundColor = backgroundColor
        
        AppDelegate.sharedInstance.resizeWindowHeight(height, animated: true)
    }
    
    // MARK - View Creation -
    
    override func loadView() {
        self.view = View()
        
        self.view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        let logoImage = #imageLiteral(resourceName: "intro-logo")
        let logoImageView = ImageView()
        logoImageView.image = logoImage
        containerView.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.width.equalTo(logoImage.size.width)
            make.height.equalTo(logoImage.size.height)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
        }
        
        let trianglesImage = isLight ? #imageLiteral(resourceName: "intro-light-triangles") : #imageLiteral(resourceName: "intro-dark-triangles")
        let trianglesImageView = ImageView()
        trianglesImageView.image = trianglesImage
        containerView.addSubview(trianglesImageView)
        trianglesImageView.snp.makeConstraints { make in
            make.width.equalTo(trianglesImage.size.width)
            make.height.equalTo(trianglesImage.size.height)
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        let titleColor = isLight ? NSColor(deviceRedInt: 59, green: 71, blue: 94)
            : NSColor(deviceRedInt: 224, green: 229, blue: 237)
        
        let welcomeAttributedString = NSMutableAttributedString(string: "Balance for Mac")
        welcomeAttributedString.addAttributes([NSAttributedStringKey.font: NSFont.mediumSystemFont(ofSize: 23),
                                               NSAttributedStringKey.foregroundColor: titleColor,
                                               NSAttributedStringKey.paragraphStyle: centeredParagraphStyle],
                                              range: NSRange(location: 0, length: 7))
        welcomeAttributedString.addAttributes([NSAttributedStringKey.font: NSFont.lightSystemFont(ofSize: 23),
                                               NSAttributedStringKey.foregroundColor: titleColor,
                                               NSAttributedStringKey.paragraphStyle: centeredParagraphStyle],
                                              range: NSRange(location: 7, length: 8))
        
        let welcomeField = LabelField()
        welcomeField.attributedStringValue = welcomeAttributedString
        welcomeField.usesSingleLineMode = true
        welcomeField.verticalAlignment = .center
        containerView.addSubview(welcomeField)
        welcomeField.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(36)
            make.centerX.equalToSuperview()
            make.top.equalTo(logoImageView.snp.bottom).offset(15)
        }
        
        let searchButtonImage = isLight ? #imageLiteral(resourceName: "intro-light-search-field") : #imageLiteral(resourceName: "intro-dark-search-field")
        let searchButtonAltImage = isLight ? #imageLiteral(resourceName: "intro-light-search-field-pressed") : #imageLiteral(resourceName: "intro-dark-search-field-pressed")
        let searchButton = Button()
        searchButton.image = searchButtonImage
        searchButton.alternateImage = searchButtonAltImage
        searchButton.isBordered = false
        searchButton.setButtonType(.momentaryChange)
        searchButton.setAccessibilityLabel("Search Institutions")
        searchButton.target = self
        searchButton.action = #selector(search)
        containerView.addSubview(searchButton)
        searchButton.snp.makeConstraints { make in
            make.width.equalTo(searchButtonImage.size.width)
            make.height.equalTo(searchButtonImage.size.height)
            make.centerX.equalToSuperview()
            make.top.equalTo(welcomeField.snp.bottom).offset(2)
        }
        
        autoRenewLabel.alignment = .left
        autoRenewLabel.verticalAlignment = .center
        autoRenewLabel.stringValue = "Subscriptions renew automatically."
        autoRenewLabel.font = .systemFont(ofSize: 12)
        autoRenewLabel.textColor = isLight ? NSColor(deviceRedInt: 144, green: 145, blue: 146) : NSColor(deviceRedInt: 120, green: 130, blue: 149)
        autoRenewLabel.setAccessibilityLabel("Subscriptions renew automatically.")
        containerView.addSubview(autoRenewLabel)
        autoRenewLabel.snp.makeConstraints { make in
            make.width.equalTo(344)
            make.height.equalTo(18)
            make.left.equalToSuperview().offset(28)
            make.top.equalTo(searchButton.snp.bottom).offset(9)
        }
        
        let buttonBlueColor = isLight ? NSColor(deviceRedInt: 39, green: 132, blue: 240) : NSColor(deviceRedInt: 71, green: 152, blue: 244)
        let buttonAltBlueColor = isLight ? NSColor(deviceRedInt: 39, green: 132, blue: 240, alpha: 0.7) : NSColor(deviceRedInt: 71, green: 152, blue: 244, alpha: 0.7)
        let autoRenewAttributes = [NSAttributedStringKey.foregroundColor: buttonBlueColor,
                                   NSAttributedStringKey.font: NSFont.semiboldSystemFont(ofSize: 12),
                                   NSAttributedStringKey.paragraphStyle: rightParagraphStyle]
        let autoRenewAltAttributes = [NSAttributedStringKey.foregroundColor: buttonAltBlueColor,
                                      NSAttributedStringKey.font: NSFont.semiboldSystemFont(ofSize: 12),
                                      NSAttributedStringKey.paragraphStyle: rightParagraphStyle]
        
        let autoRenewMoreInfoButton = Button()
        autoRenewMoreInfoButton.attributedTitle = NSAttributedString(string:"More Info", attributes: autoRenewAttributes)
        autoRenewMoreInfoButton.attributedAlternateTitle = NSAttributedString(string:"More Info", attributes: autoRenewAltAttributes)
        autoRenewMoreInfoButton.setAccessibilityLabel("More Info")
        autoRenewMoreInfoButton.isBordered = false
        autoRenewMoreInfoButton.setButtonType(.momentaryChange)
        autoRenewMoreInfoButton.target = self
        autoRenewMoreInfoButton.sizeToFit()
        autoRenewMoreInfoButton.action = #selector(autoRenewMoreInfo)
        containerView.addSubview(autoRenewMoreInfoButton)
        autoRenewMoreInfoButton.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.right.equalToSuperview().offset(-26)
            make.centerY.equalTo(autoRenewLabel)
        }
        
        createAccountButtons(topView: autoRenewLabel)
        
        let descriptionTitleLabel = LabelField()
        descriptionTitleLabel.alignment = .left
        descriptionTitleLabel.font = .semiboldSystemFont(ofSize: 14)
        descriptionTitleLabel.textColor = titleColor
        descriptionTitleLabel.usesSingleLineMode = true
        descriptionTitleLabel.stringValue = "Why we charge a subscription"
        descriptionTitleLabel.setAccessibilityLabel("Why we charge a subscription")
        containerView.addSubview(descriptionTitleLabel)
        descriptionTitleLabel.snp.makeConstraints { make in
            make.width.equalTo(300)
            make.height.equalTo(18)
            make.left.equalToSuperview().offset(28)
            make.top.equalTo(accountsContainerView.snp.bottom).offset(-123)
        }
        
        let descriptionParagraphStyle = NSMutableParagraphStyle()
        descriptionParagraphStyle.alignment = .left
        descriptionParagraphStyle.lineHeightMultiple = 1.085
        let descriptionTextColor = isLight ? NSColor(deviceWhiteInt: 51, alpha: 0.72) : NSColor(deviceRedInt: 186, green: 195, blue: 218, alpha: 0.72)
        let descriptionAttributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.paragraphStyle: descriptionParagraphStyle,
                                                                   NSAttributedStringKey.font: NSFont.systemFont(ofSize: 13),
                                                                   NSAttributedStringKey.foregroundColor: descriptionTextColor]
        
        let descriptionText = "It costs money to securely access your financial data. Other apps cover those costs by recommending credit cards or selling your data. We just want to sell software."
        let descriptionLabel = LabelField()
        descriptionLabel.attributedStringValue = NSAttributedString(string: descriptionText, attributes: descriptionAttributes)
        descriptionLabel.setAccessibilityLabel(descriptionText)
        containerView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.width.equalTo(344)
            make.height.equalTo(55.5)
            make.left.equalTo(descriptionTitleLabel)
            make.top.equalTo(descriptionTitleLabel.snp.bottom).offset(7)
        }
        
        let descriptionText2 = "If you’re not satisfied, we’ll happily send you a refund."
        let descriptionLabel2 = LabelField()
        descriptionLabel2.attributedStringValue = NSAttributedString(string: descriptionText2, attributes: descriptionAttributes)
        descriptionLabel2.setAccessibilityLabel(descriptionText2)
        containerView.addSubview(descriptionLabel2)
        descriptionLabel2.snp.makeConstraints { make in
            make.width.equalTo(344)
            make.height.equalTo(18.5)
            make.left.equalTo(descriptionTitleLabel)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(8)
        }
        
        let buttonAttributes = [NSAttributedStringKey.foregroundColor: buttonBlueColor,
                                NSAttributedStringKey.font: NSFont.semiboldSystemFont(ofSize: 13)]
        let buttonAltAttributes = [NSAttributedStringKey.foregroundColor: buttonAltBlueColor,
                                   NSAttributedStringKey.font: NSFont.semiboldSystemFont(ofSize: 13)]
        
        let restoreButton = Button()
        restoreButton.attributedTitle = NSAttributedString(string:"Restore", attributes: buttonAttributes)
        restoreButton.attributedAlternateTitle = NSAttributedString(string:"Restore", attributes: buttonAltAttributes)
        restoreButton.setAccessibilityLabel("Restore")
        restoreButton.isBordered = false
        restoreButton.setButtonType(.momentaryChange)
        restoreButton.target = self
        restoreButton.sizeToFit()
        restoreButton.action = #selector(restoreSubscription)
        containerView.addSubview(restoreButton)
        restoreButton.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.left.equalTo(descriptionTitleLabel).offset(-2)
            make.top.equalTo(descriptionLabel2.snp.bottom).offset(22)
        }
        subscribeButtons.append(restoreButton)
        
        let dotLabel1 = LabelField()
        dotLabel1.stringValue = "•"
        dotLabel1.font = .semiboldSystemFont(ofSize: 13)
        dotLabel1.textColor = buttonBlueColor
        dotLabel1.verticalAlignment = .center
        dotLabel1.sizeToFit()
        containerView.addSubview(dotLabel1)
        dotLabel1.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.left.equalTo(restoreButton.snp.right).offset(5)
            make.top.equalTo(restoreButton)
        }
        
        let privacyButton = Button()
        privacyButton.attributedTitle = NSAttributedString(string:"Privacy", attributes: buttonAttributes)
        privacyButton.attributedAlternateTitle = NSAttributedString(string:"Privacy", attributes: buttonAltAttributes)
        privacyButton.setAccessibilityLabel("Privacy")
        privacyButton.isBordered = false
        privacyButton.setButtonType(.momentaryChange)
        privacyButton.target = self
        privacyButton.sizeToFit()
        privacyButton.action = #selector(privacy)
        containerView.addSubview(privacyButton)
        privacyButton.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.left.equalTo(dotLabel1.snp.right).offset(5)
            make.top.equalTo(restoreButton)
        }
        
        let dotLabel2 = LabelField()
        dotLabel2.stringValue = "•"
        dotLabel2.font = .semiboldSystemFont(ofSize: 13)
        dotLabel2.textColor = buttonBlueColor
        dotLabel2.verticalAlignment = .center
        dotLabel2.sizeToFit()
        containerView.addSubview(dotLabel2)
        dotLabel2.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.left.equalTo(privacyButton.snp.right).offset(5)
            make.top.equalTo(restoreButton)
        }
        
        let termsButton = Button()
        termsButton.attributedTitle = NSAttributedString(string:"Terms", attributes: buttonAttributes)
        termsButton.attributedAlternateTitle = NSAttributedString(string:"Terms", attributes: buttonAltAttributes)
        termsButton.setAccessibilityLabel("Terms")
        termsButton.isBordered = false
        termsButton.setButtonType(.momentaryChange)
        termsButton.target = self
        termsButton.sizeToFit()
        termsButton.action = #selector(terms)
        containerView.addSubview(termsButton)
        termsButton.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.left.equalTo(dotLabel2.snp.right).offset(5)
            make.top.equalTo(restoreButton)
        }
        
        let dotLabel3 = LabelField()
        dotLabel3.stringValue = "•"
        dotLabel3.font = .semiboldSystemFont(ofSize: 13)
        dotLabel3.textColor = buttonBlueColor
        dotLabel3.verticalAlignment = .center
        dotLabel3.sizeToFit()
        containerView.addSubview(dotLabel3)
        dotLabel3.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.left.equalTo(termsButton.snp.right).offset(5)
            make.top.equalTo(restoreButton)
        }
        
        let contactButton = Button()
        contactButton.attributedTitle = NSAttributedString(string:"Contact", attributes: buttonAttributes)
        contactButton.attributedAlternateTitle = NSAttributedString(string:"Contact", attributes: buttonAltAttributes)
        contactButton.setAccessibilityLabel("Contact")
        contactButton.isBordered = false
        contactButton.setButtonType(.momentaryChange)
        contactButton.target = self
        contactButton.sizeToFit()
        contactButton.action = #selector(contact)
        containerView.addSubview(contactButton)
        contactButton.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.left.equalTo(dotLabel3.snp.right).offset(5)
            make.top.equalTo(restoreButton)
        }

        // Preferences button
        let preferencesButton = Button()
        preferencesButton.target = self
        preferencesButton.action = #selector(showSettingsMenu(_:))
        preferencesButton.image = isLight ? #imageLiteral(resourceName: "intro-gear-icon-light") : #imageLiteral(resourceName: "intro-gear-icon-dark")
        preferencesButton.setButtonType(.momentaryChange)
        preferencesButton.setAccessibilityLabel("Preferences")
        preferencesButton.isBordered = false
        containerView.addSubview(preferencesButton)
        preferencesButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-23)
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalTo(16)
            make.height.equalTo(16)
        }
    }
    
    fileprivate func createAccountButtons(topView: NSView) {
        let showLightPlan = subscriptionManager.showLightPlanInIntro
        
        var accountsImage = isLight ? #imageLiteral(resourceName: "intro-light") : #imageLiteral(resourceName: "intro-dark")
        if showLightPlan {
            accountsImage = isLight ? #imageLiteral(resourceName: "intro-light-trial") : #imageLiteral(resourceName: "intro-dark-trial")
        }
        containerView.addSubview(accountsContainerView)
        accountsContainerView.snp.makeConstraints { make in
            make.width.equalTo(accountsImage.size.width)
            make.height.equalTo(accountsImage.size.height)
            make.centerX.equalToSuperview()
            make.top.equalTo(topView.snp.bottom).offset(-32)
        }
        
        let accountsImageView = ImageView()
        accountsImageView.image = accountsImage
        accountsContainerView.addSubview(accountsImageView)
        accountsImageView.snp.makeConstraints { make in
            make.width.equalTo(accountsImage.size.width)
            make.height.equalTo(accountsImage.size.height)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        if showLightPlan {
            let lightMonthlyButton = PaintCodeButton()
            lightMonthlyButton.drawingFunction = IntroScreen.drawLightMonthlyButton
            lightMonthlyButton.tag = SubscriptionType.lightMonthly.rawValue
            lightMonthlyButton.target = self
            lightMonthlyButton.action = #selector(subscribe(sender:))
            accountsContainerView.addSubview(lightMonthlyButton)
            lightMonthlyButton.snp.makeConstraints { make in
                make.width.equalTo(84)
                make.height.equalTo(40)
                make.centerX.equalToSuperview().offset(-120)
                make.top.equalToSuperview().offset(195)
            }
            subscribeButtons.append(lightMonthlyButton)
        }
        
        let basicMonthlyButton = PaintCodeButton()
        basicMonthlyButton.drawingFunction = IntroScreen.drawBasicMonthlyButton
        basicMonthlyButton.tag = SubscriptionType.basicMonthly.rawValue
        basicMonthlyButton.target = self
        basicMonthlyButton.action = #selector(subscribe(sender:))
        accountsContainerView.addSubview(basicMonthlyButton)
        basicMonthlyButton.snp.makeConstraints { make in
            make.width.equalTo(84)
            make.height.equalTo(40)
            make.top.equalToSuperview().offset(195)
            if showLightPlan {
                make.centerX.equalToSuperview()
            } else {
                make.centerX.equalToSuperview().offset(-90)
            }
        }
        subscribeButtons.append(basicMonthlyButton)
        
        let basicAnnualButton = PaintCodeButton()
        basicAnnualButton.drawingFunction = IntroScreen.drawBasicAnnualButton
        basicAnnualButton.tag = SubscriptionType.basicAnnual.rawValue
        basicAnnualButton.target = self
        basicAnnualButton.action = #selector(subscribe(sender:))
        accountsContainerView.addSubview(basicAnnualButton)
        basicAnnualButton.snp.makeConstraints { make in
            make.width.equalTo(90)
            make.height.equalTo(46)
            make.top.equalToSuperview().offset(239)
            make.centerX.equalTo(basicMonthlyButton)
        }
        subscribeButtons.append(basicAnnualButton)
        
        let mediumMonthlyButton = PaintCodeButton()
        mediumMonthlyButton.drawingFunction = IntroScreen.drawMediumMonthlyButton
        mediumMonthlyButton.tag = SubscriptionType.mediumMonthly.rawValue
        mediumMonthlyButton.target = self
        mediumMonthlyButton.action = #selector(subscribe(sender:))
        accountsContainerView.addSubview(mediumMonthlyButton)
        mediumMonthlyButton.snp.makeConstraints { make in
            make.width.equalTo(84)
            make.height.equalTo(40)
            make.top.equalToSuperview().offset(195)
            if showLightPlan {
                make.centerX.equalToSuperview().offset(120)
            } else {
                make.centerX.equalToSuperview().offset(90)
            }
        }
        subscribeButtons.append(mediumMonthlyButton)
        
        let mediumAnnualButton = PaintCodeButton()
        mediumAnnualButton.drawingFunction = IntroScreen.drawMediumAnnualButton
        mediumAnnualButton.tag = SubscriptionType.mediumAnnual.rawValue
        mediumAnnualButton.target = self
        mediumAnnualButton.action = #selector(subscribe(sender:))
        accountsContainerView.addSubview(mediumAnnualButton)
        mediumAnnualButton.snp.makeConstraints { make in
            make.width.equalTo(90)
            make.height.equalTo(46)
            make.top.equalToSuperview().offset(239)
            make.centerX.equalTo(mediumMonthlyButton)
        }
        subscribeButtons.append(mediumAnnualButton)
    }
    
    // MARK: - Actions -
    
    @objc fileprivate func search() {
        searchController = AddAccountViewController()
        searchController!.allowSelection = false
        searchController!.backFunction = {
            self.view.replaceSubview(self.searchController!.view, with: self.containerView, animation: .slideInFromLeft)
            AppDelegate.sharedInstance.resizeWindowHeight(self.height, animated: true)
            self.searchController = nil
        }
        self.view.replaceSubview(self.containerView, with: self.searchController!.view, animation: .slideInFromRight)
        async(after: 0.4) {
            self.view.window?.makeFirstResponder(self.searchController!.searchField)
        }
    }
    
    @objc fileprivate func subscribe(sender: Button) {
        disableSubscribeButtons()
        subscribeFailed = false
        
        var productId = ProductId.basicMonthly
        if let subscriptionType = SubscriptionType(rawValue: sender.tag) {
            productId = subscriptionType.productId
        }
        log.debug("Subscribing to \(productId)")
        
        // Try to subscribe
        subscriptionManager.subscribe(productId: productId) { success, errorMessage, error in
            if success {
                self.handleSuccess()
            } else {
                self.handleFailure(isSubscribe: true, error: error, message: errorMessage)
            }
        }
    }

    @objc fileprivate func restoreSubscription() {
        disableSubscribeButtons()
        subscribeFailed = false
        
        // Try to restore the subscription
        subscriptionManager.restoreSubscription { success, error in
            if success {
                self.handleSuccess()
            } else {
                self.handleFailure(isSubscribe: false, error: error, message: "")
            }
        }
    }
    
    fileprivate func disableSubscribeButtons() {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.1
            for button in subscribeButtons {
                do {
                    try ObjC.catchException {
                        button.isEnabled = false
                        button.animator().alphaValue = 0.7
                    }
                } catch {
                    log.error("Got an AppKit exception when trying to disable the subscribe buttons: \(error)")
                }
                
            }
        }, completionHandler: nil)
        
        // Tell welcome window
        NotificationCenter.postOnMainThread(name: Notifications.SubscribeStarted)
    }
    
    fileprivate func enableSubscribeButtons() {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.1
            for button in subscribeButtons {
                do {
                    try ObjC.catchException {
                        button.isEnabled = true
                        button.animator().alphaValue = 1.0
                    }
                } catch {
                    log.error("Got an AppKit exception when trying to enable the subscribe buttons: \(error)")
                }
            }
        }, completionHandler: nil)
        
        // Tell welcome window
        NotificationCenter.postOnMainThread(name: Notifications.SubscribeFailed)
    }
    
    fileprivate func handleSuccess() {
        // Success, show the popover
        async(after: 0.5) {
            NotificationCenter.postOnMainThread(name: Notifications.ShowPopover)
            self.close()
        }
    }
    
    fileprivate func handleFailure(isSubscribe: Bool, error: Error?, message: String) {
        // Use the subscribeFailed boolean to prevent multiple error messages from being posted
        // when we get multiple failure callbacks from StoreKit
        if !subscribeFailed {
            subscribeFailed = true
            
            var userCanceled = false
            if let error = error, error.domain == SKErrorDomain, error.code == SKError.Code.paymentCancelled.rawValue {
                userCanceled = true
            }
            
            if userCanceled {
                // Not really a failure, since the user canceled, so just re-enable the subscribe buttons
                enableSubscribeButtons()
                
                // If the user hit restore from the popover, show it again as it will now be hidden
                async(after: 0.5) {
                    NotificationCenter.postOnMainThread(name: Notifications.ShowPopover)
                }
            } else {
                let alert = NSAlert()
                alert.alertStyle = .critical
                if isSubscribe {
                    alert.messageText = "Problem with Purchase"
                    alert.informativeText = "We had a problem completing your subscription: \(message)\n\nWe apologize for the inconvenience, please try your purchase again."
                } else {
                    alert.messageText = "No existing subscription"
                    alert.informativeText = "It doesn't look like you have an existing subscription.\n\nIf that is incorrect, please try again as there may have been an App Store issue."
                    
                    // Show a different message for expired subscriptions
                    if let error = error as? BalanceServerCode, error == .subscriptionExpired {
                        alert.messageText = "Expired Subscription"
                        
                        if subscriptionManager.expirationDate == Date.distantPast {
                            alert.informativeText = "Your subscription expired.\n\nPlease resubscribe to continue using Balance."
                        } else {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "MMMM d, yyyy"
                            let formattedDate = dateFormatter.string(from: subscriptionManager.expirationDate)
                            alert.informativeText = "Your subscription expired on \(formattedDate). Please resubscribe to continue using Balance."
                        }
                    }
                }
                alert.addButton(withTitle: "OK")
                if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
                    // Re-enable the subscribe buttons
                    enableSubscribeButtons()
                    
                    // If the user hit subscribe from the popover, show it again as it will now be hidden
                    async(after: 0.5) {
                        NotificationCenter.postOnMainThread(name: Notifications.ShowPopover)
                    }
                }
            }            
        }
    }
    
    @objc fileprivate func close() {
        // Hack to color the popover arrow during the push animation
        async(after: 0.12) {
            AppDelegate.sharedInstance.statusItem.arrowColor = NSColor.clear
        }
        closeBlock()
    }
    
    @objc fileprivate func contact() {
        feedbackViewController = EmailIssueController {
            self.view.replaceSubview(self.feedbackViewController!.view, with: self.containerView, animation: .slideInFromLeft)
            AppDelegate.sharedInstance.resizeWindowHeight(self.height, animated: true)
            self.feedbackViewController = nil
        }
        self.view.replaceSubview(containerView, with: self.feedbackViewController!.view, animation: .slideInFromRight)
    }
    
    @objc fileprivate func privacy() {
        let urlString = "https://balancemy.money/privacy"
        _ = try? NSWorkspace.shared.open(URL(string: urlString)!, options: [], configuration: [:])
    }
    
    @objc fileprivate func terms() {
        let urlString = "https://balancemy.money/terms"
        _ = try? NSWorkspace.shared.open(URL(string: urlString)!, options: [], configuration: [:])
    }
   
    fileprivate let autoRenewPopover: NSPopover = {
        let vc = MoreInfoViewController()
        let popover = NSPopover()
        popover.appearance = NSAppearance(named: NSAppearance.Name.vibrantLight)
        popover.contentSize = vc.backgroundImage.size
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = vc
        return popover
    }()
    
    @objc fileprivate func autoRenewMoreInfo() {
        guard !autoRenewPopover.isShown else {
            return
        }
        
        var rect = self.view.convert(autoRenewLabel.bounds, from: autoRenewLabel)
        rect.origin.x = 0
        autoRenewPopover.show(relativeTo: rect, of: self.view, preferredEdge: .minX)
    }
    
    @objc func showSettingsMenu(_ sender: NSButton) {
        let menu = NSMenu()
        menu.addItem(withTitle: "Send Feedback", action: #selector(contact), keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit Balance", action: #selector(quitApp), keyEquivalent: "q")
        
        let event = NSApplication.shared.currentEvent ?? NSEvent()
        NSMenu.popUpContextMenu(menu, with: event, for: sender)
    }
    
    @objc fileprivate func quitApp() {
        NSApp.terminate(nil)
    }
    
    // MARK: - Shortcut monitor -
    
    // Block preferences window from opening
    fileprivate var shortcutMonitor: Any?
    func addShortcutMonitor() {
        if shortcutMonitor == nil {
            shortcutMonitor = NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.keyDown) { event -> NSEvent? in
                if let characters = event.charactersIgnoringModifiers {
                    if event.modifierFlags.contains(NSEvent.ModifierFlags.command) && characters.length == 1 {
                        if characters == "," {
                            // Return nil to eat the event
                            return nil
                        } else if characters == "h" {
                            NotificationCenter.postOnMainThread(name: Notifications.HidePopover)
                            return nil
                        }
                    }
                }
                return event
            }
        }
    }
    
    func removeShortcutMonitor() {
        if let monitor = shortcutMonitor {
            NSEvent.removeMonitor(monitor)
            shortcutMonitor = nil
        }
    }
}

fileprivate class MoreInfoViewController: NSViewController {
    let backgroundImage = #imageLiteral(resourceName: "intro-subscription-info")
    
    fileprivate override func loadView() {
        let imageView = MoreInfoBackgroundView()
        imageView.image = backgroundImage
        self.view = imageView
        self.view.snp.makeConstraints { make in
            make.width.equalTo(backgroundImage.size.width)
            make.height.equalTo(backgroundImage.size.height)
        }
    }
    
    // Hack for arrow color
    fileprivate class MoreInfoBackgroundView: ImageView {
        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            self.superview?.wantsLayer = true
            self.superview?.layerBackgroundColor = .white
        }
    }
}

