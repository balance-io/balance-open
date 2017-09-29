//
//  NotificationsTabViewController.swift
//  Bal
//
//  Created by Benjamin Baron on 2/9/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Cocoa
import SnapKit
import MapKit
import Crashlytics
import BalanceVectorGraphics

class NotificationsTabViewController: NSViewController, NotificationsTabViewModelDelegate, NSTextFieldDelegate, TextFieldDelegate, SectionedTableViewDelegate, SectionedTableViewDataSource {
    
    struct InternalNotifications {
        static let CellOpened   = Notification.Name("FeedCellOpened")
        static let CellClosed   = Notification.Name("FeedCellClosed")
        
        struct Keys {
            static let Cell     = "Cell"
        }
    }
    
    //
    // MARK: - Constants -
    //
    
    fileprivate let searchFieldSpacer = 6.0
    fileprivate let notificationBarHeight = 24.0
    
    //
    // MARK: - Properties -
    //
    
    fileprivate let viewModel = NotificationsTabViewModel()
    fileprivate var previousSelectedIndex = TableIndex.none
    
    // MARK: Header
    fileprivate let searchField = TokenSearchField()
    fileprivate let notificationBar = NotificationBar()
    
    // MARK: Body
    fileprivate let scrollView = ScrollView()
    fileprivate let tableView = SectionedTableView()
    fileprivate let noResultsField = LabelField()
    
    // MARK: Empty State
    fileprivate let emptyStateView = View()
    fileprivate let emptyStateTitle = LabelField()
    fileprivate let emptyStateField = LabelField()
    fileprivate let emptyStateButton = Button()
    fileprivate let emptyStateIcon = ImageView()
    fileprivate let defaultRulesPromptView = PaintCodeView()
    
    // MARK: Footer
    fileprivate let footerView = VisualEffectView()
    fileprivate let totalField = LabelField()
    fileprivate let transactionCountField = LabelField()
    
    //
    // MARK: - Lifecycle -
    //
    
    init() {
        super.init(nibName: nil, bundle: nil)
        viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForNotifications()
        reloadData()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        addSearchShortcutMonitor()
        
        async {
            self.adjustWindowHeight()
        }
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        removeSearchShortcutMonitor()
    }
    
    fileprivate func adjustWindowHeight() {
        async {
            AppDelegate.sharedInstance.resizeWindowToMaxHeight(animated: true)
        }
    }
    
    deinit {
        unregisterForNotifications()
    }
    
    //
    // MARK: - View Creation -
    //
    
    override func loadView() {
        self.view = View()
        
        createHeader()
        createTable()
        createEmptyState()
        createFooter()
    }
    
    func createHeader() {
        if debugging.showSearchBarForFeed {
            searchField.delegate = self
            searchField.customDelegate = self
            self.view.addSubview(searchField)
    //        searchField.appearance = NSAppearance(named: NSAppearanceNameVibrantLight)
    //        searchField.font = CurrentTheme.feed.cell.nameFont
            searchField.snp.makeConstraints { make in
                make.top.equalTo(self.view).offset(10)
                make.height.equalTo(29)
                make.leading.equalTo(self.view).inset(12)
                make.trailing.equalTo(self.view).inset(12)
            }
        }
    
        self.view.addSubview(notificationBar)
        notificationBar.snp.makeConstraints { make in
            if debugging.showSearchBarForFeed {
                make.top.equalTo(searchField.snp.bottom).offset(searchFieldSpacer * 2)
            } else {
                make.top.equalTo(self.view).offset(10)
            }
            make.leading.equalTo(self.view)
            make.trailing.equalTo(self.view)
            make.height.equalTo(notificationBarHeight)
        }
    }
    
    fileprivate let noResultsDateFormatter = DateFormatter()
    func createTable() {
        noResultsField.alignment = .center
        noResultsField.font = CurrentTheme.feed.cell.nameFont
        noResultsField.textColor = CurrentTheme.defaults.foregroundColor
        noResultsField.usesSingleLineMode = false
        noResultsField.alphaValue = 0.0
        self.view.addSubview(noResultsField)
        noResultsField.snp.makeConstraints { make in
            make.leading.equalTo(self.view).inset(5)
            make.trailing.equalTo(self.view).inset(5)
            if debugging.showSearchBarForFeed {
                make.top.equalTo(searchField.snp.bottom).offset(20)
            } else {
                make.top.equalTo(self.view).offset(notificationBarHeight + 10)
            }
            make.height.equalTo(60)
        }
        
        scrollView.documentView = tableView
        scrollView.contentInsets = NSEdgeInsetsMake(0, 0, 30, 0)
        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            if debugging.showSearchBarForFeed {
                make.top.equalTo(searchField.snp.bottom).offset((searchFieldSpacer * 2) + notificationBarHeight)
            } else {
                make.top.equalTo(self.view).offset(notificationBarHeight + 10)
            }
            make.leading.equalTo(self.view)
            make.trailing.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        
        tableView.customDelegate = self
        tableView.customDataSource = self
        // TODO: intercellSpacing doesn't seem to allow values lower than 1, so it's rendering as 2 pixels on retina
        tableView.intercellSpacing = CurrentTheme.defaults.cell.intercellSpacing
        tableView.gridColor = CurrentTheme.defaults.cell.spacerColor
        tableView.gridStyleMask = NSTableView.GridLineStyle.solidHorizontalGridLineMask
        tableView.setAccessibilityLabel("Feed List")
        tableView.rowHeight = 5000 // Hide grid lines on empty cells
        tableView.selectionHighlightStyle = .none
        
        tableView.reloadData()
    }
    
    func createEmptyState() {
        self.view.addSubview(emptyStateView)
        emptyStateView.snp.makeConstraints { make in
            make.width.equalTo(350)
            make.height.equalTo(300)
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.view).offset(-75)
        }
        
        emptyStateIcon.image = CurrentTheme.feed.emptyState.icon
        emptyStateView.addSubview(emptyStateIcon)
        emptyStateIcon.snp.makeConstraints { make in
            make.top.equalTo(emptyStateView).inset(10)
            make.centerX.equalTo(emptyStateView)
        }
        
        emptyStateTitle.alignment = .center
        emptyStateTitle.font = CurrentTheme.feed.emptyState.titleFont
        emptyStateTitle.textColor = CurrentTheme.defaults.foregroundColor
        emptyStateTitle.usesSingleLineMode = false
        emptyStateTitle.stringValue = "Notifications"
        emptyStateView.addSubview(emptyStateTitle)
        emptyStateTitle.snp.makeConstraints { make in
            make.top.equalTo(emptyStateIcon.snp.bottom).offset(7)
            make.centerX.equalTo(emptyStateView)
        }
        
        let emptyStateParagraphStyle = NSMutableParagraphStyle()
        emptyStateParagraphStyle.alignment = .center;
        emptyStateParagraphStyle.lineHeightMultiple = 1.24
        let emptyStateAttributes = [NSAttributedStringKey.foregroundColor: CurrentTheme.defaults.foregroundColor,
                          NSAttributedStringKey.font: NSFont.systemFont(ofSize: 13),
                          NSAttributedStringKey.paragraphStyle: emptyStateParagraphStyle]
        let emptyStateString = "Fully customizable notifications for any type of transaction. Choose from the rules below or create your own in settings."
        emptyStateField.attributedStringValue = NSAttributedString(string: emptyStateString, attributes: emptyStateAttributes)
        emptyStateField.alignment = .center
        emptyStateField.font = CurrentTheme.feed.emptyState.bodyFont
//        emptyStateField.textColor = CurrentTheme.defaults.foregroundColor
        emptyStateField.alphaValue = 0.62
//        emptyStateField.lineBreakMode =
        //TODO Line Height
//        emptyStateField.usesSingleLineMode = false
        emptyStateView.addSubview(emptyStateField)
        emptyStateField.snp.makeConstraints { make in
            make.leading.equalTo(emptyStateView).offset(44)
            make.trailing.equalTo(emptyStateView).offset(-44)
            make.top.equalTo(emptyStateTitle.snp.bottom).offset(8.5)
        }
        
        let attributes = [NSAttributedStringKey.foregroundColor: CurrentTheme.defaults.foregroundColor,
                          NSAttributedStringKey.font: NSFont.systemFont(ofSize: 13),
                          NSAttributedStringKey.paragraphStyle: centeredParagraphStyle]
        emptyStateButton.attributedTitle = NSAttributedString(string: "Create a Rule", attributes: attributes)
        emptyStateButton.bezelStyle = .rounded
        emptyStateButton.target = self
        emptyStateButton.action = #selector(addRule)
        emptyStateButton.sizeToFit()
        emptyStateView.addSubview(emptyStateButton)
        emptyStateButton.snp.makeConstraints { make in
//            make.width.equalTo(150)
            make.height.equalTo(28)
            make.centerX.equalTo(emptyStateView)
            make.top.equalTo(emptyStateField.snp.bottom).offset(26)
        }
        
        showHideEmptyStateView()
    }
    
    fileprivate func showHideEmptyStateView() {
        emptyStateView.isHidden = (feed.numberOfActiveRules > 0)
        searchField.isHidden = !emptyStateView.isHidden
        notificationBar.isHidden = !emptyStateView.isHidden
        scrollView.isHidden = !emptyStateView.isHidden
    }
    
    fileprivate func showHideUnreadNotificationsBar() {
        let show = (defaults.unreadNotificationIds.count > 0)
        notificationBar.isHidden = !show
        
        scrollView.snp.updateConstraints { make in
            if show {
                make.top.equalTo(searchField.snp.bottom).offset((searchFieldSpacer * 2) + notificationBarHeight)
            } else {
                make.top.equalTo(searchField.snp.bottom).offset(searchFieldSpacer)
            }
        }
        
        emptyStateView.isHidden = (feed.numberOfActiveRules > 0)
        searchField.isHidden = !emptyStateView.isHidden
        scrollView.isHidden = !emptyStateView.isHidden
    }
    
    fileprivate func updateNotificationBar() {
        let unreadCount = defaults.unreadNotificationIds.count
        var backgroundColor1 = CurrentTheme.feed.notificationsBar.noUnreadColor1
        var backgroundColor2 = CurrentTheme.feed.notificationsBar.noUnreadColor2
        if unreadCount > 0 {
            backgroundColor1 = CurrentTheme.feed.notificationsBar.unreadColor1
            backgroundColor2 = CurrentTheme.feed.notificationsBar.unreadColor2
        }
        notificationBar.update(backgroundColor1: backgroundColor1, backgroundColor2: backgroundColor2, unreadCount: unreadCount)
    }
    
    @objc func addRule() {
        AppDelegate.sharedInstance.showRulesPreferences()
    }
    
    func createFooter() {
        footerView.blendingMode = .withinWindow
        footerView.material = CurrentTheme.defaults.material
        footerView.state = .active
        footerView.layerBackgroundColor = CurrentTheme.defaults.totalFooter.totalBackgroundColor
        self.view.addSubview(footerView)
        footerView.snp.makeConstraints { make in
            make.height.equalTo(0)
            make.leading.equalTo(self.view)
            make.trailing.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        
        transactionCountField.alignment = .center
        transactionCountField.font = CurrentTheme.feed.cell.nameFont
        transactionCountField.textColor = CurrentTheme.defaults.foregroundColor
        transactionCountField.usesSingleLineMode = true
        footerView.addSubview(transactionCountField)
        transactionCountField.snp.makeConstraints { make in
            make.leading.equalTo(footerView).offset(10)
            make.centerY.equalTo(footerView)
        }
        
        totalField.font = CurrentTheme.feed.cell.nameFont
        totalField.alignment = .right
        totalField.usesSingleLineMode = true
        footerView.addSubview(totalField)
        totalField.snp.makeConstraints { make in
            make.trailing.equalTo(footerView).inset(12)
            make.centerY.equalTo(footerView)
        }
    }
    
    func createDefaultRulesPrompt() {
        func attributedStringForRule(_ rule: Rule) -> NSAttributedString {
            let attributedString = NSMutableAttributedString()
            if rule.searchTokens.keys.contains(.over) {
                let startingString = rule.notify ? "Notify me of any transaction " : "Any transaction "
                attributedString.append(NSAttributedString(string: startingString,
                                                               attributes: [NSAttributedStringKey.font: CurrentTheme.feed.defaultRulesPrompt.nameFont,
                                                                            NSAttributedStringKey.foregroundColor: CurrentTheme.feed.defaultRulesPrompt.nameTextColor]))
                attributedString.append(NSAttributedString(string: "over \(rule.searchTokens.values.first!)",
                                                           attributes: [NSAttributedStringKey.font: CurrentTheme.feed.defaultRulesPrompt.nameBoldFont,
                                                                        NSAttributedStringKey.foregroundColor: CurrentTheme.feed.defaultRulesPrompt.nameTextColor]))
                
            } else if rule.searchTokens.keys.contains(.categoryMatches) {
                let startingString = rule.notify ? "Notify me of any  " : "In category  "
                attributedString.append(NSAttributedString(string: startingString,
                                                           attributes: [NSAttributedStringKey.font: CurrentTheme.feed.defaultRulesPrompt.nameFont,
                                                                        NSAttributedStringKey.foregroundColor: CurrentTheme.feed.defaultRulesPrompt.nameTextColor]))
                attributedString.append(NSAttributedString(string: rule.searchTokens.values.first!,
                                                       attributes: [NSAttributedStringKey.font: CurrentTheme.feed.defaultRulesPrompt.nameBoldFont,
                                                                    NSAttributedStringKey.foregroundColor: CurrentTheme.feed.defaultRulesPrompt.nameTextColor,
                                                                    NSAttributedStringKey(rawValue: RoundedBackgroundAttributeView.RoundedBackgroundColorAttributeName): CurrentTheme.feed.defaultRulesPrompt.categoryBackgroundColor]))
                                                                    //NSBackgroundColorAttributeName: CurrentTheme.feed.defaultRulesPrompt.categoryBackgroundColor]))
            }
            return attributedString
        }
        
        defaultRulesPromptHide()
        
        let remainingRules = feed.remainingDefaultRules
        let count = remainingRules.count
        if count > 0 && !defaults.hideDefaultRulesPrompt {
            let isLight = (CurrentTheme.type == .light)
            let backgroundInset = 20
            let rowInset = 12
            let headerRowHeight = 39
            let rowHeight = 44
            
            defaultRulesPromptView.isClickingEnabled = false
            defaultRulesPromptView.drawingBlock = isLight ? AccountConnectionErrors.drawConnectionErrorsLight : AccountConnectionErrors.drawConnectionErrorsDark
            self.view.addSubview(defaultRulesPromptView)
            defaultRulesPromptView.snp.makeConstraints { make in
                let height = (backgroundInset * 2) + headerRowHeight + (rowHeight * count) - 1
                make.height.equalTo(height)
                make.width.equalTo(400)
                make.centerX.equalTo(self.view)
                make.bottom.equalTo(self.view).offset(-31)
            }
            
            let containerView = View()
            defaultRulesPromptView.addSubview(containerView)
            containerView.snp.makeConstraints { make in
                make.leading.equalTo(defaultRulesPromptView).offset(backgroundInset)
                make.trailing.equalTo(defaultRulesPromptView).offset(-backgroundInset)
                make.top.equalTo(defaultRulesPromptView).offset(backgroundInset)
                make.bottom.equalTo(defaultRulesPromptView).offset(-backgroundInset)
            }
            
            let headerRow = View()
            containerView.addSubview(headerRow)
            headerRow.snp.makeConstraints { make in
                make.height.equalTo(headerRowHeight)
                make.top.equalTo(containerView)
                make.leading.equalTo(containerView).offset(rowInset)
                make.trailing.equalTo(containerView).offset(-rowInset)
            }
        
            let hideButton = Button()
            hideButton.setButtonType(.momentaryChange)
            hideButton.isBordered = false
            hideButton.image = CurrentTheme.type == .light ? #imageLiteral(resourceName: "closeRulesWindowLight") : #imageLiteral(resourceName: "closeRulesWindowDark")
            hideButton.target = self
            hideButton.action = #selector(closeButton)
            headerRow.addSubview(hideButton)
            hideButton.snp.makeConstraints { make in
                make.width.equalTo(hideButton.image?.size.width ?? 0)
                make.height.equalTo(hideButton.image?.size.width ?? 0)
                make.trailing.equalTo(headerRow)
                make.centerY.equalTo(headerRow)
            }
            
            let headerLabel = LabelField()
            headerLabel.stringValue = "Popular rules"
            headerLabel.font = CurrentTheme.accounts.fixPasswordPrompt.headerFont
            headerLabel.textColor = CurrentTheme.accounts.fixPasswordPrompt.headerTextColor
            headerLabel.verticalAlignment = .center
            headerRow.addSubview(headerLabel)
            headerLabel.snp.makeConstraints { make in
                make.height.equalTo(headerRow)
                make.leading.equalTo(headerRow).offset(1)
                make.trailing.equalTo(hideButton.snp.leading).offset(7)
                make.top.equalTo(headerRow).offset(-1)
            }
            
            var row = 0
            for rule in remainingRules {
                let rowView = View()
                containerView.addSubview(rowView)
                rowView.snp.makeConstraints { make in
                    make.height.equalTo(rowHeight)
                    let top = headerRowHeight + (rowHeight * row)
                    make.top.equalTo(top)
                    make.leading.equalTo(containerView).offset(rowInset)
                    make.trailing.equalTo(containerView).offset(-rowInset)
                }
                
                let addButton = PaintCodeButton()
                addButton.textDrawingFunction = isLight ? AccountConnectionErrors.drawReconnectButtonLight : AccountConnectionErrors.drawReconnectButtonDark
                addButton.buttonText = "Add"
                addButton.buttonTextColor = CurrentTheme.accounts.fixPasswordPrompt.buttonTextColor
                addButton.object = rule
                addButton.target = self
                addButton.action = #selector(add(sender:))
                rowView.addSubview(addButton)
                addButton.snp.makeConstraints { make in
                    make.width.equalTo(54)
                    make.height.equalTo(27)
                    make.trailing.equalTo(rowView).offset(1)
                    make.centerY.equalTo(rowView)
                }
                
                let nameLabel = RoundedBackgroundAttributeView()//LabelField()
                nameLabel.attributedStringValue = attributedStringForRule(rule)
                nameLabel.verticalAlignment = .center
                rowView.addSubview(nameLabel)
                nameLabel.snp.makeConstraints { make in
                    make.height.equalTo(rowView)
                    make.leading.equalTo(rowView).offset(1)
                    make.trailing.equalTo(addButton.snp.leading).offset(-5)
                    make.centerY.equalTo(rowView).offset(4)
                    //make.centerY.equalTo(rowView).offset(-1)
                }
                
                if row != 0 {
                    let separator = View()
                    separator.layerBackgroundColor = CurrentTheme.accounts.fixPasswordPrompt.separatorColor
                    containerView.addSubview(separator)
                    separator.snp.makeConstraints { make in
                        make.height.equalTo(1)
                        make.leading.equalTo(containerView)
                        make.trailing.equalTo(containerView)
                        make.top.equalTo(rowView)
                    }
                }
                
                row += 1
            }
        }
    }
    
    func defaultRulesPromptHide() {
        for subview in defaultRulesPromptView.subviews {
            subview.removeFromSuperview()
        }
        defaultRulesPromptView.snp.removeConstraints()
        defaultRulesPromptView.removeFromSuperview()
    }
    
    @objc func add(sender: Button) {
        if let rule = sender.object as? Rule {
            _ = feed.createRule(name: "", notify: rule.notify, searchTokens: rule.searchTokens)
            reloadData()
            
            // Show prefs if first one added
            if feed.defaultRules.count - feed.remainingDefaultRules.count == 1 {
                AppDelegate.sharedInstance.showRulesPreferences()
            }
        }
    }
    
    @objc func closeButton() {
        defaultRulesPromptHide()
        defaults.hideDefaultRulesPrompt = true
    }
    
    //
    // MARK: - Notifications -
    //
    
    fileprivate func registerForNotifications() {
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(institutionAdded(_:)), name: Notifications.InstitutionAdded)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(institutionRemoved(_:)), name: Notifications.InstitutionRemoved)
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(accountHidden(_:)), name: Notifications.AccountHidden)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(accountUnhidden(_:)), name: Notifications.AccountUnhidden)
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(syncCompleted(_:)), name: Notifications.SyncCompleted)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(unreadNotificationIdsUpdatedFromCloud(_:)), name: Notifications.UnreadNotificationIdsUpdatedFromCloud)
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(rulesChanged(_:)), name: Notifications.RulesChanged)
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(popoverWillShow(_:)), name: Notifications.PopoverWillShow)
    }
    
    fileprivate func unregisterForNotifications() {
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.InstitutionAdded)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.InstitutionRemoved)
        
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.AccountHidden)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.AccountUnhidden)
        
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.SyncCompleted)
        
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.RulesChanged)
        
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.PopoverWillShow)
    }
    
    @objc fileprivate func institutionAdded(_ notification: Notification) {
        reloadDataIfInForeground()
    }
    
    @objc fileprivate func institutionRemoved(_ notification: Notification) {
        reloadDataIfInForeground()
    }
    
    @objc fileprivate func accountHidden(_ notification: Notification) {
        reloadDataIfInForeground()
    }
    
    @objc fileprivate func accountUnhidden(_ notification: Notification) {
        reloadDataIfInForeground()
    }
    
    @objc fileprivate func syncCompleted(_ notification: Notification) {
        reloadDataIfInForeground()
    }
    
    @objc fileprivate func unreadNotificationIdsUpdatedFromCloud(_ notification: Notification) {
        reloadDataIfInForeground()
    }
    
    @objc fileprivate func rulesChanged(_ notification: Notification) {
        reloadDataIfInForeground()
    }
    
    @objc fileprivate func popoverWillShow(_ notification: Notification) {
        if viewModel.dataChangedInBackground {
            viewModel.dataChangedInBackground = false
            reloadDataDelayed()
        }
    }
    
    fileprivate func reloadDataIfInForeground() {
        if AppDelegate.sharedInstance.statusItem.isStatusItemWindowVisible {
            reloadDataDelayed()
        } else {
            viewModel.dataChangedInBackground = true
        }
    }
    
    // Coalesce rapid changes to prevent a bunch of data churn and UI slowdown 
    @objc fileprivate func reloadDataDelayed() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(reloadData), object: nil)
        self.perform(#selector(reloadData), with: nil, afterDelay: 1.0)
    }
    
    @objc func reloadData() {
        viewModel.reloadData()
    }
    
    func reloadDataFinished() {
        tableView.reloadData()
        updateNumberOfTransactionsAndTotal()
        showHideEmptyStateView()
        toggleNoResultsView()
        createDefaultRulesPrompt()
        updateNotificationBar()
        
        if view.window != nil {
            adjustWindowHeight()
        }
    }
    
    //
    // MARK: - Search -
    //
    
    func textFieldDidBecomeFirstResponder(_ textField: NSTextField) {
        // Analytics
        Answers.logContentView(withName: "Feed tab search started", contentType: nil, contentId: nil, customAttributes: nil)
    }
    
    func performSearch(_ searchString: String) {
        searchField.attributedStringValue = Search.styleSearchString(searchString)
        performSearchNow()
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        searchField.attributedStringValue = Search.styleSearchString(searchField.stringValue)
        performSearchDelayed()
    }
    
    fileprivate let searchDelay: Double = 0.25
    func performSearchDelayed() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearchNow), object: nil)
        self.perform(#selector(performSearchNow), with: nil, afterDelay: searchDelay)
    }
    
    @objc func performSearchNow() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearchNow), object: nil)
        
        if previousSelectedIndex.section >= 0 {
            tableView.deselectIndex(previousSelectedIndex)
            tableView.noteHeightOfIndex(previousSelectedIndex)
            previousSelectedIndex = TableIndex.none
            NotificationCenter.postOnMainThread(name: InternalNotifications.CellClosed)
        }
        
        let lastSearch = viewModel.lastSearch
        viewModel.performSearchNow(searchString: searchField.stringValue)
        
        updateNumberOfTransactionsAndTotal()
        
        tableView.updateRows(oldObjects: lastSearch.flattened as NSArray, newObjects: viewModel.data.flattened as NSArray, animationOptions: [NSTableView.AnimationOptions.effectFade, NSTableView.AnimationOptions.slideDown])
        
        tableView.scrollToBeginningOfDocument(nil)
        
        toggleNoResultsView()
        
        if viewModel.searching && viewModel.data.count > 0 {
            footerView.snp.updateConstraints { make in
                make.height.equalTo(30)
            }
        } else {
            footerView.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
        }
        self.view.layoutSubtreeIfNeeded()
    }
    
    func toggleNoResultsView() {
        let showNoResultsField = (viewModel.data.count == 0 && feed.numberOfActiveRules > 0)
        
        if showNoResultsField {
            if let lastKey = viewModel.unfilteredData.keys.last, let oldestTransaction = viewModel.unfilteredData[lastKey]?.last {
                noResultsDateFormatter.dateFormat = "MMM d, y"
                let date = noResultsDateFormatter.string(from: oldestTransaction.date as Date)
                noResultsField.stringValue = "No results found.\n\nThe earliest transaction in the feed is from \(date)."
            } else {
                noResultsField.stringValue = "No results found. The feed is empty."
            }
        }
        
        if noResultsField.alphaValue != CGFloat(showNoResultsField ? 1.0 : 0.0) {
            if showNoResultsField {
                NSAnimationContext.runAnimationGroup({ context in
                    context.duration = 0.8
                    self.noResultsField.animator().alphaValue = 1.0
                }, completionHandler: nil)
                NSAnimationContext.runAnimationGroup({ context in
                    context.duration = 0.2
                    self.notificationBar.animator().alphaValue = 0.0
                }, completionHandler: nil)
            } else {
                self.noResultsField.animator().alphaValue = 0.0
                self.notificationBar.animator().alphaValue = 1.0
            }
        }
    }
    
    func updateNumberOfTransactionsAndTotal() {
        var runningTotal: Int = 0
        var numberOfTransactions: Int = 0
        for date in viewModel.data.keys {
            if let transactions = viewModel.data[date] {
                for transaction in transactions {
                    runningTotal = runningTotal + transaction.amount
                    numberOfTransactions += 1
                }
            }
        }
        
        totalField.attributedStringValue = centsToStringFormatted(runningTotal, showNegative: false, showCents: true, colorPositive: false)
        transactionCountField.stringValue = "\(numberOfTransactions) TRANSACTIONS"
    }
    
    fileprivate var searchShortcutMonitor: AnyObject?
    
    // Command + F to activate search
    func addSearchShortcutMonitor() {
        if searchShortcutMonitor == nil {
            searchShortcutMonitor = NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.keyDown) { event -> NSEvent? in
                if event.window == self.view.window {
                    if let characters = event.charactersIgnoringModifiers {
                        if event.modifierFlags.contains(NSEvent.ModifierFlags.command) && characters.length == 1 {
                            if characters == "f" {
                                self.view.window?.makeFirstResponder(self.searchField)
                                return nil
                            }
                        }
                    }
                }
                
                return event
            } as AnyObject?
        }
    }
    
    func removeSearchShortcutMonitor() {
        if let monitor = searchShortcutMonitor {
            NSEvent.removeMonitor(monitor)
            searchShortcutMonitor = nil
        }
    }
    
    //
    // MARK: - Table View -
    //

    func tableView(_ tableView: SectionedTableView, clickedRow row: Int, inSection section: Int) {
        let selectedIndex = tableView.selectedIndex
        let cell = tableView.viewAtIndex(selectedIndex, makeIfNecessary: false) as? NotificationsTabTransactionCell
        
        if previousSelectedIndex == selectedIndex {
            cell?.hideBottomContainer()
            tableView.deselectIndex(selectedIndex)
            tableView.noteHeightOfIndex(selectedIndex)
            previousSelectedIndex = TableIndex.none
        } else {
            var previousCell: NotificationsTabTransactionCell?
            var indexes = [selectedIndex]
            if previousSelectedIndex.section >= 0 {
                previousCell = tableView.viewAtIndex(previousSelectedIndex, makeIfNecessary: false) as? NotificationsTabTransactionCell
                indexes.append(previousSelectedIndex)
            }
            previousSelectedIndex = selectedIndex
            
            previousCell?.hideBottomContainer(notify: false)
            
            // Dispatch async so that it runs in the next run loop, otherwise the showBottomContainer() call will animate
            async(after: 0.1) {
                cell?.showBottomContainer()
                tableView.noteHeightOfIndexes(indexes)
                
                let visibleIndexes = tableView.visibleIndexes
                let count = visibleIndexes.count
                if count > 0 {
                    let contains = visibleIndexes.contains { index -> Bool in
                        return index == selectedIndex
                    }
                    
                    if !contains || selectedIndex == visibleIndexes[0] || selectedIndex == visibleIndexes[count - 1] {
                        NSAnimationContext.runAnimationGroup({ context in
                            context.allowsImplicitAnimation = true
                            self.tableView.scrollIndexToVisible(selectedIndex)
                        }, completionHandler: nil)
                    }
                }
            }
        }
    }
    
    func numberOfSectionsInTableView(_ tableView: SectionedTableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: SectionedTableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(inSection: section)
    }
    
    func tableView(_ tableView: SectionedTableView, heightOfSection section: Int) -> CGFloat {
        return CurrentTheme.feed.headerCell.height
    }
    
    func tableView(_ tableView: SectionedTableView, heightOfRow row: Int, inSection section: Int) -> CGFloat {
        if TableIndex(section: section, row: row) == tableView.selectedIndex, let transactions = viewModel.data[section] {
            let transaction = transactions[row]
            var extraHeight: CGFloat = 0.0
//            if transaction.hasLocation {
//                extraHeight = 212.0
//            } else {
//                if transaction.categoryId == nil {
//                    extraHeight = 63.0
//                } else {
//                    extraHeight = 90.0
//                }
//            }
            return CurrentTheme.feed.cell.height + extraHeight
        } else {
            return CurrentTheme.feed.cell.height
        }
    }
    
    func tableView(_ tableView: SectionedTableView, rowViewForSection section: Int) -> NSTableRowView? {
        var row = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Date Row"), owner: self) as? NSTableRowView
        if row == nil {
            row = TableRowView()
            row?.identifier = NSUserInterfaceItemIdentifier(rawValue: "Date Row")
        }
        return row
    }
    
    func tableView(_ tableView: SectionedTableView, rowViewForRow row: Int, inSection section: Int) -> NSTableRowView? {
        var row = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Feed Item Row"), owner: self) as? HoverTableRowView
        if row == nil {
            row = HoverTableRowView()
            row?.identifier = NSUserInterfaceItemIdentifier(rawValue: "Feed Item Row")
            row?.color = CurrentTheme.defaults.cell.backgroundColor
            row?.hoverColor = CurrentTheme.defaults.cell.hoverBackgroundColor
        }
        return row
    }
    
    func tableView(_ tableView: SectionedTableView, viewForSection section: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Group Cell"), owner: self) as? NotificationsTabGroupCell ?? NotificationsTabGroupCell()
        cell.identifier = NSUserInterfaceItemIdentifier(rawValue: "Group Cell")
        cell.section = -1
        
        let date = viewModel.data.keys[section]
        cell.updateModel(date)
        
        return cell
    }
    
    func tableView(_ tableView: SectionedTableView, viewForRow row: Int, inSection section: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Transaction Cell"), owner: self) as? NotificationsTabTransactionCell ?? NotificationsTabTransactionCell()
        cell.identifier = NSUserInterfaceItemIdentifier(rawValue: "Transaction Cell")
        
        if previousSelectedIndex != TableIndex.none && cell.index == previousSelectedIndex {
            cell.hideBottomContainer()
            tableView.deselectIndex(previousSelectedIndex)
            tableView.noteHeightOfIndex(previousSelectedIndex)
            async(after: 0.3) {
                tableView.reloadData()
            }
            previousSelectedIndex = TableIndex.none
        }
        
        let transaction = viewModel.data[section]![row]
        cell.updateModel(transaction)
        cell.index = TableIndex(section: section, row: row)
        
        let selectedIndex = tableView.selectedIndex
        if selectedIndex != TableIndex.none {
            cell.alphaValue = cell.index == selectedIndex ? 1.0 : CurrentTheme.feed.cell.dimmedAlpha
        }
        
        return cell
    }
}

// MARK: - Notifications Header Bar -

private class NotificationBar: View {
    fileprivate var backgroundColor1 = NSColor.clear
    fileprivate var backgroundColor2 = NSColor.clear
    fileprivate var unreadCount = 0
    
    fileprivate let notificationsLabel = LabelField()
    fileprivate let unreadLabel = LabelField()
    
    init() {
        super.init(frame: NSZeroRect)
        
        notificationsLabel.verticalAlignment = .center
        notificationsLabel.font = CurrentTheme.feed.notificationsBar.font
        notificationsLabel.textColor = CurrentTheme.feed.notificationsBar.fontColor
        notificationsLabel.stringValue = "Notifications"
        self.addSubview(notificationsLabel)
        notificationsLabel.snp.makeConstraints { make in
            make.leading.equalTo(8)
            make.centerY.equalTo(self).offset(-1)
            make.width.equalTo(200)
            make.height.equalTo(self)
        }
        
        unreadLabel.verticalAlignment = .center
        unreadLabel.alignment = .right
        unreadLabel.font = CurrentTheme.feed.notificationsBar.font
        unreadLabel.textColor = CurrentTheme.feed.notificationsBar.fontColor
        self.addSubview(unreadLabel)
        unreadLabel.snp.makeConstraints { make in
            make.trailing.equalTo(-8)
            make.centerY.equalTo(self).offset(-1)
            make.width.equalTo(150)
            make.height.equalTo(self)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    func update(backgroundColor1: NSColor, backgroundColor2: NSColor, unreadCount: Int) {
        self.backgroundColor1 = backgroundColor1
        self.backgroundColor2 = backgroundColor2
        self.unreadCount = unreadCount
        
        unreadLabel.stringValue = "\(unreadCount) new"
        unreadLabel.alphaValue = unreadCount == 0 ? 0.7 : 1.0
        
        self.needsDisplay = true
    }
    
    fileprivate override func draw(_ dirtyRect: NSRect) {
        //// Gradient Declarations
        let notificationsHeaderGradient = NSGradient(starting: backgroundColor1, ending: backgroundColor2)!
        
        //// headerBase Drawing
        let headerBasePath = NSBezierPath()
        headerBasePath.move(to: NSMakePoint(0, 1.5))
        headerBasePath.curve(to: NSMakePoint(1.5, 0), controlPoint1: NSMakePoint(-0, 0.67), controlPoint2: NSMakePoint(0.67, 0))
        headerBasePath.line(to: NSMakePoint(398.5, 0))
        headerBasePath.curve(to: NSMakePoint(400, 1.5), controlPoint1: NSMakePoint(399.33, -0), controlPoint2: NSMakePoint(400, 0.67))
        headerBasePath.line(to: NSMakePoint(400, 12))
        headerBasePath.line(to: NSMakePoint(0, 12))
        headerBasePath.line(to: NSMakePoint(0, 1.5))
        headerBasePath.close()
        headerBasePath.move(to: NSMakePoint(0, 12))
        headerBasePath.line(to: NSMakePoint(400, 12))
        headerBasePath.line(to: NSMakePoint(400, 20))
        headerBasePath.curve(to: NSMakePoint(396, 24), controlPoint1: NSMakePoint(400, 22.21), controlPoint2: NSMakePoint(398.21, 24))
        headerBasePath.line(to: NSMakePoint(4, 24))
        headerBasePath.curve(to: NSMakePoint(0, 20), controlPoint1: NSMakePoint(1.79, 24), controlPoint2: NSMakePoint(0, 22.21))
        headerBasePath.line(to: NSMakePoint(0, 12))
        headerBasePath.close()
        notificationsHeaderGradient.draw(in: headerBasePath, angle: -90)
    }
}
