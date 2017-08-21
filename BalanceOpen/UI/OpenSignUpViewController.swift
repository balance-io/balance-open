//
//  OpenSignUpViewController.swift
//  Bal
//
//  Created by Benjamin Baron on 2/24/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Cocoa

protocol InstitutionWrapper {
    var currencyCode: String {get set}
    var usernameLabel: String {get set}
    var passwordLabel: String {get set}
    
    var name: String {get set}
    var products: [String] {get set}
    
    var type: String {get set}
    var url: String? {get set}
    
    var fields: [OpenField] {get set}
}

private enum OpenFieldType: String {
    case username   = "username"
    case password   = "password"
    case pin        = "pin"
    case key        = "key"
    case secret     = "secret"
    case passphrase = "passphrase"
}

private enum Step: String {
    case connect    = "connect"
    case question   = "question"
    case deviceList = "deviceList"
    case codeEntry  = "codeEntry"
}

// TODO: Make this and the == overload private again once the LLDB bug is fixed
// http://stackoverflow.com/questions/38357114/unable-to-use-swift-debugger-in-one-particular-class-file
struct Device: Hashable {
    let type: String
    let mask: String
    
    var hashValue: Int {
        return type.hashValue ^ mask.hashValue
    }
}

func ==(lhs: Device, rhs: Device) -> Bool {
    return lhs.type == rhs.type && lhs.mask == rhs.mask
}

class OpenSignUpViewController: NSViewController {
    
    fileprivate let errorTextColor = NSColor(deviceRedInt: 243, green: 191, blue: 107)
    
    //
    // MARK: - Properties -
    //
    
    fileprivate var currentStep = Step.connect
    fileprivate var institution: Institution?
    
    fileprivate let plaidInstitution: InstitutionWrapper
    fileprivate let patch: Bool
    fileprivate let closeBlock: (_ finished: Bool, _ signUpController: OpenSignUpViewController) -> Void
    
    fileprivate var primaryColor = NSColor.gray
    fileprivate let margin = 25
    fileprivate var emailIssueController: OpenEmailIssueController?
    fileprivate var lastPlaidErrorCode = -1
    fileprivate var connectionFailures = 0 {
        didSet {
            if connectionFailures == 0 {
                DispatchQueue.main.async {
                    self.hideReportFailureButton()
                }
            } else if connectionFailures > 0 {
                DispatchQueue.main.async {
                    self.showReportFailureButton()
                }
            }
        }
    }
    
    fileprivate let containerView = View()
    
    fileprivate var connectFields = [OpenSignUpTextField]() // These match the order of plaidInstitution.fields
    fileprivate var questionField = OpenSignUpTextField(type: .mfaAnswer)
    fileprivate var deviceButtons = [NSButton]()
    fileprivate var devices = [Device]()
    fileprivate var codeField = OpenSignUpTextField(type: .mfaCode)
    
    fileprivate let institutionNameField = LabelField()
    
    fileprivate let titleField = LabelField()
    
    fileprivate let loadingFieldScrollView = ScrollView()
    fileprivate let loadingField = LabelField()
    fileprivate var loadingFieldShadow: NSShadow = {
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 1
        shadow.shadowOffset = NSSize(width: 0, height: 0)
        shadow.shadowColor = .black
        return shadow
    }()
    
    fileprivate let backButton = Button()
    fileprivate let onePasswordButton = Button()
    fileprivate let spinner = NSProgressIndicator()
    fileprivate let line = View()
    fileprivate let submitButton = Button()
    
    fileprivate let reportFailureField = LabelField()
    fileprivate let reportFailureButton = Button()
    
    fileprivate let lock = ImageView()
    fileprivate let reassuranceField = LabelField()
    fileprivate let expandedExplanationButton = Button()
    
    fileprivate let explanationTabView = NSTabView()
    fileprivate let explanationField = LabelField()
    fileprivate let explanationImage = ImageView()
    
    fileprivate var showingExplanation: Bool {
        return expandedExplanationButton.state == NSControl.StateValue.onState
    }
    fileprivate let loginService: ExchangeApi
    
    fileprivate var showOnePasswordButton: Bool {
        // Check for 1password
        let bundleIds = ["com.agilebits.onepassword-osx", "com.agilebits.onepassword4"]
        for id in bundleIds {
            if NSWorkspace.shared.absolutePathForApplication(withBundleIdentifier: id) != nil {
                return true
            }
        }
        
        let appNames = ["1Password", "1Password 6"]
        for name in appNames {
            if NSWorkspace.shared.fullPath(forApplication: name) != nil {
                return true
            }
        }
        
        return false
    }
    
    fileprivate var height: CGFloat {
        switch currentStep {
        case .connect:
            let placeholderFor3Fields = 3
            return 270.0 + (CGFloat(placeholderFor3Fields/*plaidInstitution.fields.count*/) * 45.0) + (showingExplanation ? 240.0 : 0.0)
        case .question, .codeEntry:
            return 315.0 + (showingExplanation ? 240.0 : 0.0)
        case .deviceList:
            return 295.0 + (CGFloat(devices.count - 1) * 33.0) + (showingExplanation ? 240.0 : 0.0)
        }
    }
    
    //
    // MARK: - Lifecycle -
    //
    
    init(plaidInstitution: InstitutionWrapper, patch: Bool = false, institution: Institution? = nil, loginService: ExchangeApi, closeBlock: @escaping (_ finished: Bool, _ signUpViewController: OpenSignUpViewController) -> Void) {
        self.plaidInstitution = plaidInstitution
        self.closeBlock = closeBlock
        self.patch = patch
        self.institution = institution
        self.loginService = loginService
        log.info("Opened sign up controller for \(plaidInstitution.type): \(plaidInstitution.name)")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    deinit {
//        subscriptionManager.isShowingSignUpController = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        subscriptionManager.isShowingSignUpController = true
        
        onePasswordButton.isHidden = !showOnePasswordButton
        
        let firstItem = explanationTabView.tabViewItems[0]
        explanationTabView.selectTabViewItem(firstItem)
        
        // For some reason (probably AppKit bug), the delegate is not getting called when we call
        // selectTabViewItemAtIndex, so we have to call it manually
        self.tabView(explanationTabView, didSelect: firstItem)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        // Hack to color the popover arrow during the push animation
        DispatchQueue.main.async(after: 0.1) {
            AppDelegate.sharedInstance.statusItem.arrowColor = self.primaryColor
            
            // Must resize after changing the color or the color changes too late
            DispatchQueue.main.async {
                AppDelegate.sharedInstance.resizeWindowHeight(self.height, animated: true)
                
                DispatchQueue.main.async(after: 0.5) {
                    self.explanationTabView.isHidden = false
                }
            }
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        DispatchQueue.main.async(after: 0.3) {
            _ = self.connectFields.first?.becomeFirstResponder()
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
        
        if let institutionColor = institution?.primaryColor {
            primaryColor = institutionColor
        }
        
        let brandHeaderView = View()
        let brandBackgroundLayer = CAGradientLayer()
        brandBackgroundLayer.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
        brandBackgroundLayer.colors = [NSColor.clear.cgColor, primaryColor.cgColor]
        brandBackgroundLayer.locations = [0.0, 0.9]
        brandHeaderView.layer?.addSublayer(brandBackgroundLayer)
        containerView.addSubview(brandHeaderView)
        brandHeaderView.snp.makeConstraints { make in
            make.height.equalTo(400)
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        let waves = ImageView()
        waves.image = CurrentTheme.addAccounts.waveImage
        containerView.addSubview(waves)
        waves.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(72)
            make.centerX.equalToSuperview()
        }
        
        institutionNameField.stringValue = plaidInstitution.name
        institutionNameField.font = CurrentTheme.addAccounts.institutionNameFont
        institutionNameField.textColor = CurrentTheme.defaults.foregroundColor
        //institutionNameField.textColor = primaryColor.brightnessComponent > 0.90 ? NSColor.black : NSColor.white
        institutionNameField.textColor = CurrentTheme.addAccounts.textColor
        institutionNameField.alignment = .center
        institutionNameField.usesSingleLineMode = true
        institutionNameField.cell?.lineBreakMode = .byTruncatingTail
        containerView.addSubview(institutionNameField)
        institutionNameField.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(margin)
            make.trailing.equalToSuperview().inset(margin)
            make.top.equalToSuperview().inset(23)
            make.height.equalTo(30)
        }
        
        titleField.stringValue = "Connect your account"
        titleField.font = CurrentTheme.addAccounts.welcomeFont
        titleField.textColor = CurrentTheme.addAccounts.textColor
        titleField.alignment = .center
        titleField.usesSingleLineMode = true
        containerView.addSubview(titleField)
        titleField.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.leading.equalToSuperview().inset(margin)
            make.trailing.equalToSuperview().inset(margin)
            make.top.equalToSuperview().inset(55)
        }
        
        loadingFieldScrollView.frame.size.height = 60
        loadingFieldScrollView.hasVerticalScroller = true
        loadingFieldScrollView.hasHorizontalScroller = false
        loadingFieldScrollView.documentView = loadingField
        containerView.addSubview(loadingFieldScrollView)
        loadingFieldScrollView.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.top.equalTo(titleField.snp.bottom).offset(5)
            make.leading.equalToSuperview().inset(margin)
            make.trailing.equalToSuperview().inset(margin)
        }
        
        loadingField.drawsBackground = false
        loadingField.isHidden = false
        // TODO: Remove this hack for PayPal issues
        if plaidInstitution.type == "ins_100020" {
            setLoadingFieldString("If unsuccessful, please try again in 24 to 48 hours")
        } else {
            setLoadingFieldString("Please enter your credentials")
        }
        loadingField.alignment = .center
        loadingField.usesSingleLineMode = false
        loadingField.font = CurrentTheme.addAccounts.labelFont
        loadingField.textColor = CurrentTheme.addAccounts.textColor
        loadingField.sizeToFit()
        //containerView.addSubview(loadingField)
        loadingField.snp.makeConstraints { make in
            //make.height.equalTo(60)
            make.top.equalToSuperview()//(titleField.snp.bottom).offset(5)
            make.leading.equalToSuperview()//.inset(margin)
            make.trailing.equalToSuperview()//.inset(margin)
        }
        
        displayConnectFields()
        
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
            if let last = connectFields.last {
                make.top.equalTo(last.snp.bottom).offset(25)
            } else {
                make.top.equalTo(loadingFieldScrollView.snp.bottom).offset(25)
            }
        }
    
        submitButton.bezelStyle = .rounded
        submitButton.font = CurrentTheme.addAccounts.buttonFont
        submitButton.isEnabled = false
        submitButton.title = "Connect"
        submitButton.sizeToFit()
        submitButton.target = self
        submitButton.action = #selector(connect)
        containerView.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.height.equalTo(25)
            make.trailing.equalToSuperview().inset(margin)
            make.top.equalTo(backButton)
        }
        
        onePasswordButton.bezelStyle = .texturedSquare
        onePasswordButton.alphaValue = 0.6
        onePasswordButton.title = ""
        let onePasswordButtonImage = CurrentTheme.addAccounts.onePasswordButtonImage
        onePasswordButtonImage.size = NSSize(width: 18, height: 18)
        onePasswordButton.image = onePasswordButtonImage
        onePasswordButton.imagePosition = .imageOnly
        onePasswordButton.isBordered = false
        onePasswordButton.sizeToFit()
        onePasswordButton.target = self
        onePasswordButton.action = #selector(openOnePassword)
        containerView.addSubview(onePasswordButton)
        onePasswordButton.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.centerY.equalTo(submitButton)
            make.centerX.equalToSuperview()
        }
        onePasswordButton.sizeToFit()
        
        spinner.wantsLayer = true
        spinner.alphaValue = 0.6
        spinner.style = .spinning
        spinner.isDisplayedWhenStopped = false
        containerView.addSubview(spinner)
        spinner.snp.makeConstraints { make in
            make.height.equalTo(15)
            make.width.equalTo(15)
            make.centerX.equalToSuperview()
            make.centerY.equalTo(submitButton)
        }
        
        line.layerBackgroundColor = CurrentTheme.addAccounts.lineColor
        containerView.addSubview(line)
        line.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(backButton.snp.bottom).offset(20)
        }
        
        let offsetColor = View()
        offsetColor.layerBackgroundColor = CurrentTheme.defaults.foregroundColor
        offsetColor.alphaValue = 0.04
        containerView.addSubview(offsetColor)
        offsetColor.snp.makeConstraints{ make in
            make.top.equalTo(line.snp.bottom).offset(0)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        lock.image = CurrentTheme.addAccounts.padlockImage
        lock.alphaValue = 0.9
        containerView.addSubview(lock)
        lock.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.width.equalTo(24)
            make.top.equalTo(line.snp.bottom).inset(-14)
            make.leading.equalToSuperview().inset(margin)
        }
        
        expandedExplanationButton.bezelStyle = .roundedDisclosure
        expandedExplanationButton.setButtonType(.pushOnPushOff)
        expandedExplanationButton.state = NSControl.StateValue.offState
        expandedExplanationButton.title = ""
        expandedExplanationButton.target = self
        expandedExplanationButton.action = #selector(toggleExplanation)
        containerView.addSubview(expandedExplanationButton)
        expandedExplanationButton.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.width.equalTo(20)
            make.centerY.equalTo(lock)
            make.trailing.equalToSuperview().inset(19)
        }
        
        //reassuranceField.attributedStringValue = createHtmlAttributedString(string: "Balance uses the industry-standard banking data service from <a href='https://plaid.com/security'>Plaid.com</a> to protect your login details.", font: NSFont.systemFontOfSize(12), color: CurrentTheme.defaults.foregroundColor)
        reassuranceField.stringValue = "Balance uses a secure bank service. Learn More"
        reassuranceField.allowsEditingTextAttributes = true
        reassuranceField.isSelectable = true
        reassuranceField.isEnabled = false
        reassuranceField.alignment = .center
        reassuranceField.lineBreakMode = .byWordWrapping
        reassuranceField.alphaValue = 0.75
        containerView.addSubview(reassuranceField)
        reassuranceField.snp.makeConstraints { make in
            make.leading.equalTo(lock.snp.trailing).inset(-10)
            make.trailing.equalTo(expandedExplanationButton.snp.leading).inset(-10)
            make.top.equalTo(line.snp.bottom).inset(-16)
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
            make.leading.equalToSuperview().inset(15)
            make.trailing.equalToSuperview().inset(15)
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
        DispatchQueue.main.async {
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
            make.centerY.equalTo(lock)
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
            make.top.equalTo(line.snp.bottom).offset(16)
            make.height.equalTo(30)
        }
        
        DispatchQueue.main.async(after: 0.5) {
            if self.expandedExplanationButton.state == NSControl.StateValue.onState {
                self.expandedExplanationButton.state = NSControl.StateValue.offState
                self.toggleExplanation()
            }
            
            self.lock.alphaValue = 0.0
            
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
        
        lock.alphaValue = 1.0
        reassuranceField.alphaValue = 0.75
        expandedExplanationButton.alphaValue = 1.0
    }
    
    fileprivate func generatePlaceholder(field: OpenField) -> String {
        let lowercaseLabel = field.label.lowercased()
        if lowercaseLabel == "account number/userid" {
            return "Account Number or User ID"
        } else if lowercaseLabel == "account number" {
            return "02610642"
        } else if lowercaseLabel.contains("email") {
            return "Email"
        } else if lowercaseLabel.contains("password") {
            return "Password"
        } else if lowercaseLabel.contains("pin") {
            return "PIN"
        } else if lowercaseLabel.contains("user") || lowercaseLabel.contains("id") {
            return "User ID"
        } else {
            if let type = OpenFieldType(rawValue: field.type) {
                switch type {
                case .username: return "User ID"
                case .password: return "Password"
                case .pin: return "PIN"
                case .passphrase: return "Passphrase"
                case .key: return "Key"
                case .secret: return "Secret"
                }
            } else {
                return ""
            }
        }
    }
    
    //show the fields
    fileprivate func displayConnectFields() {
        var previousTextField: OpenSignUpTextField?
        for field in plaidInstitution.fields {
            var type: SignUpTextFieldType = .username
            if field.type == OpenFieldType.username.rawValue {
                type = .username
            } else if field.type == OpenFieldType.password.rawValue {
                type = .password
            } else if field.type == OpenFieldType.pin.rawValue {
                type = .pin
            } else if field.type == OpenFieldType.passphrase.rawValue {
                type = .passphrase
            } else if field.type == OpenFieldType.key.rawValue {
                type = .key
            } else if field.type == OpenFieldType.secret.rawValue {
                type = .secret
            }
            
            let textField = OpenSignUpTextField(type: type)
            textField.delegate = self
            textField.alphaValue = 0.9
            containerView.addSubview(textField)
            textField.placeholderString = generatePlaceholder(field: field)
            textField.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(margin)
                make.trailing.equalToSuperview().offset(-margin)
                make.height.equalTo(30)
                if let previousTextField = previousTextField {
                    make.top.equalTo(previousTextField.snp.bottom).offset(15)
                } else {
                    make.top.equalTo(loadingFieldScrollView.snp.bottom).offset(10)
                }
            }
            
            connectFields.append(textField)
            previousTextField?.nextKeyView = textField
            previousTextField = textField
        }
        
        submitButton.action = #selector(connect)
        
        _ = connectFields.first?.becomeFirstResponder()        
    }
    
    fileprivate func removeConnectFields() {
        for textField in connectFields {
            textField.removeFromSuperview()
        }
        connectFields.removeAll()
        submitButton.action = nil
    }

    fileprivate func createHtmlAttributedString(string: String, font: NSFont, color: NSColor) -> NSAttributedString {
        if let hexColor = color.hexString {
            let finalHtml = "<span style=\"font-family:'\(font.fontName)'; font-size:\(Int(font.pointSize))px; color:\(hexColor);\">\(string)</span>"
            
            if let data = finalHtml.data(using: String.Encoding.utf8) {
                var attributedString: NSAttributedString?
                do {
                    attributedString =  try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.fileType: NSAttributedString.DocumentType.html, NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
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
        guard emailIssueController == nil else {
            return
        }
        
        // Hack so that explanationTabView doesn't show while resizing
        explanationTabView.isHidden = true
        
        emailIssueController = OpenEmailIssueController(plaidInstitution: plaidInstitution, plaidErrorCode: lastPlaidErrorCode) {
            self.removeEmailIssueController()
            self.hideReportFailureButton()
        }
        
        if let emailIssueController = emailIssueController {
            self.view.replaceSubview(containerView, with: emailIssueController.view, animation: .slideInFromRight)
        }
    }
    
    fileprivate func removeEmailIssueController() {
        if let emailIssueController = emailIssueController {
            // Hack to color the popover arrow during the push animation
            DispatchQueue.main.async(after: 0.1) {
                AppDelegate.sharedInstance.statusItem.arrowColor = self.primaryColor
                
                // Must resize after changing the color or the color changes too late
                DispatchQueue.main.async {
                    AppDelegate.sharedInstance.resizeWindowHeight(self.height, animated: true)
                    
                    DispatchQueue.main.async(after: 0.5) {
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
        let attributes = ["Institution Type":  plaidInstitution.type,
                          "Institution name":  plaidInstitution.name,
                          "Step":              currentStep.rawValue,
                          "Error Description": errorDescription]
        log.error("Connection Failed: \(attributes)")
    }
    
    fileprivate func allFieldsFilled() -> Bool {
        var textFields = [OpenSignUpTextField]()
        switch currentStep {
        case .connect: textFields = connectFields
        case .question: textFields = [questionField]
        case .codeEntry: textFields = [codeField]
        default: break
        }
        
        var filled = true
        for textField in textFields {
            if textField.stringValue.length == 0 {
                filled = false
                break
            }
        }
        
        return filled
    }
    
    fileprivate func callCloseBlock(finished: Bool) {
        // Hack to color the popover arrow during the push animation
        DispatchQueue.main.async(after: 0.12) {
            AppDelegate.sharedInstance.statusItem.arrowColor = NSColor.clear
            
            // Must resize after changing the color or the color changes too late
            DispatchQueue.main.async(after: 0.1) {
                AppDelegate.sharedInstance.resizeWindow(CurrentTheme.defaults.size, animated: true)
            }
        }
        
        closeBlock(false, self)
    }
    
    @objc fileprivate func close() {
        callCloseBlock(finished: false)
    }
    
    @objc fileprivate func finished() {
        if !patch {
            if let institutionId = institution?.institutionId {
//                defaults.removeUnfinishedConnectionInstitutionId(institutionId)
            }
            
            // TODO: Do this a different way
            // Update the last new institution time so syncs happen faster
//            syncManager.syncDefaults.lastNewInstitutionAddedTime = Date()
            
            // If this is a brand new install, sync categories right away
//            if Category.allCategoryNames().count == 0 {
//                plaidApi.pullCategories()
//            }
        }
        
        callCloseBlock(finished: true)
    }
    
    @objc fileprivate func cancel() {
        if !patch, let institution = institution {
//            plaidApi.removeUser(institutionId: institution.institutionId, completion: nil)
        }
        log.severe("user presssed cancel")
        
        close()
    }
    
    @objc fileprivate func openOnePassword() {
        let nameComponents = plaidInstitution.name.components(separatedBy: " ")
        let name = nameComponents.first ?? plaidInstitution.name
        let url = URL(string: "onepassword://search/\(name.URLQueryStringEncodedValue)") ?? URL(string: "onepassword://search/")!
        NSWorkspace.shared.open(url)
    }
    
    //
    // MARK: - Connecting -
    //
    
    //TODO: 4) on sucess, move away and show normal screen -> problem screen crashing due to wrong thread call
    
    // Initial connection
    @objc fileprivate func connect() {
        guard allFieldsFilled() else {
            return
        }
        
        var loginFields = [OpenField]()
        for field in self.connectFields {
            loginFields.append(field.signupFieldToOpenField())
        }
        // try login with loginFields
        self.loginService.authenticationChallenge(loginStrings: loginFields, closeBlock: { (success) in
            self.callCloseBlock(finished: success)
        })
    }
    
    fileprivate func setLoadingFieldString(_ stringValue: String) {
        loadingField.stringValue = stringValue
        loadingField.sizeToFit()
        let targetSize = NSSize(width: loadingFieldScrollView.frame.size.width, height: CGFloat.greatestFiniteMagnitude)
        let loadingFieldSize = stringValue.size(font: loadingField.font!, targetSize: targetSize)
        
        let showScroller = loadingFieldSize.height > loadingFieldScrollView.frame.size.height
        loadingFieldScrollView.scrollerStyle = showScroller ? .legacy : .overlay
        loadingFieldScrollView.isScrollingEnabled = showScroller
    }
    
    fileprivate var connectStartTime = Date()
    fileprivate var updateConnectLabelWorkItem: DispatchWorkItem?
    fileprivate func autoUpdateConnectLabel(initialText: String) {
        stopAutoUpdatingConnectLabel()
        connectStartTime = Date()
        
        func work() {
            let interval = Date().timeIntervalSince(self.connectStartTime)
            if interval < 15.0 {
                self.setLoadingFieldString(initialText)
            } else if interval < 60.0 {
                self.setLoadingFieldString("\(initialText). Please hang on, this can take a while.")
            } else if interval < 90.0 {
                self.setLoadingFieldString("\(initialText). Almost there...")
            }
        }
        
        work()
        updateConnectLabelWorkItem = DispatchWorkItem {
            work()
            
            if let updateConnectLabelWorkItem = self.updateConnectLabelWorkItem {
                DispatchQueue.main.async(after: 5.0, execute: updateConnectLabelWorkItem)
            }
        }
        
        DispatchQueue.main.async(after: 5.0, execute: updateConnectLabelWorkItem!)
    }
    
    fileprivate func stopAutoUpdatingConnectLabel() {
        updateConnectLabelWorkItem?.cancel()
    }
    
    fileprivate func completeConnect(institution: Institution) {
        stopAutoUpdatingConnectLabel()
        
        connectionFailures = 0
        
        // Success, so close the window
        if !patch {
            let userInfo = Notifications.userInfoForInstitution(institution)
            NotificationCenter.postOnMainThread(name: Notifications.InstitutionAdded, object: nil, userInfo: userInfo)
        }
        
        self.finished()
    }
    
    fileprivate func failConnect(error: Error?) {
        stopAutoUpdatingConnectLabel()
        
        if let error = error! as? NSError {
            lastPlaidErrorCode = error.code
        }
        connectionFailures += 1
        
        // Error, so allow the user to try again
        for textField in self.connectFields {
            textField.isEnabled = true
        }
        backButton.isEnabled = true
        submitButton.isEnabled = true
        spinner.stopAnimation(nil)
        onePasswordButton.isHidden = !showOnePasswordButton
        
        loadingField.textColor = errorTextColor
        loadingField.shadow = loadingFieldShadow
        if let error = error {
            setLoadingFieldString(error.localizedDescription)
        } else {
            setLoadingFieldString("Connecting failed with an unknown error")
        }
        
        submitConnectionFailedEvent(error?.localizedDescription ?? "Unknown error")
        
        // Shake the window
        self.view.window?.shake()
    }
    
    fileprivate func prepareViewsForSubmit(loadingText: String) {
        switch currentStep {
        case .connect:
            for textField in connectFields {
                textField.isEnabled = false
            }
        case .codeEntry:
            codeField.isEnabled = false
        case .deviceList:
            for button in deviceButtons {
                button.isEnabled = false
            }
        case .question:
            questionField.isEnabled = false
        }
        backButton.isEnabled = false
        submitButton.isEnabled = false
        spinner.startAnimation(nil)
        onePasswordButton.isHidden = true
        loadingField.isHidden = false
        loadingField.textColor = CurrentTheme.addAccounts.textColor
        loadingField.shadow = nil
        
        autoUpdateConnectLabel(initialText: loadingText)
    }
    
}

//
// MARK: - NSTextFieldDelegate -
//

extension OpenSignUpViewController: NSTextFieldDelegate {
    override func controlTextDidChange(_ obj: Notification) {
        submitButton.isEnabled = allFieldsFilled()
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if let fieldEditor = self.view.window?.firstResponder as? NSTextView, let currentField = fieldEditor.delegate as? NSTextField {
            if commandSelector == #selector(insertNewline(_:)) || commandSelector == #selector(insertTab(_:)) {
                return handleEnterKey(currentField)
            } else if commandSelector == #selector(insertBacktab(_:)) {
                return handleBackTabKey(currentField)
            }
        }
        
        return false
    }
    
    func handleEnterKey(_ currentField: NSTextField) -> Bool {
        if currentStep == .connect {
            if currentField == connectFields.last?.textField {
                if allFieldsFilled() {
                    connect()
                    return true
                }
            } else {
                let index = connectFields.index { signUpTextField in
                    return signUpTextField.textField == currentField
                }
                if let window = self.view.window, let index = index, connectFields.count > index + 1 {
                    let nextField = connectFields[index + 1]
                    return window.makeFirstResponder(nextField)
                }
            }
        } else if currentStep == .question || currentStep == .codeEntry {
            if allFieldsFilled() {
                submitButton.title = "Submit"
                return true
            }
        }
        
        return false
    }
    
    func handleBackTabKey(_ currentField: NSTextField) -> Bool {
        if currentStep == .connect {
            let index = connectFields.index { signUpTextField in
                return signUpTextField.textField == currentField
            }
            if let window = self.view.window, let index = index, index > 0 {
                let previousField = connectFields[index - 1]
                if window.makeFirstResponder(previousField) {
                    previousField.textField.currentEditor()?.moveToEndOfLine(nil)
                    return true
                }
            }
        }
        
        return false
    }
}

//
// MARK: - NSTabViewDelegate -
//

extension OpenSignUpViewController: NSTabViewDelegate {
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
}
