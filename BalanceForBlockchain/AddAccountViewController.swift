//
//  AddAccountViewController.swift
//  Bal
//
//  Created by Benjamin Baron on 4/27/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation
import SnapKit

class AddAccountViewController: NSViewController {
    
    typealias ButtonFunction = (_ bounds: NSRect, _ original: Bool, _ hover: Bool, _ pressed: Bool) -> (Void)
    fileprivate let buttonVertPadding = 12.0
    
    //
    // MARK: - Properties -
    //
    
    var allowSelection = true
    var backFunction: (() -> Void)?
    
    // Container views
    fileprivate let containerView = View()
    fileprivate let buttonContainerView = View()
    
    // Main fields
    fileprivate let welcomeField = LabelField()
    fileprivate let backButton = Button()
    fileprivate let statusField = LabelField()
    fileprivate let preferencesButton = Button()
    
    // Buttons
    fileprivate var buttons = [HoverButton]()
    fileprivate let buttonDrawFunctions: [Source: ButtonFunction] = [.coinbase: AddAccountButtons.drawBoaButton,
                                                                     .gdax:     AddAccountButtons.drawBoaButton,
                                                                     .poloniex: AddAccountButtons.drawBoaButton,
                                                                     .bitfinex: AddAccountButtons.drawBoaButton]
    fileprivate let buttonSourceOrder: [Source] = [.coinbase, .gdax, .poloniex, .bitfinex]
    
    //
    // MARK: - Lifecycle -
    //
    
    init() {
        super.init(nibName: nil, bundle: nil)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Block preferences if no institutions
        if !Institution.hasInstitutions {
            addShortcutMonitor()
        }
    }
    
    deinit {
        removeShortcutMonitor()
    }
    
    fileprivate var hackDelay = 0.25
    fileprivate var hackDelayCount = 2
    override func viewWillAppear() {
        super.viewWillAppear()
        
        welcomeField.stringValue = "Add an Account"
        backButton.isHidden = !Institution.hasInstitutions && allowSelection
    }
    
    //
    // MARK: - Create View -
    //
    
    override func loadView() {
        self.view = View()
        
        self.view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        
        welcomeField.font = NSFont.mediumSystemFont(ofSize: 20)//CurrentTheme.addAccounts.welcomeFont
        welcomeField.textColor = CurrentTheme.defaults.foregroundColor
        welcomeField.alignment = .center
        welcomeField.usesSingleLineMode = true
        containerView.addSubview(welcomeField)
        welcomeField.snp.makeConstraints { make in
            make.height.equalTo(25)
            make.leading.equalTo(containerView).inset(10)
            make.trailing.equalTo(containerView).inset(10)
            make.top.equalTo(containerView).inset(17)
        }
        
        backButton.isHidden = true
        backButton.bezelStyle = .rounded
        backButton.font = NSFont.systemFont(ofSize: 14)
        backButton.title = "Back"
        backButton.setAccessibilityLabel("Back")
        backButton.sizeToFit()
        backButton.target = self
        backButton.action = #selector(back)
        containerView.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.height.equalTo(25)
            make.bottom.equalTo(containerView).inset(15)
            make.left.equalTo(containerView).inset(15)
        }
        
        containerView.addSubview(buttonContainerView)
        buttonContainerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(welcomeField.snp.bottom).offset(7)
            make.bottom.equalTo(backButton.snp.top).offset(-10)
        }
        
        createButtons()
        
        if allowSelection && Institution.institutionsCount == 0 {
            // Preferences button
            preferencesButton.target = self
            preferencesButton.action = #selector(showSettingsMenu(_:))
            let preferencesIcon = CurrentTheme.tabs.footer.preferencesIcon
            preferencesButton.image = preferencesIcon
            preferencesButton.setButtonType(.momentaryChange)
            preferencesButton.setAccessibilityLabel("Preferences")
            preferencesButton.isBordered = false
            self.view.addSubview(preferencesButton)
            preferencesButton.snp.makeConstraints { make in
                make.bottom.equalTo(self.view).offset(-11)
                make.trailing.equalTo(self.view).offset(-11)
                make.width.equalTo(16)
                make.height.equalTo(16)
            }
        }
    }
    
    fileprivate func createButtons() {
        func assignBlocks(button: HoverButton, bounds: NSRect, function: @escaping ButtonFunction) {
            button.originalBlock = {
                function(bounds, true, false, false)
            }
            
            if allowSelection {
                button.hoverBlock = {
                    function(bounds, false, true, false)
                }
                button.pressedBlock = {
                    function(bounds, false, false, true)
                }
            }
        }
        
        let buttonWidth = 191.0
        let buttonHeight = 56.0
        let buttonHorizPadding = 8.5
        let buttonVertPadding = -1
        let buttonSize = NSRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)
        
        var tag = 0
        var isRightColumn = false
        var topView: NSView? = nil
        for source in buttonSourceOrder {
            if let drawFunction = buttonDrawFunctions[source] {
                let button = HoverButton(frame: buttonSize)
                
                button.target = self
                button.action = #selector(buttonAction(_:))
                button.tag = tag
                button.setAccessibilityLabel(source.description)
                
                assignBlocks(button: button, bounds: buttonSize, function: drawFunction)
                buttonContainerView.addSubview(button)
                button.snp.makeConstraints { make in
                    make.width.equalTo(buttonWidth)
                    make.height.equalTo(buttonHeight)
                    
                    if let topView = topView {
                        make.top.equalTo(topView.snp.bottom).offset(buttonVertPadding)
                    } else {
                        make.top.equalTo(buttonContainerView)
                    }
                    
                    if isRightColumn {
                        make.right.equalTo(buttonContainerView).inset(buttonHorizPadding + 0.5)
                    } else {
                        make.left.equalTo(buttonContainerView).offset(buttonHorizPadding + 0.5)
                    }
                }
                
                buttons.append(button)
                
                if isRightColumn {
                    topView = button
                }
                isRightColumn = !isRightColumn
            }
            tag += 1
        }
    }
    
    fileprivate func removeButtons() {
        for button in buttons {
            button.removeFromSuperview()
        }
        buttons = []
    }
    
    // MARK: - Actions -
    
    @objc fileprivate func back() {
        if let backFunction = backFunction {
            backFunction()
        } else {
            NotificationCenter.postOnMainThread(name: Notifications.ShowTabIndex, object: nil, userInfo: [Notifications.Keys.TabIndex: Tab.accounts.rawValue])
            NotificationCenter.postOnMainThread(name: Notifications.ShowTabs)
        }
    }
    
    @objc fileprivate func buttonAction(_ sender: NSButton) {
        if allowSelection, let source = Source(rawValue: sender.tag) {
            // TODO: Implement this
        }
    }
    
    func showSettingsMenu(_ sender: NSButton) {
        let menu = NSMenu()
        menu.addItem(withTitle: "Send Feedback", action: #selector(sendFeedback), keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit Balance", action: #selector(quitApp), keyEquivalent: "q")
        
        let event = NSApplication.shared().currentEvent ?? NSEvent()
        NSMenu.popUpContextMenu(menu, with: event, for: sender)
    }
    
    func sendFeedback() {
        AppDelegate.sharedInstance.sendFeedback()
    }
    
    func quitApp() {
        AppDelegate.sharedInstance.quitApp()
    }
    
    // MARK: - Prefs Window Blocking -
    
    // Block preferences window from opening
    fileprivate var shortcutMonitor: Any?
    func addShortcutMonitor() {
        if shortcutMonitor == nil {
            shortcutMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event -> NSEvent? in
                if let characters = event.charactersIgnoringModifiers {
                    if event.modifierFlags.contains(.command) && characters.length == 1 {
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
