//
//  WebSignUpViewController.swift
//  Bal
//
//  Created by Benjamin Baron on 6/28/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Cocoa
import WebKit

class WebSignUpViewController: NSViewController, NSTabViewDelegate, WebPolicyDelegate, WebFrameLoadDelegate {
    
    fileprivate let errorTextColor = NSColor(deviceRedInt: 243, green: 191, blue: 107)
    
    //
    // MARK: - Properties -
    //
    
    fileprivate var source: Source
    fileprivate var sourceInstitutionId: String
    fileprivate var institution: Institution?
    fileprivate let patch: Bool
    fileprivate let closeBlock: (_ finished: Bool) -> Void
    
    fileprivate var primaryColor = NSColor.gray
    fileprivate let margin = 15
    fileprivate var emailIssueController: EmailIssueController?
    fileprivate var lastPlaidErrorCode = -1
    fileprivate var connectionFailures = 0 {
        didSet {
            if connectionFailures == 0 {
                async { self.hideReportFailureButton() }
            } else if connectionFailures > 0 {
                async { self.showReportFailureButton() }
            }
        }
    }
    
    fileprivate let containerView = View()
    fileprivate let webView = WebView()
    
    fileprivate let reportFailureField = LabelField()
    fileprivate let reportFailureButton = Button()
    
    fileprivate let backButton = Button()
    fileprivate let reassuranceField = LabelField()
    fileprivate let expandedExplanationButton = Button()
    
    fileprivate let explanationTabView = NSTabView()
    fileprivate let explanationField = LabelField()
    fileprivate let explanationImage = ImageView()
    
    fileprivate var showingExplanation: Bool {
        return expandedExplanationButton.state == .on
    }
    
    fileprivate var height: CGFloat {
        return 435.0 + (showingExplanation ? 240.0 : 0.0)
    }
    
    //
    // MARK: - Lifecycle -
    //
    
    init(source: Source, sourceInstitutionId: String, patch: Bool = false, institution: Institution? = nil, closeBlock: @escaping (_ finished: Bool) -> Void) {
        self.source = source
        self.sourceInstitutionId = sourceInstitutionId
        self.closeBlock = closeBlock
        self.patch = patch
        self.institution = institution
        log.info("Opened sign up controller for \(source) - \(sourceInstitutionId)")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    deinit {
        webView.close()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let firstItem = explanationTabView.tabViewItems[0]
        explanationTabView.selectTabViewItem(firstItem)
        
        // For some reason (probably AppKit bug), the delegate is not getting called when we call
        // selectTabViewItemAtIndex, so we have to call it manually
        self.tabView(explanationTabView, didSelect: firstItem)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        // Hack to color the popover arrow during the push animation
        async(after: 0.1) {
            AppDelegate.sharedInstance.statusItem.arrowColor = .white
            
            // Must resize after changing the color or the color changes too late
            async {
                AppDelegate.sharedInstance.resizeWindowHeight(self.height, animated: true)
                
                async(after: 0.5) {
                    self.explanationTabView.isHidden = false
                }
            }
        }
    }
    
    //
    // MARK: - View Creation -
    //
    
    override func loadView() {
        self.view = View()
        self.view.snp.makeConstraints { make in
            make.width.equalTo(CurrentTheme.defaults.size.width)
        }
        
        self.view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        webView.policyDelegate = self
        webView.frameLoadDelegate = self
        containerView.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(380)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        if source == .plaid {
            let request = URLRequest(url: PlaidApi.linkInitializationUrl(sourceInstitutionId: sourceInstitutionId))
            webView.mainFrame.load(request)
        }
        
        backButton.bezelStyle = .rounded
        backButton.font = CurrentTheme.addAccounts.buttonFont
        backButton.title = "Back"
        backButton.sizeToFit()
        backButton.target = self
        backButton.action = #selector(cancel)
        containerView.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.height.equalTo(25)
            make.leading.equalToSuperview().offset(margin)
            make.top.equalTo(webView.snp.bottom).offset(margin)
        }
        
        expandedExplanationButton.bezelStyle = .roundedDisclosure
        expandedExplanationButton.setButtonType(.pushOnPushOff)
        expandedExplanationButton.state = .off
        expandedExplanationButton.title = ""
        expandedExplanationButton.target = self
        expandedExplanationButton.action = #selector(toggleExplanation)
        containerView.addSubview(expandedExplanationButton)
        expandedExplanationButton.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.width.equalTo(20)
            make.centerY.equalTo(backButton)
            make.trailing.equalToSuperview().inset(19)
        }
        
        reassuranceField.stringValue = "We use a secure bank service. Learn More:"
        reassuranceField.allowsEditingTextAttributes = true
        reassuranceField.isSelectable = true
        reassuranceField.isEnabled = false
        reassuranceField.alignment = .center
        reassuranceField.lineBreakMode = .byWordWrapping
        reassuranceField.alphaValue = 0.75
        containerView.addSubview(reassuranceField)
        reassuranceField.snp.makeConstraints { make in
            make.leading.equalTo(backButton.snp.trailing).offset(10)
            make.trailing.equalTo(expandedExplanationButton.snp.leading).offset(-10)
            make.centerY.equalTo(backButton)
        }
        
        let tabLabels = ["Basic", "Technical", "Expert"]
        for label in tabLabels {
            let item = NSTabViewItem()
            item.label = label
            explanationTabView.addTabViewItem(item)
        }
        explanationTabView.wantsLayer = true
        explanationTabView.delegate = self
        explanationTabView.isHidden = true
        containerView.addSubview(explanationTabView)
        explanationTabView.snp.makeConstraints { make in
            make.top.equalTo(expandedExplanationButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(margin)
            make.trailing.equalToSuperview().offset(-margin)
            make.height.equalTo(220)
        }
        
        explanationField.lineBreakMode = .byWordWrapping
        explanationTabView.addSubview(explanationField)
        explanationField.snp.makeConstraints { make in
            make.top.equalTo(explanationTabView).inset(30)
            make.centerX.equalTo(explanationTabView).offset(5)
            make.width.equalTo(350)
            make.bottom.equalTo(explanationTabView).inset(10)
        }
    }
    
    @objc func toggleExplanation() {
        // Resize window
        async {
            AppDelegate.sharedInstance.resizeWindowHeight(self.height, animated: true)
        }
    }
    
    func showReportFailureButton() {
        guard reportFailureButton.superview == nil else {
            return
        }
        
        reportFailureButton.alphaValue = 0.0
        reportFailureButton.bezelStyle = .rounded
        reportFailureButton.font = CurrentTheme.addAccounts.buttonFont
        reportFailureButton.title = "Report a problem"
        reportFailureButton.sizeToFit()
        reportFailureButton.target = self
        reportFailureButton.action = #selector(showEmailIssueController)
        containerView.addSubview(reportFailureButton)
        reportFailureButton.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.width.equalTo(150)
            make.centerY.equalTo(backButton)
            make.trailing.equalToSuperview().inset(19)
        }
        
        reportFailureField.alphaValue = 0.0
        reportFailureField.stringValue = "Having trouble connecting?"
        reportFailureField.font = CurrentTheme.addAccounts.buttonFont
        reportFailureField.allowsEditingTextAttributes = true
        reportFailureField.isSelectable = true
        reportFailureField.alignment = .left
        reportFailureField.lineBreakMode = .byWordWrapping
        containerView.addSubview(reportFailureField)
        reportFailureField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(margin)
            make.trailing.equalTo(reportFailureButton.snp.leading).offset(-10)
            make.top.equalTo(backButton.snp.bottom).offset(16)
            make.height.equalTo(30)
        }
        
        async(after: 0.5) {
            if self.expandedExplanationButton.state == .on {
                self.expandedExplanationButton.state = .off
                self.toggleExplanation()
            }
            
            self.reassuranceField.alphaValue = 0.0
            self.expandedExplanationButton.alphaValue = 0.0
            
            self.reportFailureField.alphaValue = 0.75
            self.reportFailureButton.alphaValue = 1.0
        }
    }
    
    func hideReportFailureButton() {
        guard reportFailureButton.superview != nil else {
            return
        }
        
        reportFailureButton.removeFromSuperview()
        reportFailureField.removeFromSuperview()
        
        reassuranceField.alphaValue = 0.75
        expandedExplanationButton.alphaValue = 1.0
    }
    
    fileprivate func createHtmlAttributedString(string: String, font: NSFont, color: NSColor) -> NSAttributedString {
        if let hexColor = color.hexString {
            let finalHtml = "<span style=\"font-family:'\(font.fontName)'; font-size:\(Int(font.pointSize))px; color:\(hexColor);\">\(string)</span>"
            
            if let data = finalHtml.data(using: String.Encoding.utf8) {
                var attributedString: NSAttributedString?
                do {
                    let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
                                                                                       NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue]
                    attributedString =  try NSAttributedString(data: data, options: options, documentAttributes: nil)
                } catch {}
                
                if let attributedString = attributedString {
                    return attributedString
                }
            }
        }
        
        return NSAttributedString(string: string)
    }
    
    //
    // MARK: - Actions -
    //
    
    @objc fileprivate func showEmailIssueController() {
        fatalError("Finish implementing this")
//        guard emailIssueController == nil else {
//            return
//        }
//        
//        // Hack so that explanationTabView doesn't show while resizing
//        explanationTabView.isHidden = true
//        
//        emailIssueController = EmailIssueController(plaidInstitution: plaidInstitution, plaidErrorCode: lastPlaidErrorCode) {
//            self.removeEmailIssueController()
//            self.hideReportFailureButton()
//        }
//        
//        if let emailIssueController = emailIssueController {
//            self.view.replaceSubview(containerView, with: emailIssueController.view, animation: .slideInFromRight)
//        }
    }
    
    fileprivate func removeEmailIssueController() {
        if let emailIssueController = emailIssueController {
            // Hack to color the popover arrow during the push animation
            async(after: 0.1) {
                AppDelegate.sharedInstance.statusItem.arrowColor = self.primaryColor
                
                // Must resize after changing the color or the color changes too late
                async {
                    AppDelegate.sharedInstance.resizeWindowHeight(self.height, animated: true)
                    
                    async(after: 0.5) {
                        // Hack so that explanationTabView doesn't show while resizing
                        self.explanationTabView.isHidden = false
                    }
                }
            }
            
            self.view.replaceSubview(emailIssueController.view, with: containerView, animation: .slideInFromLeft) {
                self.emailIssueController = nil
            }
        }
    }
    
    fileprivate func submitConnectionFailedEvent(_ errorDescription: String) {
        let properties: [String: String] = ["Source":              "\(source.rawValue)",
                                            "SourceInstitutionId": "\(sourceInstitutionId)",
                                            "Error Description":   errorDescription]
        BITHockeyManager.shared()?.metricsManager?.trackEvent(withName: "Connection Failed", properties: properties, measurements: nil)
    }
    
    fileprivate func callCloseBlock(finished: Bool) {
        // Hack to color the popover arrow during the push animation
        async(after: 0.12) {
            AppDelegate.sharedInstance.statusItem.arrowColor = NSColor.clear
            
            // Must resize after changing the color or the color changes too late
            async(after: 0.1) {
                AppDelegate.sharedInstance.resizeWindow(CurrentTheme.defaults.size, animated: true)
            }
        }
        
        closeBlock(false)
    }
    
    @objc fileprivate func close() {
        callCloseBlock(finished: false)
    }
    
    @objc fileprivate func finished() {
        if !patch {
            // TODO: Do this a different way
            // Update the last new institution time so syncs happen faster
            syncManager.syncDefaults.lastNewInstitutionAddedTime = Date()
            
            // If this is a brand new install, sync categories right away
            if CategoryRepository.si.allCategoryNames().count == 0 {
                PlaidApi.pullCategories()
            }
        }
        
        callCloseBlock(finished: true)
    }
    
    @objc fileprivate func cancel() {
        if !patch, let institution = institution {
            PlaidApi.deleteInstitution(institutionId: institution.institutionId, completion: nil)
        }
        
        close()
    }
    
    //
    // MARK: - Connecting -
    //
    
    

    //
    // MARK: - NSTabViewDelegate -
    //

    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        guard let tabViewItem = tabViewItem else {
            return
        }
        
        var explanation: String?
        switch tabView.indexOfTabViewItem(tabViewItem) {
        case 0:
            explanation = "We do not store your login information on your Mac or on our servers. We use Plaid.com, a service which provides infrastructure to companies like Venmo and PayPal.\n\nYour details are sent directly and securely to them. Plaid makes a copy of your transaction history and then gives Balance read-only access to that information. We cannot log in to your online bank or move your money.\n\nWe will never sell your data to third parties or use it to recommend financial products to you."
        case 1:
            explanation = "Your login information is sent using SSL to Plaid's API. They have direct integrations with several banks and have partnered with Intuit to access a long tail of thousands of institutions. Plaid retrieves as much transaction history as possible and gives us a read-only access token.\n\nWe store this token on your Mac's keychain, and Balance downloads the transactions directly to your machine. We also store the token on our subscription server to allow syncing accounts between your devices, and so that we can sever Plaid's connection if you cancel your subscription."
        case 2:
            explanation = "Balance is a closed-source application which we sell to cover the cost of data and development. Therefore, we cannot open source all the code for you to look through. However, we have been working on Plaidster, an open source library written in Swift for working with Plaid's API. You can see the code here:\n\nhttps://github.com/balancemymoney/Plaidster\n\nHere you can see how we handle bank credentials and pass them directly to Plaid without storing them."// If you find any security holes, please email bounty@balancemy.money."  // <-- I like this but let's figure out details on the program first before mentioning it
        default:
            break
        }
        
        if let explanation = explanation {
            //explanationField.attributedStringValue = createHtmlAttributedString(string: explanation, font: NSFont.systemFontOfSize(12), color: CurrentTheme.defaults.foregroundColor)
            explanationField.stringValue = explanation
        }
    }
    
    //
    // MARK: - WebView Delegate -
    //
    
    func webViewDecidePolicy(actionInformation: [AnyHashable : Any]!, request: URLRequest!, decisionListener listener: WebPolicyDecisionListener!) {
        if source == .plaid {
            guard let url = actionInformation[WebActionOriginalURLKey] as? URL, let navigationTypeId = actionInformation[WebActionNavigationTypeKey] as? Int, let navigationType = WebNavigationType(rawValue: navigationTypeId) else {
                print("No url or missing navigation type: \(actionInformation)")
                listener.use()
                return
            }
            
            let linkScheme = "plaidlink"
            let actionScheme = url.scheme
            let actionType = url.host
            let queryParams = url.queryParameters
            
            if (actionScheme == linkScheme) {
                switch actionType {
                    
                case "connected"?:
                    if let publicToken = queryParams["public_token"] {
                        subscriptionManager.plaidExchangePublicToken(sourceInstitutionId: sourceInstitutionId, publicToken: publicToken)
                        
                        // Close the webview
                        self.finished()
                    } else {
                        // TODO: Present an error
                        self.cancel()
                    }
                case "exit"?:
                    // NOTE: We hide the html close button, so this should never happen unless they change their HTML
                    // Close the webview
                    self.cancel()
                default:
                    print("Link action detected: \(actionType ?? "")")
                    break
                }
                
                listener.ignore()
            } else if navigationType == .linkClicked && (actionScheme == "http" || actionScheme == "https") {
                // Handle http:// and https:// links inside of Plaid Link,
                // and open them in a new Safari page. This is necessary for links
                // such as "forgot-password" and "locked-account"
                _ = try? NSWorkspace.shared.open(url, options: [], configuration: [:])
                listener.ignore()
            } else {
                print("Unrecognized URL scheme detected that is neither HTTP, HTTPS, or related to Plaid Link: \(url.absoluteString)")
                listener.use()
            }
        } else {
            listener.use()
        }
    }
    
    func webView(_ webView: WebView!, decidePolicyForNavigationAction actionInformation: [AnyHashable : Any]!, request: URLRequest!, frame: WebFrame!, decisionListener listener: WebPolicyDecisionListener!) {
        webViewDecidePolicy(actionInformation: actionInformation, request: request, decisionListener: listener)
    }
    
    func webView(_ webView: WebView!, decidePolicyForNewWindowAction actionInformation: [AnyHashable : Any]!, request: URLRequest!, newFrameName frameName: String!, decisionListener listener: WebPolicyDecisionListener!) {
        webViewDecidePolicy(actionInformation: actionInformation, request: request, decisionListener: listener)
    }
    
    func webView(_ webView: WebView!, didCreateJavaScriptContext context: JSContext!, for frame: WebFrame!) {
        if source == .plaid {
            context.evaluateScript("document.documentElement.style.zoom = \"0.80\"")
        }
    }
    
    func webView(_ sender: WebView!, didFinishLoadFor frame: WebFrame!) {
        if source == .plaid {
            if let domDocument = webView.mainFrameDocument, let styleElement = domDocument.createElement("style") {
                styleElement.setAttribute("type", value: "text/css")
                
                // Hide the close button in the top right corner since we have our own back button
                let hideCloseButton = domDocument.createTextNode(".Navbar__button--is-right{width:0px;height:0px;} ")
                styleElement.appendChild(hideCloseButton)
                
                // Prevent elastic scrolling so that we don't see white behind the background color
                let preventOverscroll = domDocument.createTextNode("html{height:100%;width:100%;overflow:hidden;} body{height:100%;padding:0;overflow:auto;margin:0;-webkit-overflow-scrolling:touch;}")
                styleElement.appendChild(preventOverscroll)
                
                if let headElement = domDocument.getElementsByTagName("head")?.item(0) {
                    headElement.appendChild(styleElement)
                }
            }
        }
    }
}
