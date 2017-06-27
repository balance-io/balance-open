//
//  SignUpTextField.swift
//  Bal
//
//  Created by Benjamin Baron on 12/7/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Cocoa
import SnapKit

enum BalanceTextFieldType {
    case username
    case password
    case pin
    case mfaCode
    case mfaAnswer
    case balancePassword
    case email
    case none
}

class BalanceTextField: View, TextFieldDelegate {
    weak var customDelegate: TextFieldDelegate?
    
    let type: BalanceTextFieldType
    
    var activeBorderColor = CurrentTheme.balanceTextField.activeBorderColor
    var inactiveBorderColor = CurrentTheme.balanceTextField.inactiveBorderColor
    
    var placeHolderStringColor = CurrentTheme.balanceTextField.placeHolderTextColor {
        didSet {
            updatePlaceholder()
        }
    }
    
    var textField: NSTextField!

    fileprivate let iconContainer = View()
    fileprivate let icon = ImageView()
    fileprivate let offset = 7.0
    
    init(type: BalanceTextFieldType) {
        self.type = type
        super.init(frame: NSZeroRect)
        commonInit()
    }
    
    override init(frame frameRect: NSRect) {
        fatalError("unsupported")
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    func commonInit() {
        
        self.layerBackgroundColor = CurrentTheme.balanceTextField.backgroundColor
        self.borderColor = inactiveBorderColor
        self.borderWidth = 2.0
        self.cornerRadius = 6.0
        
        self.addSubview(iconContainer)
        iconContainer.snp.makeConstraints { make in
            make.width.equalTo(30)
            make.height.equalTo(30)
            make.top.equalToSuperview()
            make.leading.equalTo(self)
        }
        
        var iconImage = #imageLiteral(resourceName: "login-user")
        var iconImageSize = NSZeroSize
        switch type {
        case .username:
            iconImage = #imageLiteral(resourceName: "login-user")
            iconImageSize = NSSize(width: 13, height: 13)
        case .password:
            iconImage = #imageLiteral(resourceName: "login-password")
            iconImageSize = NSSize(width: 10, height: 12)
        case .pin, .mfaCode:
            iconImage = #imageLiteral(resourceName: "login-pin")
            iconImageSize = NSSize(width: 12, height: 12)
        case .mfaAnswer:
            iconImage = #imageLiteral(resourceName: "login-mfa")
            iconImageSize = NSSize(width: 13, height: 13)
        // TODO: Better separate the light/dark ones from white only ones
        case .balancePassword:
            iconImage = CurrentTheme.type == .light ? #imageLiteral(resourceName: "login-balancePassword"): #imageLiteral(resourceName: "login-password")
            iconImageSize = NSSize(width: 10, height: 12)
        case .email:
            iconImage = CurrentTheme.type == .light ? #imageLiteral(resourceName: "login-mail-light") : #imageLiteral(resourceName: "login-mail-dark")
            iconImageSize = NSSize(width: 13, height: 10)
        case .none:
            iconImage = NSImage()
            iconImageSize = NSZeroSize
        }
        icon.image = iconImage
        icon.imageScaling = .scaleNone
        iconContainer.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.centerX.equalTo(iconContainer)
            make.centerY.equalTo(iconContainer)
            make.width.equalTo(iconImageSize.width)
            make.height.equalTo(iconImageSize.height)
        }
        
        if type == .password || type == .balancePassword {
            let field = SecureField()
            field.customDelegate = self
            field.drawsBackground = false
            textField = field
        } else {
            let field = TextField()
            field.customDelegate = self
            textField = field
        }
        textField.isEditable = true
        textField.isSelectable = true
        textField.isBordered = false
        textField.allowsEditingTextAttributes = true
        textField.cell?.isScrollable = true
        textField.textColor = CurrentTheme.balanceTextField.textColor
        textField.font = CurrentTheme.balanceTextField.font
        textField.focusRingType = .none
        self.addSubview(textField)
        textField.snp.makeConstraints { make in
            if iconImageSize.width == 0 {
                make.leading.equalToSuperview().offset(offset)
            } else {
                make.leading.equalTo(iconContainer.snp.trailing)
            }
            make.trailing.equalToSuperview().offset(-offset)
            make.top.equalToSuperview().offset(5.5)
            make.height.equalToSuperview().offset(-11)
        }
        updatePlaceholder()
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(textFieldDidBeginEditing), name: NSControl.textDidBeginEditingNotification, object: textField)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(textFieldDidEndEditing), name: NSControl.textDidEndEditingNotification, object: textField)
    }
    
    deinit {
        NotificationCenter.removeObserverOnMainThread(self, name: NSControl.textDidBeginEditingNotification, object: textField)
        NotificationCenter.removeObserverOnMainThread(self, name: NSControl.textDidEndEditingNotification, object: textField)
    }
    
    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    func textFieldDidBecomeFirstResponder(_ textField: NSTextField) {
        self.borderColor = activeBorderColor
        
        customDelegate?.textFieldDidBecomeFirstResponder(textField)
    }
    
    @objc fileprivate func textFieldDidBeginEditing() {
        self.borderColor = activeBorderColor
    }
    
    @objc fileprivate func textFieldDidEndEditing() {
        /* // This check doesn't work properly
        if let firstResponder = self.window?.firstResponder {
            if let fieldEditor = firstResponder as? NSText, let field = fieldEditor.delegate as? NSTextField, field == textField {
                // Sometimes we get this callback even when we're still editing, so check for that
                return
            }
        } */
        
        self.borderColor = inactiveBorderColor
    }
    
    fileprivate func updatePlaceholder() {
        if let placeholderString = textField.placeholderString, placeholderString.length > 0 {
            let placeholderAttributes: [NSAttributedStringKey : Any] = [NSAttributedStringKey.foregroundColor: placeHolderStringColor,
                                                                        NSAttributedStringKey.font: CurrentTheme.balanceTextField.font]
            textField.placeholderAttributedString = NSAttributedString(string: placeholderString, attributes: placeholderAttributes)
        }
    }
    
    // MARK: - Text Field Passthrough -
    
    var delegate: NSTextFieldDelegate? {
        get {
            return textField.delegate
        }
        set {
            textField.delegate = newValue
        }
    }
    
    var stringValue: String {
        get {
            return textField.stringValue
        }
        set {
            textField.stringValue = newValue
        }
    }
    
    var attributedStringValue: NSAttributedString {
        get {
            return textField.attributedStringValue
        }
        set {
            textField.attributedStringValue = newValue
        }
    }
    
    var placeholderString: String? {
        get {
            return textField.placeholderString
        }
        set {
            textField.placeholderString = newValue
            updatePlaceholder()
        }
    }
    
    var font: NSFont? {
        get {
            return textField.font
        }
        set {
            textField.font = newValue
        }
    }
    
    var textColor: NSColor? {
        get {
            return textField.textColor
        }
        set {
            textField.textColor = newValue
        }
    }
    
    var isEnabled: Bool {
        get {
            return textField.isEnabled
        }
        set {
            textField.isEnabled = newValue
        }
    }
    
    var usesSingleLineMode: Bool {
        get {
            return textField.usesSingleLineMode
        }
        set {
            textField.usesSingleLineMode = newValue
            textField.cell?.wraps = !newValue
        }
    }
}

