//
//  AddAccountViewController.swift
//  Bal
//
//  Created by Benjamin Baron on 4/27/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation
import SnapKit
import BalanceVectorGraphics

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
    fileprivate let subtitleField = LabelField()
    fileprivate let requestExplanationField = LabelField()
    fileprivate let githubButton = Button()
    fileprivate let backButton = Button()
    fileprivate let statusField = LabelField()
    fileprivate let preferencesButton = Button()
    
    // Buttons
    fileprivate var buttons = [HoverButton]()
    fileprivate let buttonDrawFunctions: [Source: ButtonFunction] = [.coinbase: InstitutionButtons.drawCoinbaseButton,
                                                                     .gdax:     InstitutionButtons.drawGdaxButton,
                                                                     .poloniex: InstitutionButtons.drawPoloniexButton,
                                                                     .bitfinex: InstitutionButtons.drawBitfinexButton,
                                                                     .kraken:   InstitutionButtons.drawKrakenButton,
                                                                     .wallet:   InstitutionButtons.drawAddWalletAddressButton]
    fileprivate let buttonSourceOrder: [Source] = [.coinbase, .gdax, .poloniex, .bitfinex, .kraken, .wallet]
    fileprivate var signUpController: SignUpViewController?

    //
    // MARK: - Lifecycle -
    //
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Block preferences if no institutions
        if !InstitutionRepository.si.hasInstitutions {
            addShortcutMonitor()
        }
    }
    
    deinit {
        removeShortcutMonitor()
    }
    
    fileprivate var windowHeight: CGFloat {
        let buttonHeight = 50.0
        let minimumViewHeight = 260.0
        let verticalButtons = ceil(Float(self.buttonDrawFunctions.count)/Float(2.0))
        let windowHeight = (Double(verticalButtons) * buttonHeight) + minimumViewHeight
        return CGFloat(windowHeight)
    }
    
    fileprivate var hackDelay = 0.25
    fileprivate var hackDelayCount = 2
    override func viewWillAppear() {
        super.viewWillAppear()
        
        let hasInstitutions = InstitutionRepository.si.hasInstitutions
        backButton.isHidden = !hasInstitutions && allowSelection
        githubButton.isHidden = hasInstitutions
        
        // TODO: Remove delay hack. Currently there to allow for the resize to work on app launch
        async(after: hackDelay) {
            if self.hackDelay > 0.0 {
                self.hackDelayCount -= 1
                if self.hackDelayCount == 0 {
                    self.hackDelay = 0.0
                }
            }
            print("going back \(self.allowSelection)")
            if self.allowSelection {
                AppDelegate.sharedInstance.resizeWindowHeight(self.windowHeight, animated: true)
            }
        }
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
        
        let logoImage = #imageLiteral(resourceName: "intro-logo")
        let logoImageView = ImageView()
        logoImageView.image = logoImage
        containerView.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.width.equalTo(logoImage.size.width)
            make.height.equalTo(logoImage.size.height)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(25)
        }
        
        let trianglesImage = #imageLiteral(resourceName: "intro-dark-triangles")
        let trianglesImageView = ImageView()
        trianglesImageView.image = trianglesImage
        containerView.addSubview(trianglesImageView)
        trianglesImageView.snp.makeConstraints { make in
            make.width.equalTo(trianglesImage.size.width)
            make.height.equalTo(trianglesImage.size.height)
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        welcomeField.stringValue = "Balance"
        welcomeField.font = .mediumSystemFont(ofSize: 28)//CurrentTheme.addAccounts.welcomeFont
        welcomeField.textColor = CurrentTheme.defaults.foregroundColor
        welcomeField.alignment = .center
        welcomeField.usesSingleLineMode = true
        containerView.addSubview(welcomeField)
        welcomeField.snp.makeConstraints { make in
            make.leading.equalTo(containerView).inset(10)
            make.trailing.equalTo(containerView).inset(10)
            make.top.equalTo(logoImageView.snp.bottom).offset(25)
        }
        
        subtitleField.stringValue = "Connect to an exchange"
        subtitleField.font = .mediumSystemFont(ofSize: 18)//CurrentTheme.addAccounts.welcomeFont
        subtitleField.textColor = CurrentTheme.defaults.foregroundColor
        subtitleField.alignment = .center
        subtitleField.usesSingleLineMode = true
        containerView.addSubview(subtitleField)
        subtitleField.snp.makeConstraints { make in
            make.leading.equalTo(containerView).inset(10)
            make.trailing.equalTo(containerView).inset(10)
            make.top.equalTo(welcomeField.snp.bottom).offset(10)
        }
        
        requestExplanationField.stringValue = "Read-only API access to your account"
        requestExplanationField.font = .mediumSystemFont(ofSize: 14)//CurrentTheme.addAccounts.welcomeFont
        requestExplanationField.textColor = CurrentTheme.defaults.foregroundColor
        requestExplanationField.alignment = .center
        requestExplanationField.alphaValue = 0.6
        requestExplanationField.usesSingleLineMode = true
        containerView.addSubview(requestExplanationField)
        requestExplanationField.snp.makeConstraints { make in
            make.leading.equalTo(containerView).inset(10)
            make.trailing.equalTo(containerView).inset(10)
            make.top.equalTo(subtitleField.snp.bottom).offset(10)
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
            make.top.equalTo(requestExplanationField.snp.bottom).offset(15)
            make.bottom.equalTo(backButton.snp.top).offset(-10)
        }
        
        createButtons()
        
        let isLight = CurrentTheme.type == .light
        
        let buttonBlueColor = isLight ? NSColor(deviceRedInt: 39, green: 132, blue: 240) : NSColor(deviceRedInt: 71, green: 152, blue: 244)
        let buttonAltBlueColor = isLight ? NSColor(deviceRedInt: 39, green: 132, blue: 240, alpha: 0.7) : NSColor(deviceRedInt: 71, green: 152, blue: 244, alpha: 0.7)
        
        let buttonAttributes = [NSAttributedStringKey.foregroundColor: buttonBlueColor,
                                NSAttributedStringKey.font: NSFont.semiboldSystemFont(ofSize: 13)]
        let buttonAltAttributes = [NSAttributedStringKey.foregroundColor: buttonAltBlueColor,
                                   NSAttributedStringKey.font: NSFont.semiboldSystemFont(ofSize: 13)]
        
        githubButton.attributedTitle = NSAttributedString(string:"GitHub", attributes: buttonAttributes)
        githubButton.attributedAlternateTitle = NSAttributedString(string:"GitHub", attributes: buttonAltAttributes)
        githubButton.setAccessibilityLabel("GitHub")
        githubButton.isBordered = false
        githubButton.setButtonType(.momentaryChange)
        githubButton.target = self
        githubButton.sizeToFit()
        githubButton.action = #selector(githubButtonAction)
        containerView.addSubview(githubButton)
        githubButton.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.left.equalToSuperview().offset(13)
            make.bottom.equalToSuperview().inset(10)
        }
        
        if allowSelection && InstitutionRepository.si.institutionsCount == 0 {
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
    
    @objc fileprivate func githubButtonAction() {
        let url = "https://github.com/balancemymoney/balance-open"
        do {
            _ = try NSWorkspace.shared.open(URL(string: url)!, options: [], configuration: [:])
        } catch {
            // TODO: Better error handling
            print("Error opening Github repo URL: \(error)")
        }
    }
    
    fileprivate func createButtons() {
        func assignBlocks(button: HoverButton, bounds: NSRect, function: @escaping ButtonFunction) {
            button.originalBlock = {
                function(bounds, true, false, false)
            } as HoverButton.DrawingBlock
            
            if allowSelection {
                button.hoverBlock = {
                    function(bounds, false, true, false)
                } as HoverButton.DrawingBlock
                button.pressedBlock = {
                    function(bounds, false, false, true)
                } as HoverButton.DrawingBlock
            }
        }
        
        let buttonWidth = 191.0
        let buttonHeight = 56.0
        let buttonHorizPadding = 8.5
        let buttonVertPadding = -1
        let buttonSize = NSRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)
        
        var isRightColumn = false
        var topView: NSView? = nil
        for source in buttonSourceOrder {
            if let drawFunction = buttonDrawFunctions[source] {
                let button = HoverButton(frame: buttonSize)
                
                button.target = self
                button.action = #selector(buttonAction(_:))
                button.tag = source.rawValue
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
            switch source {
            case .coinbase:
                CoinbaseApi.authenticate()
            default:
                self.presentLoginScreenWith(apiInstitution: source.apiInstitution, loginService: source.exchangeApi)
            }
        }
    }
    
    func presentLoginScreenWith(apiInstitution: ApiInstitution,  loginService: ExchangeApi) {
        guard signUpController == nil else {
            return
        }
        signUpController = SignUpViewController(apiInstitution: apiInstitution, patch: false, institution: nil, loginService: loginService, closeBlock: { (finished, signUpViewController: SignUpViewController) in
            if finished {
                self.back()
            } else {
                self.removeSignUpController(animated: true)
            }
            async() {
                if self.allowSelection {
                    AppDelegate.sharedInstance.resizeWindowHeight(self.windowHeight, animated: true)
                }
            }
        })
        preferencesButton.isEnabled = false
        preferencesButton.animator().alphaValue = 0.0
        self.view.replaceSubview(containerView, with: (signUpController?.view)!, animation: .slideInFromRight)
    }
    
    func removeSignUpController(animated: Bool) {
        if let signUpController = signUpController {
            preferencesButton.isEnabled = true
            if animated {
                preferencesButton.animator().alphaValue = 1.0
                self.view.replaceSubview(signUpController.view, with: containerView, animation: .slideInFromLeft) {
                    self.signUpController = nil
                }
            } else {
                preferencesButton.alphaValue = 1.0
                self.view.replaceSubview(signUpController.view, with: containerView, animation: .none) {
                    self.signUpController = nil
                }
            }
        }
    }
    
    @objc func showSettingsMenu(_ sender: NSButton) {
        let menu = NSMenu()
        menu.addItem(withTitle: "Send Feedback", action: #selector(sendFeedback), keyEquivalent: "")
        menu.addItem(withTitle: "Check for Updates", action: #selector(checkForUpdates(sender:)), keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit Balance", action: #selector(quitApp), keyEquivalent: "q")
        
        let event = NSApplication.shared.currentEvent ?? NSEvent()
        NSMenu.popUpContextMenu(menu, with: event, for: sender)
    }
    
    @objc func sendFeedback() {
        AppDelegate.sharedInstance.sendFeedback()
    }
    
    @objc func checkForUpdates(sender: Any) {
        AppDelegate.sharedInstance.checkForUpdates(sender: sender)
    }
    
    @objc func quitApp() {
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
