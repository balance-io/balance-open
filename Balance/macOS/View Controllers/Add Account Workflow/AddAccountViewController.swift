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
    fileprivate let searchContainerView = View()
    fileprivate let buttonContainerView = View()
    
    // Main fields
    fileprivate let welcomeField = LabelField()
    fileprivate let institutionTypeSegmentedControl = NSSegmentedControl()
    fileprivate let backButton = Button()
    fileprivate let statusField = LabelField()
    let searchField = TokenSearchField()
    fileprivate let preferencesButton = Button()
    
    //Institution Types
    enum InstitutionTypeSection: Int {
        case popular = 0
        case checking = 1
        case credit = 2
        case investment = 3
        case online = 4
    }
    
    // Account buttons
    fileprivate var buttons = [NSButton]()
    fileprivate let buttonDrawFunctions: [String: ButtonFunction] = [
        "chase":      InstitutionButtons.drawChaseButton,
        "bofa":       InstitutionButtons.drawBoaButton,
        "wells":      InstitutionButtons.drawWellsButton,
        "citi":       InstitutionButtons.drawCitiButton,
        "us":         InstitutionButtons.drawUsbankButton,
        "usaa":       InstitutionButtons.drawUsaaButton,
        "pnc":        InstitutionButtons.drawPncButton,
        "ins_101692": InstitutionButtons.drawSchwabButton,
        "amex":       InstitutionButtons.drawAmexButton,
        "capone":     InstitutionButtons.drawCapitalOneButton,
        "ins_100096": InstitutionButtons.drawEtradeButton,
        "ins_107233": InstitutionButtons.drawScottradeButton,
        "td":         InstitutionButtons.drawTdBank, // TODO: Rename this to drawTdBankButton
        "ins_100048": InstitutionButtons.drawFidelityButton,
        "ins_100020": InstitutionButtons.drawPaypalButton,
        "ins_100007": InstitutionButtons.drawSimpleButton,
        "ins_100003": InstitutionButtons.drawDiscoverButton
    ]
    fileprivate let tabData: [[String]] = [
        ["chase", "bofa", "wells", "citi", "us", "usaa", "pnc", "ins_101692", "amex", "capone", "ins_100096", "ins_107233", "td", "ins_100048", "ins_100007", "ins_100003"],
        ["chase", "bofa", "wells", "citi", "us", "usaa", "pnc", "ins_101692"],
        ["amex", "capone", "chase"],
        ["ins_100096", "ins_107233", "td", "ins_100048"],
        ["ins_100020"]
    ]

    // Search
    fileprivate let scrollView = ScrollView()
    fileprivate let tableView = SectionedTableView()
    fileprivate var lastSearchData = [[Institution](), [Institution]()]
    fileprivate var searchData = [[Institution](), [Institution]()]
    fileprivate var searchTask: URLSessionDataTask?
    fileprivate var searchViewShowing = false
    
    // Next page
    fileprivate var signUpController: WebSignUpViewController?
    
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
    
    fileprivate var hackDelay = 0.25
    fileprivate var hackDelayCount = 2
    override func viewWillAppear() {
        super.viewWillAppear()
        
        welcomeField.stringValue = "Add an Account"
        backButton.isHidden = !InstitutionRepository.si.hasInstitutions && allowSelection
        
        if signUpController == nil {
            if subscriptionManager.productId != .none && !InstitutionRepository.si.hasInstitutions {
                // TODO: Remove delay hack. Currently there to allow for the resize to work on app launch
                async(after: hackDelay) {
                    if self.hackDelay > 0.0 {
                        self.hackDelayCount -= 1
                        if self.hackDelayCount == 0 {
                            self.hackDelay = 0.0
                        }
                    }
                    
                    if self.allowSelection {
                        AppDelegate.sharedInstance.resizeWindow(CurrentTheme.defaults.size, animated: true)
                    }
                }
            } else {
                if self.allowSelection {
                    async {
                        AppDelegate.sharedInstance.resizeWindow(CurrentTheme.defaults.size, animated: true)
                    }
                }
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
        
        welcomeField.font = CurrentTheme.addAccounts.welcomeFont
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
        backButton.font = CurrentTheme.addAccounts.buttonFont
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
        
//        statusField.isHidden = true
//        statusField.stringValue = "All bank connections are working"
//        statusField.font = CurrentTheme.addAccounts.statusFont
//        statusField.textColor = CurrentTheme.addAccounts.statusColor
//        statusField.usesSingleLineMode = true
//        statusField.setAccessibilityLabel("Connection Status")
//        statusField.verticalAlignment = .center
//        containerView.addSubview(statusField)
        
        searchField.delegate = self
        searchField.placeholderString = "Search over 9,000 supported institutions"
        searchField.setAccessibilityLabel("Institution Search")
        containerView.addSubview(searchField)
        searchField.snp.makeConstraints { make in
            make.width.equalTo(containerView).inset(15)
            make.height.equalTo(29)
            make.top.equalTo(welcomeField.snp.bottom).offset(17)
            make.centerX.equalTo(containerView)
        }
        
        containerView.addSubview(searchContainerView)
        searchContainerView.snp.makeConstraints { make in
            make.left.equalTo(containerView)
            make.right.equalTo(containerView)
            make.top.equalTo(searchField.snp.bottom).offset(7)
            make.bottom.equalTo(backButton.snp.top).offset(-10)
        }
        
        searchContainerView.addSubview(buttonContainerView)
        buttonContainerView.snp.makeConstraints { make in
            make.left.equalTo(searchContainerView)
            make.right.equalTo(searchContainerView)
            make.top.equalTo(searchContainerView)
            make.bottom.equalTo(searchContainerView)
        }
        
//        institutionTypeSegmentedControl.isHidden = false
//        institutionTypeSegmentedControl.segmentCount = 5
//        institutionTypeSegmentedControl.setLabel("Popular", forSegment: InstitutionTypeSection.popular.rawValue)
//        institutionTypeSegmentedControl.setLabel("Checking", forSegment: InstitutionTypeSection.checking.rawValue)
//        institutionTypeSegmentedControl.setLabel("Credit", forSegment: InstitutionTypeSection.credit.rawValue)
//        institutionTypeSegmentedControl.setLabel("Investment", forSegment: InstitutionTypeSection.investment.rawValue)
//        institutionTypeSegmentedControl.setLabel("Online", forSegment: InstitutionTypeSection.online.rawValue)
//        
//        institutionTypeSegmentedControl.setSelected(true, forSegment:InstitutionTypeSection.popular.rawValue)
//        institutionTypeSegmentedControl.target = self
//        institutionTypeSegmentedControl.action = #selector(segmentSwitch(_:))
//        
//        buttonContainerView.addSubview(institutionTypeSegmentedControl)
//        institutionTypeSegmentedControl.snp.makeConstraints{ make in
//            make.centerX.equalTo(containerView)
//            make.top.equalTo(buttonContainerView)
//            make.height.equalTo(20)
//        }
        
        createButtons(selectedSegment: InstitutionTypeSection.popular.rawValue)
        createSearchView()
        
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
    
    fileprivate func createButtons(selectedSegment: Int) {
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
        
        var tag = 0
        var isRightColumn = false
        var topView: NSView? = nil
        for sourceInstitutionId in tabData[selectedSegment] {
            // TODO: Made this data source indepependent
            if let plaidInstitution = institutionsDatabase.search(source: .plaid, sourceInstitutionId: sourceInstitutionId), let drawFunction = buttonDrawFunctions[sourceInstitutionId] {
                let button = HoverButton(frame: buttonSize)
                
                button.target = self
                button.action = #selector(buttonAction(_:))
                button.tag = tag
                button.setAccessibilityLabel(plaidInstitution.name)
                
                assignBlocks(button: button, bounds: buttonSize, function: drawFunction)
                buttonContainerView.addSubview(button)
                button.snp.makeConstraints { make in
                    make.width.equalTo(buttonWidth)
                    make.height.equalTo(buttonHeight)
                    
                    if let topView = topView {
                        make.top.equalTo(topView.snp.bottom).offset(buttonVertPadding)
                    } else {
                        //make.top.equalTo(institutionTypeSegmentedControl.snp.bottom).offset(6)
                        make.top.equalTo(buttonContainerView)//.offset(6)
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
    
    func createSearchView() {
        tableView.selectionHighlightStyle = .none
        tableView.backgroundColor = NSColor.clear
        tableView.customDelegate = self
        tableView.customDataSource = self
        // TODO: intercellSpacing doesn't seem to allow values lower than 1, so it's rendering as 2 pixels on retina
        tableView.intercellSpacing = CurrentTheme.defaults.cell.intercellSpacing
        tableView.gridColor = CurrentTheme.defaults.foregroundColor.withAlphaComponent(0.03)
        tableView.gridStyleMask = NSTableView.GridLineStyle.solidHorizontalGridLineMask
        tableView.rowHeight = 5000 // Hide grid lines on empty cells
        scrollView.documentView = tableView
        searchContainerView.addSubview(scrollView)
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
        if allowSelection {
            let tag = sender.tag
            //let sourceInstitutionId = tabData[institutionTypeSegmentedControl.selectedSegment][tag]
            let sourceInstitutionId = tabData[0][tag]
            if let institution = institutionsDatabase.search(source: .plaid, sourceInstitutionId: sourceInstitutionId) {
                showSignUpController(institution: institution, animated: true)
            }
        }
    }
    
    @objc fileprivate func segmentSwitch(_ sender: NSSegmentedControl) {
        removeButtons()
        createButtons(selectedSegment: sender.selectedSegment)
    }
    
    func showSearchView() {
        if !searchViewShowing {
            searchViewShowing = true
            institutionTypeSegmentedControl.isHidden = true
            
            searchContainerView.replaceSubview(buttonContainerView, with: scrollView, animation: .slideInFromRight, constraints: { make in
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.top.equalToSuperview().offset(8)
                make.bottom.equalToSuperview()
            })
        }
    }
    
    func hideSearchView() {
        if searchViewShowing {
            searchViewShowing = false
            institutionTypeSegmentedControl.isHidden = false
            searchContainerView.replaceSubview(scrollView, with: buttonContainerView, animation: .slideInFromLeft)
        }
    }

    func connect() {
        if allowSelection {
            let index = tableView.selectedIndex
            if index.row >= 0 {
                let institution = self.searchData[index.section][index.row]
                showSignUpController(institution: institution, animated: true)
            }
        }
    }
    
    func showSignUpController(institution: Institution, animated: Bool) {
        guard signUpController == nil else {
            return
        }
        
        guard subscriptionManager.remainingAccounts > 0 else {
            let alert = NSAlert()
            alert.addButton(withTitle: "OK")
            alert.messageText = "Account Limit Reached"
            alert.informativeText = "Your account is limited to \(subscriptionManager.maxAccounts) accounts. Please upgrade to use more accounts"
            alert.alertStyle = .informational
            if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
                AppDelegate.sharedInstance.showBillingPreferences()
            }
            return
        }
        
        signUpController = WebSignUpViewController(source: institution.source, sourceInstitutionId: institution.sourceInstitutionId) { finished in
            if finished {
                self.back()
            } else {
                self.removeSignUpController(animated: true)
            }
        }
        
        if let signUpController = signUpController {
            preferencesButton.isEnabled = false
            if animated {
                preferencesButton.animator().alphaValue = 0.0
                self.view.replaceSubview(containerView, with: signUpController.view, animation: .slideInFromRight)
            } else {
                preferencesButton.alphaValue = 0.0
                self.view.replaceSubview(containerView, with: signUpController.view, animation: .none)
            }
        }
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
                self.view.replaceSubview(signUpController.view, with: containerView, animation: .none)
                self.signUpController = nil
            }
        }
    }
    
    @objc func showSettingsMenu(_ sender: NSButton) {
        let menu = NSMenu()
        menu.addItem(withTitle: "Send Feedback", action: #selector(sendFeedback), keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit Balance", action: #selector(quitApp), keyEquivalent: "q")
        
        let event = NSApplication.shared.currentEvent ?? NSEvent()
        NSMenu.popUpContextMenu(menu, with: event, for: sender)
    }
    
    @objc func sendFeedback() {
        let urlString = "mailto:support@balancemy.money?Subject=Balance%20Feedback"
        _ = try? NSWorkspace.shared.open(URL(string: urlString)!, options: [], configuration: [:])
    }
    
    @objc func quitApp() {
        NSApp.terminate(nil)
    }
    
    // MARK: - Search -
    
    // Rate limited (in seconds)
    fileprivate let searchRateLimit: Double = 0.25
    fileprivate var lastSearchTime: Double = 0
    @objc func performSearch() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearch), object: nil)
        
        // Cancel any previous search
        if let searchTask = searchTask {
            searchTask.cancel()
        }
        
        let currentTime = CFAbsoluteTimeGetCurrent()
        let timeDiff = currentTime - lastSearchTime
        if timeDiff < searchRateLimit {
            // Wait
            let delay = searchRateLimit - timeDiff
            self.perform(#selector(performSearch), with: nil, afterDelay: delay)
        } else {
            // Perform search
            if searchField.stringValue.isEmpty {
                lastSearchData = [[Institution](), [Institution]()]
                searchData = [[Institution](), [Institution]()]
                tableView.reloadData()
                tableView.deselectAll(nil)
                //connectButton.enabled = false
                async(after: 0.3) {
                    self.hideSearchView()
                }
            } else {
                let plaidInstitutions = institutionsDatabase.search(name: self.searchField.stringValue)
                let primaryInstitutions = plaidInstitutions.filter({$0.isPrimary})
                let otherInstitutions = plaidInstitutions.filter({!$0.isPrimary})
                let newData = [primaryInstitutions, otherInstitutions]
                
                if primaryInstitutions.count > 0 && otherInstitutions.count > 0 {
                    lastSearchData = searchData.flatMap({$0}).count > 0 ? searchData : newData
                }
                searchData = newData
                
                tableView.reloadData()
                if searchData.flatMap({$0}).count > 0 {
                    tableView.deselectAll(nil)
                    showSearchView()
                } else if lastSearchData.flatMap({$0}).count == 0 {
                    hideSearchView()
                }
            }
            
            lastSearchTime = currentTime
        }
    }
    
    // MARK: - Prefs Window Blocking -
    
    // Block preferences window from opening
    fileprivate var shortcutMonitor: Any?
    func addShortcutMonitor() {
        if shortcutMonitor == nil {
            shortcutMonitor = NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.keyDown) { event -> NSEvent? in
                if let characters = event.charactersIgnoringModifiers {
                    if event.modifierFlags.contains(NSEvent.ModifierFlags.command) && characters.length == 1 {
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

extension AddAccountViewController: NSSearchFieldDelegate {
    override func controlTextDidChange(_ obj: Notification) {
        performSearch()
    }
}

extension AddAccountViewController: SectionedTableViewDelegate, SectionedTableViewDataSource {
    
    func tableView(_ tableView: SectionedTableView, clickedRow row: Int, inSection section: Int) {
        connect()
    }
    
    func numberOfSectionsInTableView(_ tableView: SectionedTableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: SectionedTableView, numberOfRowsInSection section: Int) -> Int {
        return searchData[section].count
    }
    
    func tableView(_ tableView: SectionedTableView, heightOfSection section: Int) -> CGFloat {
        return 26
    }
    
    func tableView(_ tableView: SectionedTableView, heightOfRow row: Int, inSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: SectionedTableView, rowViewForSection section: Int) -> NSTableRowView? {
        var row = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Date Row"), owner: self) as? NSTableRowView
        if row == nil {
            row = TableRowView()
            row?.identifier = NSUserInterfaceItemIdentifier(rawValue: "Institution Search Section Row")
        }
        return row
    }
    
    func tableView(_ tableView: SectionedTableView, rowViewForRow row: Int, inSection section: Int) -> NSTableRowView? {
        var row = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Institution Search Row"), owner: self) as? NSTableRowView
        if row == nil {
            row = TableRowView()
            row?.identifier = NSUserInterfaceItemIdentifier(rawValue: "Institution Search Row")
        }
        return row
    }
    
    func tableView(_ tableView: SectionedTableView, viewForSection section: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Group Cell"), owner: self) as? GroupCell ?? GroupCell()
        cell.identifier = NSUserInterfaceItemIdentifier(rawValue: "Group Cell")
        cell.section = -1
        
        if section == 0 {
            cell.updateModel("Popular")
            cell.nameField.font = CurrentTheme.addAccounts.searchHeaderPopularFont
        } else {
            cell.updateModel("More results")
            cell.nameField.textColor = CurrentTheme.addAccounts.searchHeaderColor.withAlphaComponent(0.9)
        }
        
        return cell
    }
    
    func tableView(_ tableView: SectionedTableView, viewForRow row: Int, inSection section: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Institution Cell"), owner: self) as? InstitutionCell ?? InstitutionCell()
        cell.section = section
        
        let institution = searchData[section][row]
        cell.updateModel(institution)
        
        return cell
    }
    
    fileprivate class GroupCell: View {
        var section = -1
        
        //        let blurryView = VisualEffectView()
        let blurryView = View()
        let nameField = LabelField()
        
        init() {
            super.init(frame: NSZeroRect)
            
            //            blurryView.blendingMode = .withinWindow
            //            blurryView.material = CurrentTheme.defaults.material
            blurryView.wantsLayer = true
            //            blurryView.state = .active
            blurryView.layerBackgroundColor = CurrentTheme.addAccounts.searchHeaderBackgroundColor
            self.addSubview(blurryView)
            blurryView.snp.makeConstraints { make in
                make.leading.equalTo(self)
                make.trailing.equalTo(self)
                make.top.equalTo(self)
                make.height.equalTo(26)
            }
            
            nameField.textColor = CurrentTheme.addAccounts.searchHeaderColor
            nameField.font = CurrentTheme.addAccounts.searchHeaderFont
            self.addSubview(nameField)
            nameField.snp.makeConstraints { make in
                make.centerX.equalTo(self)
                make.centerY.equalTo(self).offset(3)
                make.height.equalTo(26)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("unsupported")
        }
        
        func updateModel(_ model: String) {
            nameField.stringValue = model
        }
    }
    
    fileprivate class InstitutionCell: View {
        var section = -1
        
        let colorView = View()
        let popularNameField = LabelField()
        let moreResultsNameField = LabelField()
        
        init() {
            super.init(frame: NSZeroRect)
            
            colorView.cornerRadius = 3.0
            self.addSubview(colorView)
            colorView.snp.makeConstraints { make in
                make.width.equalTo(10)
                make.height.equalTo(10)
                make.leading.equalTo(self).inset(12)
                make.centerY.equalTo(self)
            }
            
            popularNameField.verticalAlignment = .center
            popularNameField.font = CurrentTheme.addAccounts.searchPopularFont
            popularNameField.textColor = CurrentTheme.addAccounts.searchPopularColor
            popularNameField.alignment = .left
            self.addSubview(popularNameField)
            popularNameField.snp.makeConstraints { make in
                make.leading.equalTo(colorView.snp.trailing).offset(6)
                make.trailing.equalTo(self).inset(12)
                make.centerY.equalTo(self).offset(-1.5)
                make.height.equalTo(self)
            }
            
            moreResultsNameField.verticalAlignment = .center
            moreResultsNameField.font = CurrentTheme.addAccounts.searchMoreResultsFont
            moreResultsNameField.textColor = CurrentTheme.addAccounts.searchMoreResultsColor
            moreResultsNameField.alignment = .left
            self.addSubview(moreResultsNameField)
            moreResultsNameField.snp.makeConstraints { make in
                make.leading.equalTo(self).inset(12)
                make.trailing.equalTo(self).inset(12)
                make.centerY.equalTo(self).offset(-1.5)
                make.height.equalTo(self)
            }
        }
        
        func updateModel(_ model: Institution) {
            if section == 0 {
                if debugging.showInstitutionTypesInSearch {
                    popularNameField.stringValue = "\(model.sourceInstitutionId): \(model.name)"
                } else {
                    popularNameField.stringValue = model.name
                }
                colorView.layerBackgroundColor = model.color
                colorView.isHidden = false
                popularNameField.isHidden = false
                moreResultsNameField.isHidden = true
            } else {
                if debugging.showInstitutionTypesInSearch {
                    moreResultsNameField.stringValue = "\(model.sourceInstitutionId): \(model.name)"
                } else {
                    moreResultsNameField.stringValue = model.name
                }
                colorView.isHidden = true
                popularNameField.isHidden = true
                moreResultsNameField.isHidden = false
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("unsupported")
        }
    }
}
