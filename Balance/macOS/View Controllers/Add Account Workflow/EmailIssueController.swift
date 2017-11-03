//
//  EmailIssueController.swift
//  Bal
//
//  Created by Benjamin Baron on 1/29/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

class EmailIssueController: NSViewController {
    fileprivate let margin = 25
    
    fileprivate let apiInstitution: ApiInstitution?
    fileprivate let errorType: String?
    fileprivate let errorCode: String?
    fileprivate let closeBlock: () -> Void
    
    fileprivate var isConnectionIssue: Bool {
        return apiInstitution != nil
    }
    
    fileprivate let titleLabel = LabelField()
    fileprivate let institutionLabel = LabelField()
    fileprivate let versionLabel = LabelField()
    fileprivate let hardwareLabel = LabelField()
    fileprivate let operatingSystemLabel = LabelField()
    fileprivate let notesField = SignUpTextField(type: .none)
    fileprivate let emailField = SignUpTextField(type: .email)
    fileprivate let messageLabel = LabelField()
    
    fileprivate let backButton = Button()
    fileprivate let submitButton = Button()
    
    fileprivate var isEmailValid: Bool {
        return validateEmail(emailField.stringValue)
    }
    
    init(apiInstitution: ApiInstitution, errorType: String? = nil, errorCode: String? = nil, closeBlock: @escaping () -> Void) {
        self.apiInstitution = apiInstitution
        self.errorType = errorType
        self.errorCode = errorCode
        self.closeBlock = closeBlock
        log.info("Opened send email controller for source \(apiInstitution.source), sourceInstitutionId: \(apiInstitution.sourceInstitutionId)")
        super.init(nibName: nil, bundle: nil)
    }
    
    init(closeBlock: @escaping () -> Void) {
        self.apiInstitution = nil
        self.errorType = nil
        self.errorCode = nil
        self.closeBlock = closeBlock
        log.info("Opened send email controller for feedback")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        // Hack to color the popover arrow during the push animation
        async(after: 0.1) {
            AppDelegate.sharedInstance.statusItem.arrowColor = CurrentTheme.defaults.backgroundColor
            
            // Must resize after changing the color or the color changes too late
            async {
                AppDelegate.sharedInstance.resizeWindowHeight(330, animated: true)
            }
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        self.view.window?.makeFirstResponder(notesField)
    }
    
    override func loadView() {
        self.view = View()
        self.view.layerBackgroundColor = CurrentTheme.defaults.backgroundColor
        self.view.snp.makeConstraints { make in
            make.width.equalTo(CurrentTheme.defaults.size.width)
        }
        
        titleLabel.stringValue = isConnectionIssue ? "Report a connection problem" : "Submit Feedback"
        titleLabel.font = CurrentTheme.addAccounts.welcomeFont
        titleLabel.textColor = CurrentTheme.defaults.foregroundColor
        titleLabel.alignment = .center
        titleLabel.usesSingleLineMode = true
        self.view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.leading.equalToSuperview().offset(margin)
            make.trailing.equalToSuperview().offset(-margin)
            make.top.equalToSuperview().inset(23)
        }
        
        if let name = apiInstitution?.name {
            institutionLabel.attributedStringValue = attributedString(name: "Institution", value: name)
        }
        institutionLabel.alignment = .left
        institutionLabel.verticalAlignment = .center
        institutionLabel.usesSingleLineMode = true
        institutionLabel.cell?.lineBreakMode = .byTruncatingTail
        self.view.addSubview(institutionLabel)
        institutionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(margin)
            make.trailing.equalToSuperview().offset(-margin)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.height.equalTo(isConnectionIssue ? 20 : 0)
        }
        
        versionLabel.attributedStringValue = attributedString(name: "Version", value: appVersionString)
        versionLabel.alignment = .left
        versionLabel.verticalAlignment = .center
        versionLabel.usesSingleLineMode = true
        versionLabel.cell?.lineBreakMode = .byTruncatingTail
        self.view.addSubview(versionLabel)
        versionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(margin)
            make.trailing.equalToSuperview().offset(-margin)
            make.top.equalTo(institutionLabel.snp.bottom)
            make.height.equalTo(20)
        }

        hardwareLabel.attributedStringValue = attributedString(name: "Hardware", value: hardwareModelString)
        hardwareLabel.alignment = .left
        hardwareLabel.verticalAlignment = .center
        hardwareLabel.usesSingleLineMode = true
        hardwareLabel.cell?.lineBreakMode = .byTruncatingTail
        self.view.addSubview(hardwareLabel)
        hardwareLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(margin)
            make.trailing.equalToSuperview().offset(-margin)
            make.top.equalTo(versionLabel.snp.bottom)
            make.height.equalTo(20)
        }
        
        operatingSystemLabel.attributedStringValue = attributedString(name: "Operating System", value: osVersionString)
        operatingSystemLabel.alignment = .left
        operatingSystemLabel.verticalAlignment = .center
        operatingSystemLabel.usesSingleLineMode = true
        operatingSystemLabel.cell?.lineBreakMode = .byTruncatingTail
        self.view.addSubview(operatingSystemLabel)
        operatingSystemLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(margin)
            make.trailing.equalToSuperview().offset(-margin)
            make.top.equalTo(hardwareLabel.snp.bottom)
            make.height.equalTo(20)
        }
        
        notesField.delegate = self
        notesField.layerBackgroundColor = CurrentTheme.defaults.backgroundColor
        notesField.activeBorderColor = CurrentTheme.emailIssue.inputFieldActiveBorderColor
        notesField.inactiveBorderColor = CurrentTheme.emailIssue.inputFieldInactiveBorderColor
        notesField.textColor = CurrentTheme.emailIssue.inputFieldTextColor
        notesField.placeHolderStringColor = CurrentTheme.emailIssue.inputFieldPlaceholderTextColor
        notesField.placeholderString = isConnectionIssue ? "Add your notes (optional)" : "Your feedback"
        notesField.usesSingleLineMode = false
        self.view.addSubview(notesField)
        notesField.snp.makeConstraints { make in
            make.top.equalTo(operatingSystemLabel.snp.bottom).offset(10)
            make.height.equalTo(60)
            make.leading.equalToSuperview().offset(margin)
            make.trailing.equalToSuperview().offset(-margin)
        }
        
        emailField.delegate = self
        emailField.layerBackgroundColor = CurrentTheme.defaults.backgroundColor
        emailField.activeBorderColor = CurrentTheme.emailIssue.inputFieldActiveBorderColor
        emailField.inactiveBorderColor = CurrentTheme.emailIssue.inputFieldInactiveBorderColor
        emailField.textColor = CurrentTheme.emailIssue.inputFieldTextColor
        emailField.placeHolderStringColor = CurrentTheme.emailIssue.inputFieldPlaceholderTextColor
        emailField.placeholderString = "Your email"
        self.view.addSubview(emailField)
        emailField.snp.makeConstraints { make in
            make.top.equalTo(notesField.snp.bottom).offset(10)
            make.height.equalTo(30)
            make.leading.equalToSuperview().offset(margin)
            make.trailing.equalToSuperview().offset(-margin)
        }
        
        messageLabel.font = CurrentTheme.emailIssue.messageLabelFont
        messageLabel.textColor = CurrentTheme.defaults.foregroundColor
        messageLabel.stringValue = isConnectionIssue ? "We will look into this problem and follow up within 24 hours." : "We will follow up within 24 hours."
        messageLabel.alignment = .center
        messageLabel.verticalAlignment = .center
        messageLabel.usesSingleLineMode = true
        messageLabel.cell?.lineBreakMode = .byTruncatingTail
        self.view.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(margin)
            make.trailing.equalToSuperview().offset(-margin)
            make.top.equalTo(emailField.snp.bottom).offset(5)
            make.height.equalTo(20)
        }
        
        backButton.bezelStyle = .rounded
        backButton.font = CurrentTheme.addAccounts.buttonFont
        backButton.title = "Back"
        backButton.sizeToFit()
        backButton.target = self
        backButton.action = #selector(close)
        self.view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.height.equalTo(25)
            make.leading.equalToSuperview().offset(margin)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        submitButton.bezelStyle = .rounded
        submitButton.font = CurrentTheme.addAccounts.buttonFont
        submitButton.isEnabled = false
        submitButton.title = "Submit"
        submitButton.sizeToFit()
        submitButton.target = self
        submitButton.action = #selector(submit)
        self.view.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.height.equalTo(backButton)
            make.trailing.equalToSuperview().inset(margin)
            make.top.equalTo(backButton)
        }
    }
    
    fileprivate func attributedString(name: String, value: String) -> NSAttributedString {
        let nameAttributes = [NSAttributedStringKey.font: CurrentTheme.emailIssue.infoLabelNameFont,
                              NSAttributedStringKey.foregroundColor: CurrentTheme.emailIssue.infoLabelNameColor]
        let nameAttributedString = NSAttributedString(string: name + ": ", attributes: nameAttributes)
        
        let valueAttributes = [NSAttributedStringKey.font: CurrentTheme.emailIssue.infoLabelValueFont,
                               NSAttributedStringKey.foregroundColor: CurrentTheme.emailIssue.infoLabelValueColor]
        let valueAttributedString = NSAttributedString(string: value, attributes: valueAttributes)
        
        let attributedString = NSMutableAttributedString()
        attributedString.append(nameAttributedString)
        attributedString.append(valueAttributedString)
        return attributedString
    }
    
    @objc fileprivate func close() {
        closeBlock()
    }
    
    @objc fileprivate func submit() {
        guard submitButton.isEnabled else {
            return
        }
        
        submitButton.isEnabled = false
        
        Feedback.email(apiInstitution: apiInstitution, errorType: errorType, errorCode: errorCode, email: emailField.stringValue, comment: notesField.stringValue) { success, error in
            AppDelegate.sharedInstance.pinned = true
            if success {
                let alert = NSAlert()
                alert.addButton(withTitle: "OK")
                alert.messageText = self.isConnectionIssue ? "Report Sent" : "Feedback Sent"
                alert.informativeText = "We will get back to you as soon as possible."
                alert.alertStyle = .informational
                alert.beginSheetModal(for: self.view.window!) { _ in
                    AppDelegate.sharedInstance.pinned = false
                    self.close()
                }
            } else {
                let alert = NSAlert()
                alert.addButton(withTitle: "OK")
                if self.isConnectionIssue {
                    alert.messageText = "Problem Sending Report"
                    alert.informativeText = "Well isn't this embarrassing. It looks like somehow the report about your connection issue had a connection issue. Please contact us directly at support@balancemy.money to let us know how bad we messed up, and so that we can help you in any way possible. We apologize for the double inconvenience!"
                } else {
                    alert.messageText = "Problem Sending Feedback"
                    alert.informativeText = "Well isn't this embarrassing. Please contact us directly at support@balancemy.money to let us know how bad we messed up, and so that we can help you in any way possible. We apologize for the inconvenience!"
                }
                alert.alertStyle = .informational
                alert.beginSheetModal(for: self.view.window!) { _ in
                    AppDelegate.sharedInstance.pinned = false
                    self.submitButton.isEnabled = true
                }
            }
        }
    }
}

extension EmailIssueController: NSTextFieldDelegate {
    override func controlTextDidChange(_ obj: Notification) {
        if isConnectionIssue {
            submitButton.isEnabled = isEmailValid
        } else {
            submitButton.isEnabled = isEmailValid && notesField.stringValue.length > 0
        }
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
        if let window = self.view.window {
            if currentField == notesField.textField {
                return window.makeFirstResponder(emailField)
            } else if currentField == emailField.textField && isEmailValid {
                submit()
                return true
            }
        }
        
        return false
    }
    
    func handleBackTabKey(_ currentField: NSTextField) -> Bool {
        if let window = self.view.window, currentField == emailField.textField {
            return window.makeFirstResponder(notesField)
        }
        return false
    }
}
