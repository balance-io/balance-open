//
//  SignUpViewController.swift
//  Bal
//
//  Created by Benjamin Baron on 2/24/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Cocoa
import QuartzCore
import BalanceVectorGraphics

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
    var field: Field? {
        guard let fieldType = FieldType(rawValue: type.rawValue) else {
            return nil
        }
        
        let value = textField.stringValue
        switch self.type {
        case .none:
            return Field(name: type.rawValue, type: fieldType, value: nil)
        default:
            return Field(name: type.rawValue, type: fieldType, value: value)
        }
    }
}

class SignUpViewController: NSViewController {
    
    fileprivate let errorTextColor = NSColor(deviceRedInt: 243, green: 191, blue: 107)
    
    //
    // MARK: - Properties -
    //
    
    fileprivate var institution: Institution?
    
    fileprivate let apiInstitution: ApiInstitution
    fileprivate let patch: Bool
    fileprivate let closeBlock: (_ finished: Bool, _ signUpController: SignUpViewController) -> Void
    
    fileprivate var primaryColor = NSColor.gray
    fileprivate let margin = 20
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
    fileprivate var deviceButtons = [NSButton]()
    fileprivate var devices = [Device]()
    
    fileprivate let institutionLogoField = ImageView()
    fileprivate let institutionNameField = LabelField()
    
    fileprivate let loadingFieldScrollView = ScrollView()
    fileprivate let loadingField = LabelField()
    fileprivate var loadingFieldShadow: NSShadow = {
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 1
        shadow.shadowOffset = NSSize(width: 0, height: 0)
        shadow.shadowColor = .black
        return shadow
    }()
    
    fileprivate let helpButton = Button()
    fileprivate let backButton = Button()
    fileprivate let onePasswordButton = Button()
    fileprivate let spinner = YRKSpinningProgressIndicator()
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
        return 150.0 + (CGFloat(apiInstitution.fields.count) * (CurrentTheme.addAccounts.signUpFieldHeight + CurrentTheme.addAccounts.signUpFieldSpacing))
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
        self.primaryColor = apiInstitution.source.color
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
        self.view.layerBackgroundColor = primaryColor
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
        
        institutionNameField.stringValue = apiInstitution.name
        institutionNameField.font = CurrentTheme.addAccounts.institutionNameFont
        institutionNameField.textColor = CurrentTheme.addAccounts.textColor
        institutionNameField.alignment = .center
        institutionNameField.usesSingleLineMode = true
        institutionNameField.cell?.lineBreakMode = .byTruncatingTail
        containerView.addSubview(institutionNameField)
        institutionNameField.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(margin)
            make.right.equalToSuperview().inset(margin)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(30)
        }
        
        backButton.isBordered = false
        backButton.image = #imageLiteral(resourceName: "addAccountBackArrow")
        backButton.imagePosition = .imageOnly
        backButton.target = self
        backButton.action = #selector(cancel)
        containerView.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.height.equalTo(25)
            make.width.equalTo(25)
            make.left.equalToSuperview().offset(10)
            make.centerY.equalTo(institutionNameField)
        }
        
        if let logo = apiInstitution.source.signUpLogo {
            institutionLogoField.isHidden = false
            institutionNameField.isHidden = true
            institutionLogoField.image = logo
            containerView.addSubview(institutionLogoField)
            institutionLogoField.snp.makeConstraints { make in
                make.width.equalTo(logo.size.width)
                make.height.equalTo(logo.size.height)
                make.centerX.equalToSuperview()
                make.centerY.equalTo(institutionNameField)
            }
        } else {
            institutionLogoField.isHidden = true
            institutionNameField.isHidden = false
        }
        
        line.layerBackgroundColor = CurrentTheme.addAccounts.lineColor
        containerView.addSubview(line)
        line.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(institutionNameField.snp.bottom).offset(10)
        }
        
        loadingFieldScrollView.frame.size.height = 25
        loadingFieldScrollView.hasVerticalScroller = true
        loadingFieldScrollView.hasHorizontalScroller = false
        loadingFieldScrollView.documentView = loadingField
        containerView.addSubview(loadingFieldScrollView)
        loadingFieldScrollView.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.top.equalTo(line.snp.bottom).offset(4)
            make.left.equalToSuperview().inset(margin)
            make.right.equalToSuperview().inset(margin)
        }
        
        loadingField.drawsBackground = false
        loadingField.isHidden = false
        setLoadingFieldString("")
        loadingField.alignment = .center
        loadingField.usesSingleLineMode = false
        loadingField.font = CurrentTheme.addAccounts.labelFont
        loadingField.textColor = CurrentTheme.addAccounts.textColor
        loadingField.sizeToFit()
        loadingField.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        displayConnectFields()
        
        helpButton.bezelStyle = .rounded
        helpButton.font = CurrentTheme.addAccounts.buttonFont
        helpButton.title = "Help"
        helpButton.sizeToFit()
        helpButton.target = self
        helpButton.action = #selector(help)
        containerView.addSubview(helpButton)
        helpButton.snp.makeConstraints { make in
            make.height.equalTo(25)
            make.left.equalToSuperview().offset(margin)
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
            make.right.equalToSuperview().inset(margin)
            if let last = connectFields.last {
                make.top.equalTo(last.snp.bottom).offset(25)
            } else {
                make.top.equalTo(loadingFieldScrollView.snp.bottom).offset(25)
            }
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
        spinner.color = .white
        spinner.isDisplayedWhenStopped = false
        spinner.usesThreadedAnimation = false
        containerView.addSubview(spinner)
        spinner.snp.makeConstraints { make in
            make.height.equalTo(15)
            make.width.equalTo(15)
            make.centerX.equalToSuperview()
            make.centerY.equalTo(submitButton)
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
            make.left.equalToSuperview().offset(margin)
            make.right.equalTo(reportFailureButton.snp.left).offset(-10)
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
    
    //show the fields
    fileprivate func displayConnectFields() {
        var previousTextField: SignUpTextField?
        for field in apiInstitution.fields {
            let type: SignUpTextFieldType
            switch field.type {
            case .passphrase: type = .passphrase
            case .key:        type = .key
            case .secret:     type = .secret
            case .name:       type = .name
            case .address:    type = .address
            }
            
            let textField = SignUpTextField(type: type)
            textField.delegate = self
            textField.alphaValue = 1.0
            containerView.addSubview(textField)
            textField.placeholderString = field.name
            textField.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(margin)
                make.right.equalToSuperview().offset(-margin)
                make.height.equalTo(CurrentTheme.addAccounts.signUpFieldHeight)
                if let previousTextField = previousTextField {
                    make.top.equalTo(previousTextField.snp.bottom).offset(CurrentTheme.addAccounts.signUpFieldSpacing)
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
                          "Error Description": errorDescription]
        log.error("Connection Failed: \(attributes)")
    }
    
    fileprivate func allFieldsFilled() -> Bool {
        var filled = true
        for textField in connectFields {
            if textField.stringValue.count == 0 {
                filled = false
                break
            }
        }
        
        return filled
    }
    
    // NOTE: Do not call directly, use close, cancel, or finished instead
    fileprivate func callCloseBlock(finished: Bool) {
        AppDelegate.sharedInstance.statusItem.arrowColor = NSColor.clear
        closeBlock(finished, self)
    }
    
    @objc fileprivate func close() {
        callCloseBlock(finished: false)
    }
    
    @objc fileprivate func finished() {
        callCloseBlock(finished: true)
    }
    
    @objc fileprivate func cancel() {
        log.info("user presssed cancel")
        
        close()
    }
    
    @objc fileprivate func openOnePassword() {
        let nameComponents = apiInstitution.name.components(separatedBy: " ")
        let name = nameComponents.first ?? apiInstitution.name
        let url = URL(string: "onepassword://search/\(name.URLQueryStringEncodedValue)") ?? URL(string: "onepassword://search/")!
        NSWorkspace.shared.open(url)
    }
        
    @objc private func help() {
        NSWorkspace.shared.open(apiInstitution.source.helpUrl)
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
            if let field = textField.field {
                loginFields.append(field)
            }
        }
        // try login with loginFields
        loginService.authenticationChallenge(loginStrings: loginFields, existingInstitution: institution) { success, error, institution in
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
                self.setLoadingFieldString("\(initialText). Slower than usual...")
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
        let userInfo = Notifications.userInfoForInstitution(institution)
        let notificationName = patch ? Notifications.InstitutionPatched : Notifications.InstitutionAdded
        NotificationCenter.postOnMainThread(name: notificationName, object: nil, userInfo: userInfo)
        
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
        for textField in connectFields {
            textField.isEnabled = false
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
        
        return false
    }
    
    func handleBackTabKey(_ currentField: NSTextField) -> Bool {
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
        
        return false
    }
}

fileprivate extension Source {
    var signUpLogo: NSImage? {
        switch self {
        case .coinbase: return #imageLiteral(resourceName: "coinbaseSignup")
        case .poloniex: return #imageLiteral(resourceName: "poloniexSignup")
        case .gdax:     return #imageLiteral(resourceName: "gdaxSignup")
        case .bitfinex: return #imageLiteral(resourceName: "bitfinexSignup")
        case .kraken:   return #imageLiteral(resourceName: "krakenSignup")
        case .bittrex:  return #imageLiteral(resourceName: "bittrexSignup")
        default:        return nil
        }
    }
}
