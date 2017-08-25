//
//  PreferencesBillingViewController.swift
//  Bal
//
//  Created by Benjamin Baron on 8/2/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation
import Crashlytics
import BalanceVectorGraphics
import StoreKit

class PreferencesBillingViewController: NSViewController {
    
    fileprivate struct BillingPlan {
        let productIdMonthly: ProductId
        let productIdAnnual: ProductId
        let name: String
        let description: String
        let color: NSColor
    }
    
    fileprivate let lightPlan = BillingPlan(productIdMonthly: .lightMonthly, productIdAnnual: .none, name: "Light",  description: "Up to 2 accounts", color: NSColor(deviceRedInt: 99, green: 173, blue: 208))
    
    fileprivate let billingPlans = [
        BillingPlan(productIdMonthly: .basicMonthly, productIdAnnual: .basicAnnual, name: "Basic", description: "Up to 5 accounts", color: NSColor(deviceRed: 0.576, green: 0.678, blue: 0.341, alpha: 1.0)),
        BillingPlan(productIdMonthly: .mediumMonthly, productIdAnnual: .mediumAnnual, name: "Medium", description: "Up to 10 accounts", color: NSColor(deviceRed: 0.204, green: 0.647, blue: 0.678, alpha: 1.0)),
        BillingPlan(productIdMonthly: .proMonthly, productIdAnnual: .proAnnual, name: "Pro", description: "Up to 20 accounts", color: NSColor(deviceRed: 0.882, green: 0.349, blue: 0.267, alpha: 1.0))]
    
    fileprivate var barViews = [View]()
    fileprivate var buttons = [Button]()
    
    fileprivate let explanationField = LabelField()
    
    fileprivate let currentPlanBackgroundView = View()
    fileprivate let currentPlanField = LabelField()
    
    fileprivate let linkField = LabelField()
    fileprivate let manageSubscriptionsButton = Button()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        explanationField.stringValue = "Subscriptions are billed through your iTunes account and renew automatically."
        explanationField.alignment = .left
        explanationField.font = NSFont.systemFont(ofSize: 12)
        explanationField.alphaValue = 0.9
        self.view.addSubview(explanationField)
        explanationField.snp.makeConstraints { make in
            make.top.equalTo(self.view).offset(15)
            make.leading.equalTo(self.view).offset(15)
            make.trailing.equalTo(self.view).offset(-15)
        }
        
        createBars()
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(productPurchased), name: Notifications.ProductPurchased)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        removeBars()
        createBars()
    }
    
    @objc fileprivate func productPurchased() {
        removeBars()
        createBars()
    }
    
    deinit {
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.ProductPurchased)
    }

    func createBars() {
        let barTopOffset = 15
        let barHeight = 75
        let barMargin = 10
        let priceBackgroundWidth = 135
        
        let titleSize: CGFloat = 18
        let subTitleSize: CGFloat = 12
        let priceSize: CGFloat = 16
        
        let buttonTopOffset = 10
        
        let defaultColor = NSColor(deviceRedInt: 160, green: 167, blue: 173)
        let currentProductId = subscriptionManager.productId
        
        var plans = billingPlans
        if subscriptionManager.showLightPlanInPreferences {
            plans.insert(lightPlan, at: 0)
        }
        
        var previousBarView: NSView?
        for plan in plans {
            
            let currentPlan = (currentProductId == plan.productIdMonthly || currentProductId == plan.productIdAnnual)
            let backgroundColor = currentPlan ? plan.color : defaultColor
            var monthlyButtonText = ""
            var annualButtonText = ""
            var monthlyButtonTextColor = NSColor(deviceWhiteInt: 0, alpha: 0.9)
            var annualButtonTextColor = NSColor(deviceWhiteInt: 0, alpha: 0.9)
            var monthlyButtonBlock = BillingButtons.drawUpgrade
            var annualButtonBlock = BillingButtons.drawUpgrade
            if currentPlan {
                if currentProductId == plan.productIdMonthly {
                    monthlyButtonBlock = BillingButtons.drawCurrentPlan
                    monthlyButtonTextColor = plan.color
                    monthlyButtonText = "Current Plan"
                    annualButtonText = "Switch Plan"
                } else {
                    annualButtonBlock = BillingButtons.drawCurrentPlan
                    annualButtonTextColor = plan.color
                    monthlyButtonText = "Switch Plan"
                    annualButtonText = "Current Plan"
                }
            } else {
                if currentProductId.tier < plan.productIdMonthly.tier {
                    monthlyButtonText = "Upgrade"
                    annualButtonText = "Upgrade"
                } else {
                    monthlyButtonText = "Downgrade"
                    annualButtonText = "Downgrade"
                }
            }
            
            let barView = View()
            barView.layerBackgroundColor = backgroundColor
            barView.cornerRadius = 6
            barView.borderWidth = 1
            barView.borderColor = NSColor(deviceRed: 0, green: 0, blue: 0, alpha: 0.06)
            self.view.addSubview(barView)
            barView.snp.makeConstraints { make in
                let topView = previousBarView ?? explanationField
                make.top.equalTo(topView.snp.bottom).offset(barTopOffset)
                make.height.equalTo(barHeight)
                make.leading.equalTo(self.view).offset(15)
                make.trailing.equalTo(self.view).offset(-15)
                make.width.equalTo(470)
            }
            previousBarView = barView
            barViews.append(barView)
            
            let titleField = LabelField()
            titleField.stringValue = plan.name
            titleField.alignment = .left
            titleField.font = .systemFont(ofSize: titleSize)
            titleField.textColor = NSColor.white
            barView.addSubview(titleField)
            titleField.snp.makeConstraints{ make in
                make.top.equalTo(barView).offset(barMargin)
                make.leading.equalTo(barView).offset(12)
            }
            
            let subtitleField = LabelField()
            subtitleField.stringValue = plan.description
            subtitleField.alignment = .left
            subtitleField.font = NSFont.systemFont(ofSize: subTitleSize)
            subtitleField.textColor = NSColor.white
            barView.addSubview(subtitleField)
            subtitleField.snp.makeConstraints{ make in
                make.top.equalTo(titleField.snp.bottom).offset(5)
                make.leading.equalTo(titleField)
            }
            
            let annualBackgroundView = View()
            annualBackgroundView.layerBackgroundColor = .black
            annualBackgroundView.alphaValue = 0.1
            barView.addSubview(annualBackgroundView)
            annualBackgroundView.snp.makeConstraints { make in
                make.top.equalTo(barView)
                make.bottom.equalTo(barView)
                make.width.equalTo(priceBackgroundWidth)
                make.trailing.equalTo(barView)
            }
            
            if plan.productIdAnnual != .none {
                let annualPriceField = LabelField()
                let annualPrice = centsToString(plan.productIdAnnual.price, showNegative: false, showCents: true)
                annualPriceField.stringValue = "\(annualPrice)/year"
                annualPriceField.alignment = .center
                annualPriceField.font = .systemFont(ofSize: priceSize)
                annualPriceField.textColor = .white
                barView.addSubview(annualPriceField)
                annualPriceField.snp.makeConstraints{ make in
                    make.top.equalTo(barView).offset(barMargin)
                    make.centerX.equalTo(annualBackgroundView)
                }
                
                let annualButton = PaintCodeButton()
                annualButton.textDrawingFunction = annualButtonBlock
                annualButton.buttonText = annualButtonText
                annualButton.buttonTextColor = annualButtonTextColor
                annualButton.object = plan.productIdAnnual
                annualButton.target = self
                annualButton.action = #selector(changePlan(_:))
                barView.addSubview(annualButton)
                annualButton.snp.makeConstraints { make in
                    make.top.equalTo(annualPriceField.snp.bottom).offset(buttonTopOffset)
                    make.centerX.equalTo(annualBackgroundView)
                    make.height.equalTo(25)
                    make.width.equalTo(85)
                }
                buttons.append(annualButton)
            }
            
            let monthlyBackgroundView = View()
            monthlyBackgroundView.layerBackgroundColor = .black
            monthlyBackgroundView.alphaValue = 0.05
            barView.addSubview(monthlyBackgroundView)
            monthlyBackgroundView.snp.makeConstraints { make in
                make.top.equalTo(barView)
                make.bottom.equalTo(barView)
                make.width.equalTo(priceBackgroundWidth)
                make.trailing.equalTo(annualBackgroundView.snp.leading)
            }
            
            let monthlyPriceField = LabelField()
            let monthPrice = centsToString(plan.productIdMonthly.price, showNegative: false, showCents: true)
            monthlyPriceField.stringValue = "\(monthPrice)/month"
            monthlyPriceField.alignment = .center
            monthlyPriceField.font = NSFont.systemFont(ofSize: priceSize)
            monthlyPriceField.textColor = NSColor.white
            barView.addSubview(monthlyPriceField)
            monthlyPriceField.snp.makeConstraints{ make in
                make.top.equalTo(barView).offset(barMargin)
                make.centerX.equalTo(monthlyBackgroundView)
            }
            
            let monthlyButton = PaintCodeButton()
            monthlyButton.textDrawingFunction = monthlyButtonBlock
            monthlyButton.buttonText = monthlyButtonText
            monthlyButton.buttonTextColor = monthlyButtonTextColor
            monthlyButton.object = plan.productIdMonthly
            monthlyButton.target = self
            monthlyButton.action = #selector(changePlan(_:))
            barView.addSubview(monthlyButton)
            monthlyButton.snp.makeConstraints { make in
                make.top.equalTo(monthlyPriceField.snp.bottom).offset(buttonTopOffset)
                make.centerX.equalTo(monthlyBackgroundView)
                make.height.equalTo(25)
                make.width.equalTo(85)
            }
            buttons.append(monthlyButton)
        }
        
        let components = Calendar.current.dateComponents([.day], from: Date(), to: subscriptionManager.expirationDate)
        let remainingDays = components.day ?? 0
        let pluralizedDays = "day".pluralize(remainingDays)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, y"
        let expirationDateString = dateFormatter.string(from: subscriptionManager.expirationDate)
        
        //let priceString = centsToString(currentProductId.price)
        
        let attributes = [NSAttributedStringKey.font: NSFont.systemFont(ofSize: 11),
                          NSAttributedStringKey.foregroundColor: NSColor(deviceWhiteInt: 0, alpha: 0.6)]
        //let attributedString = NSAttributedString(string: "You have \(remainingDays) \(pluralizedDays) left on your subscription. You will be billed \(priceString) on \(expirationDateString).\n\nTo cancel you have to go to the subscriptions section of you Apple account in App Store. Click here to go directly.", attributes: attributes)
        let attributedString = NSAttributedString(string: "You have \(remainingDays) \(pluralizedDays) left on your subscription. You will be billed again on \(expirationDateString).\n\nTo cancel you have to go to the subscriptions section of you Apple account in App Store. Click here to go directly.", attributes: attributes)
        let linkedString = createLink(attributedString, linkText: "Click here", urlString: "https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions")
        
        currentPlanField.attributedStringValue = linkedString
        currentPlanField.isSelectable = true
        currentPlanField.sizeToFit()
        currentPlanField.allowsEditingTextAttributes = true
        self.view.addSubview(currentPlanField)
        currentPlanField.snp.makeConstraints{ make in
            make.top.equalTo(previousBarView!.snp.bottom).offset(barTopOffset)
            make.leading.equalTo(self.view).offset(barTopOffset)
            make.trailing.equalTo(self.view).offset(-barTopOffset)
            //            make.bottom.equalTo(self.view).offset(-barTopOffset)
        }
    }
    
    func removeBars() {
        for view in barViews {
            view.removeFromSuperview()
        }
        barViews = [View]()
        buttons = [Button]()
    }
    
    func createLink(_ text: NSAttributedString, linkText: String, urlString: String) -> NSMutableAttributedString {
        let attrString = NSMutableAttributedString(attributedString: text)
        let linkRange = (attrString.string as NSString).range(of: linkText)
        let attributes: [NSAttributedStringKey : Any] = [NSAttributedStringKey.link: urlString,
                                                         NSAttributedStringKey.foregroundColor: NSColor(deviceRed: 0.11, green: 0.404, blue: 0.8, alpha: 0.7)]
        attrString.addAttributes(attributes, range: linkRange)
        return attrString
    }
    
    @objc fileprivate func changePlan(_ sender: Button) {
        if let productId = sender.object as? ProductId {
            for button in buttons {
                button.isEnabled = false
            }
            
            subscriptionManager.subscribe(productId: productId) { success, errorMessage, error in
                if success {
                    self.removeBars()
                    self.createBars()
                } else {
                    var userCanceled = false
                    if let error = error, error.code == SKError.Code.paymentCancelled.rawValue {
                        userCanceled = true
                    }
                    
                    if userCanceled {
                        for button in self.buttons {
                            button.isEnabled = false
                        }
                    } else {
                        let alert = NSAlert()
                        alert.alertStyle = .critical
                        alert.messageText = "Problem with Purchase"
                        alert.informativeText = "We had a problem completing your subscription: \(errorMessage)\n\nWe apologize for the inconvenience, please try your purchase again."
                        alert.addButton(withTitle: "OK")
                        if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
                            for button in self.buttons {
                                button.isEnabled = false
                            }
                        }
                    }
                }
            }
        }
    }
}
