//
//  SignUpViewController.swift
//  Bal
//
//  Created by Benjamin Baron on 2/24/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Cocoa

private enum FieldType: String {
    case username   = "username"
    case password   = "password"
    case pin        = "pin"
    case key        = "key"
    case secret     = "secret"
    case passphrase = "passphrase"
    case name       = "name"
    case address    = "address"
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

extension SignUpTextField {
    var field: Field {
        let value = textField.stringValue
        switch self.type {
        case .none:
            return Field(name: type.rawValue, label: type.rawValue, type: type.rawValue, value: nil)
        default:
            return Field(name: type.rawValue, label: type.rawValue, type: type.rawValue, value: value)
        }
    }
}

class SignUpViewController: NSViewController {
    
    fileprivate let errorTextColor = NSColor(deviceRedInt: 243, green: 191, blue: 107)
    
    //
    // MARK: - Properties -
    //
    
    fileprivate var currentStep = Step.connect
    fileprivate var institution: Institution?
    
    fileprivate let apiInstitution: ApiInstitution
    fileprivate let patch: Bool
    fileprivate let closeBlock: (_ finished: Bool, _ signUpController: SignUpViewController) -> Void
    
    fileprivate var primaryColor = NSColor.gray
    fileprivate let margin = 25
    fileprivate var emailIssueController: EmailIssueController?
    fileprivate var connectionFailures = 0 {
        didSet {
            if connectionFailures == 0 {
                async {
                    self.hideReportFailureButton()
                }
            } else if connectionFailures > 0 {
                async {
                    self.showReportFailureButton()
                }
            }
        }
    }
    
    fileprivate let containerView = View()
    
    fileprivate var connectFields = [SignUpTextField]() // These match the order of apiInstitution.fields
    fileprivate var questionField = SignUpTextField(type: .mfaAnswer)
    fileprivate var deviceButtons = [NSButton]()
    fileprivate var devices = [Device]()
    fileprivate var codeField = SignUpTextField(type: .mfaCode)
    
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
            return 270.0 + (CGFloat(apiInstitution.fields.count) * 45.0)
        case .question, .codeEntry:
            return 315.0
        case .deviceList:
            return 295.0 + (CGFloat(devices.count - 1) * 33.0)
        }
    }
    fileprivate var previousScreenSize: CGFloat = 0
    
    //
    // MARK: - Lifecycle -
    //
    
    init(apiInstitution: ApiInstitution, patch: Bool = false, institution: Institution? = nil, loginService: ExchangeApi, closeBlock: @escaping (_ finished: Bool, _ signUpViewController: SignUpViewController) -> Void) {
        self.apiInstitution = apiInstitution
        self.closeBlock = closeBlock
        self.patch = patch
        self.institution = institution
        self.loginService = loginService
        log.info("Opened sign up controller for \(apiInstitution.type): \(apiInstitution.name)")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onePasswordButton.isHidden = !showOnePasswordButton
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        // Hack to color the popover arrow during the push animation
        async(after: 0.1) {
            AppDelegate.sharedInstance.statusItem.arrowColor = self.primaryColor
            
            // Must resize after changing the color or the color changes too late
            async {
                AppDelegate.sharedInstance.resizeWindowHeight(self.height, animated: true)
            }
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        async(after: 0.3) {
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
        
        institutionNameField.stringValue = apiInstitution.name
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
        if apiInstitution.type == "ins_100020" {
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
    }
    
    func hideReportFailureButton() {
        guard reportFailureButton.superview != nil else {
            return
        }
        
        reportFailureButton.removeFromSuperview()
        reportFailureField.removeFromSuperview()
    }
    
    fileprivate func generatePlaceholder(field: Field) -> String {
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
            if let type = FieldType(rawValue: field.type) {
                switch type {
                case .username: return "User ID"
                case .password: return "Password"
                case .pin: return "PIN"
                case .passphrase: return "Passphrase"
                case .key: return "Key"
                case .secret: return "Secret"
                case .address: return "Address"
                case .name: return "Name"
                }
            } else {
                return ""
            }
        }
    }
    
    //show the fields
    fileprivate func displayConnectFields() {
        var previousTextField: SignUpTextField?
        for field in apiInstitution.fields {
            var type: SignUpTextFieldType = .username
            if field.type == FieldType.username.rawValue {
                type = .username
            } else if field.type == FieldType.password.rawValue {
                type = .password
            } else if field.type == FieldType.pin.rawValue {
                type = .pin
            } else if field.type == FieldType.passphrase.rawValue {
                type = .passphrase
            } else if field.type == FieldType.key.rawValue {
                type = .key
            } else if field.type == FieldType.secret.rawValue {
                type = .secret
            }else if field.type == FieldType.name.rawValue {
                type = .name
            } else if field.type == FieldType.address.rawValue {
                type = .address
            }
            
            let textField = SignUpTextField(type: type)
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
        
        emailIssueController = EmailIssueController(apiInstitution: apiInstitution) {
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
            async(after: 0.1) {
                AppDelegate.sharedInstance.statusItem.arrowColor = self.primaryColor
                
                // Must resize after changing the color or the color changes too late
                async {
                    AppDelegate.sharedInstance.resizeWindowHeight(self.height, animated: true)
                }
            }
            
            self.view.replaceSubview(emailIssueController.view, with: containerView, animation: .slideInFromLeft) {
                self.emailIssueController = nil
            }
        }
    }
    
    fileprivate func submitConnectionFailedEvent(_ errorDescription: String) {
        let attributes = ["Institution Type":  apiInstitution.type,
                          "Institution name":  apiInstitution.name,
                          "Step":              currentStep.rawValue,
                          "Error Description": errorDescription]
        log.error("Connection Failed: \(attributes)")
    }
    
    fileprivate func allFieldsFilled() -> Bool {
        var textFields = [SignUpTextField]()
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
    
    // NOTE: Do not call directly, use close, cancel, or finished instead
    fileprivate func callCloseBlock(finished: Bool) {
        // Hack to color the popover arrow during the push animation
        async(after: 0.12) {
            AppDelegate.sharedInstance.statusItem.arrowColor = NSColor.clear
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
        let nameComponents = apiInstitution.name.components(separatedBy: " ")
        let name = nameComponents.first ?? apiInstitution.name
        let url = URL(string: "onepassword://search/\(name.URLQueryStringEncodedValue)") ?? URL(string: "onepassword://search/")!
        NSWorkspace.shared.open(url)
    }
    
    //
    // MARK: - Connecting -
    //
    
    // Initial connection
    @objc fileprivate func connect() {
        guard allFieldsFilled() else {
            return
        }
        
        prepareViewsForSubmit(loadingText: "Connecting to \(apiInstitution.name)...")

        var loginFields = [Field]()
        for textField in connectFields {
            loginFields.append(textField.field)
        }
        // try login with loginFields
        loginService.authenticationChallenge(loginStrings: loginFields) { success, error, institution in
            if success, let institution = institution {
                self.completeConnect(institution: institution)
            } else {
                self.failConnect(error: error)
            }
        }
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
                async(after: 5.0, execute: updateConnectLabelWorkItem)
            }
        }
        
        async(after: 5.0, execute: updateConnectLabelWorkItem!)
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
        var submissionDescription = "Connecting failed with an unknown error"
        if let error = error as? LocalizedError, let errorDescription = error.errorDescription {
            submissionDescription = errorDescription
        } else if let error = error {
            submissionDescription = error.localizedDescription
        }
        setLoadingFieldString(submissionDescription)
        
        submitConnectionFailedEvent(submissionDescription)
        
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

extension SignUpViewController: NSTextFieldDelegate {
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
