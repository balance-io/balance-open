//
//  TokenSearchField.swift
//  Bal
//
//  Created by Benjamin Baron on 11/27/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Cocoa
import SnapKit

class TokenSearchField: View, TextFieldDelegate {
    weak var customDelegate: TextFieldDelegate?
    
    var placeHolderStringColor = CurrentTheme.defaults.searchField.placeHolderStringColor {
        didSet {
            updatePlaceholder()
        }
    }
    
    let searchIcon = ImageView()
    let textField = TokenTextField()
    let closeButton = Button()
    let secondShadowView = View()
    fileprivate var closeButtonVisible = false
    fileprivate var searchIconCenterX: NSLayoutConstraint!
    fileprivate let offset = 7.0
    fileprivate var trackingArea: NSTrackingArea?
    fileprivate var placeholderCenteredXOffset: CGFloat {
        let searchIconWidth = CurrentTheme.defaults.searchField.searchIconImage.size.width
        let stringWidth = (placeholderAttributedString?.string ?? "").size(font: CurrentTheme.defaults.searchField.font).width
        return -(searchIconWidth + CGFloat(offset) + stringWidth) / CGFloat(2)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        
        textField.placeholderString = "Search"
        updatePlaceholder()
        
        self.layerBackgroundColor = NSColor.clear
//        self.borderWidth = 1
//        self.borderColor = CurrentTheme.defaults.searchField.borderColor
        self.cornerRadius = 6.0
        
        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.28)
        shadow.shadowOffset = NSMakeSize(0,-1)
        shadow.shadowBlurRadius = 0.5
        self.shadow = shadow
        
        secondShadowView.cornerRadius = 6.0
        self.addSubview(secondShadowView)
        secondShadowView.layerBackgroundColor = CurrentTheme.defaults.searchField.backgroundColor
        secondShadowView.snp.makeConstraints { make in
            make.width.equalTo(self)
            make.height.equalTo(self)
            make.top.equalTo(self)
            make.leading.equalTo(self)
        }
        
        let secondShadow = NSShadow()
        secondShadow.shadowColor = NSColor.black.withAlphaComponent(0.32)
        secondShadow.shadowOffset = NSMakeSize(0,-1.5)
        secondShadow.shadowBlurRadius = 2
        secondShadowView.shadow = secondShadow
        
        let searchIconImage = CurrentTheme.defaults.searchField.searchIconImage
        searchIcon.image = searchIconImage
        self.addSubview(searchIcon)
        searchIcon.snp.makeConstraints { make in
            //make.leading.equalTo(offset)
            //make.centerX.equalTo(self).offset(-50).labeled("centerX")
            make.centerY.equalTo(self)
            make.width.equalTo(searchIconImage.size.width)
            make.height.equalTo(searchIconImage.size.height)
        }
        
        // Doing it this way because animating SnapKit constraints is currently broken
        searchIconCenterX = NSLayoutConstraint(item: searchIcon,
                                               attribute: .centerX,
                                               relatedBy: .equal,
                                               toItem: self,
                                               attribute: .centerX,
                                               multiplier: 1.0,
                                               constant: placeholderCenteredXOffset)
        self.addConstraint(searchIconCenterX)
        
        let closeButtonImage = NSImage(named: NSImage.Name.stopProgressFreestandingTemplate)!
        closeButton.isBordered = false
        closeButton.image = closeButtonImage
        closeButton.target = self
        closeButton.action = #selector(closeButtonAction)
        closeButton.isEnabled = false
        closeButton.alphaValue = 0.0
        self.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.trailing.equalTo(self).offset(-offset)
            make.centerY.equalTo(self)
            make.width.equalTo(closeButtonImage.size.width)
            make.height.equalTo(closeButtonImage.size.height)
        }
        
        //textField.verticalAlignment = .center
        textField.textInsets = NSEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
        textField.customDelegate = self
        textField.isEditable = true
        textField.isSelectable = true
        textField.isBordered = false
        textField.allowsEditingTextAttributes = true
        textField.cell?.isScrollable = true
        textField.textColor = CurrentTheme.defaults.searchField.textColor
        textField.font = CurrentTheme.defaults.searchField.font
        textField.focusRingType = .none
        self.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.leading.equalTo(searchIcon.snp.trailing).offset(offset)
            make.trailing.equalTo(closeButton.snp.leading).offset(-offset)
            make.height.equalTo(19)
            make.top.equalTo(self).offset(5)
        }
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(textFieldDidChange), name: NSControl.textDidChangeNotification, object: textField)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(textFieldDidEndEditing), name: NSControl.textDidEndEditingNotification, object: textField)
    }
    
    deinit {
        NotificationCenter.removeObserverOnMainThread(self, name: NSControl.textDidChangeNotification, object: textField)
        NotificationCenter.removeObserverOnMainThread(self, name: NSControl.textDidEndEditingNotification, object: textField)
    }
    
    @objc fileprivate func textFieldDidChange() {
        let isEmpty = textField.stringValue.isEmpty
        if isEmpty && closeButtonVisible {
            closeButton.animator().alphaValue = 0.0
            closeButton.isEnabled = false
            closeButtonVisible = false
        } else if !isEmpty && !closeButtonVisible {
            closeButton.animator().alphaValue = 1.0
            closeButton.isEnabled = true
            closeButtonVisible = true
        }
    }
    
    @objc fileprivate func closeButtonAction() {
        textField.attributedStringValue = NSAttributedString(string: "")
        NotificationCenter.postOnMainThread(name: NSControl.textDidChangeNotification, object: textField)
        self.window?.makeFirstResponder(self.superview)
        NotificationCenter.postOnMainThread(name: NSControl.textDidEndEditingNotification, object: textField)
    }
    
    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    func textFieldDidBecomeFirstResponder(_ textField: NSTextField) {
        if textField.stringValue.isEmpty {
            moveIconToLeft(animated: true)
        }
        
        customDelegate?.textFieldDidBecomeFirstResponder(textField)
    }
    
    @objc fileprivate func textFieldDidEndEditing() {
        if textField.stringValue.isEmpty {
            moveIconToCenter(animated: true)
        }
    }
    
    fileprivate func updatePlaceholder() {
        if let placeholderString = textField.placeholderString, placeholderString.count > 0 {
            let placeholderAttributes: [NSAttributedStringKey : Any] = [NSAttributedStringKey.foregroundColor: placeHolderStringColor,
                                                                        NSAttributedStringKey.font: CurrentTheme.defaults.searchField.font]
            textField.placeholderAttributedString = NSAttributedString(string: placeholderString, attributes: placeholderAttributes)
        }
    }
    
    override func layout() {
        super.layout()
        if !textField.stringValue.isEmpty {
            moveIconToLeft(animated: true)
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        if let locationInSuperview = self.superview?.convert(event.locationInWindow, from: nil) {
            let hitView = self.hitTest(locationInSuperview)
            if hitView == self || hitView == searchIcon || hitView == secondShadowView {
                self.window?.makeFirstResponder(textField)
            }
        }
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingArea = trackingArea {
            self.removeTrackingArea(trackingArea)
        }
        
        trackingArea = NSTrackingArea(rect: self.bounds, options: [NSTrackingArea.Options.mouseEnteredAndExited, NSTrackingArea.Options.activeAlways], owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea!)
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        NSCursor.iBeam.set()
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        NSCursor.arrow.set()
    }
    
    fileprivate func moveIconToCenter(animated: Bool) {
        let constant = placeholderCenteredXOffset
        if searchIconCenterX.constant != constant {
            if animated {
                NSAnimationContext.runAnimationGroup({ context in
                    context.duration = 0.2
                    context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                    searchIconCenterX.animator().constant = constant
                    searchIcon.animator().needsUpdateConstraints = true
                }, completionHandler: nil)
            } else {
                searchIconCenterX.constant = constant
                searchIcon.needsUpdateConstraints = true
            }
        }
    }
    
    fileprivate func moveIconToLeft(animated: Bool) {
        let selfWidth: CGFloat = self.frame.size.width
        let iconWidth: CGFloat = searchIcon.frame.size.width
        let constant: CGFloat = -(selfWidth / CGFloat(2.0)) + (iconWidth / CGFloat(2.0)) + CGFloat(offset)
        
        if searchIconCenterX.constant != constant {
            if animated {
                NSAnimationContext.runAnimationGroup({ context in
                    context.duration = 0.2
                    context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                    searchIconCenterX.animator().constant = constant
                    searchIcon.animator().needsUpdateConstraints = true
                }, completionHandler: nil)
            } else {
                searchIconCenterX.constant = constant
                searchIcon.needsUpdateConstraints = true
            }
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
            if textField.stringValue.isEmpty && !newValue.isEmpty {
                // First text added, so adjust the location of the icon
                moveIconToLeft(animated: false)
            }
            textField.stringValue = newValue
            textFieldDidChange()
        }
    }
    
    var attributedStringValue: NSAttributedString {
        get {
            return textField.attributedStringValue
        }
        set {
            if textField.attributedStringValue.string.isEmpty && !newValue.string.isEmpty {
                // First text added, so adjust the location of the icon
                moveIconToLeft(animated: false)
            }
            textField.attributedStringValue = newValue
            textFieldDidChange()
        }
    }
    
    var placeholderString: String? {
        get {
            return textField.placeholderString
        }
        set {
            textField.placeholderString = newValue
            updatePlaceholder()
            moveIconToCenter(animated: false)
        }
    }
    
    var placeholderAttributedString: NSAttributedString? {
        get {
            return textField.placeholderAttributedString
        }
        set {
            textField.placeholderAttributedString = newValue
            moveIconToCenter(animated: false)
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
    
    @available(OSX 10.12.2, *)
    var isAutomaticTextCompletionEnabled: Bool {
        get {
            return textField.isAutomaticTextCompletionEnabled
        }
        set {
            textField.isAutomaticTextCompletionEnabled = newValue
        }
    }
}
