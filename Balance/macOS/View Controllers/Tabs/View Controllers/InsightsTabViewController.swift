//
//  InsightsTabViewController.swift
//  Bal
//
//  Created by Benjamin Baron on 8/11/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Cocoa
import SnapKit
import MapKit
import Crashlytics

class InsightsTabViewController: NSViewController, InsightsTabViewModelDelegate, NSTextFieldDelegate, TextFieldDelegate, SectionedTableViewDelegate, SectionedTableViewDataSource {
    
    struct InternalNotifications {
        static let CellOpened            = Notification.Name("InsightsCellOpened")
        static let CellClosed            = Notification.Name("InsightsCellClosed")
        static let PerformMerchantSearch = Notification.Name("InsightsPerformMerchantSearch")
        
        struct Keys {
            static let Cell         = "Cell"
            static let SearchString = "SearchString"
        }
    }
    
    //
    // MARK: - Properties -
    //

    let viewModel = InsightsTabViewModel()
    var previousSelectedIndex = TableIndex.none
    
    // MARK: Header
    let headerView = View()
    let modeSegmentedControl = NSSegmentedControl()
    let rangePopUpButton = NSPopUpButton()
    let searchField = TokenSearchField()
    
    // MARK: Body
    let scrollView = ScrollView()
    let tableView = SectionedTableView()
    let noResultsField = LabelField()
    
    // MARK: Footer
    let footerView = VisualEffectView()
    let totalField = LabelField()
    let transactionCountField = LabelField()
    
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
            AppDelegate.sharedInstance.resizeWindowToMaxHeight(animated: true)
        }
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        removeSearchShortcutMonitor()
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
        createFooter()
    }
    
    func createHeader() {
        if debugging.showSearchBarForInsights {
            searchField.delegate = self
            searchField.customDelegate = self
            self.view.addSubview(searchField)
            searchField.font = CurrentTheme.transactions.cell.nameFont
            searchField.snp.makeConstraints { make in
                make.top.equalTo(self.view)
                make.leading.equalTo(self.view).inset(10)
                make.trailing.equalTo(self.view).inset(10)
            }
        }
        
        headerView.layerBackgroundColor = NSColor(deviceRedInt: 112, green: 117, blue: 122, alpha: 0.4)
        self.view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            if debugging.showSearchBarForInsights {
                make.top.equalTo(searchField.snp.bottom).offset(12)
            } else {
                make.top.equalTo(self.view).offset(10)
            }
            make.leading.equalTo(self.view)
            make.trailing.equalTo(self.view)
            make.height.equalTo(34)
        }
        
        modeSegmentedControl.segmentCount = 2
        modeSegmentedControl.selectedSegment = 0
        let segmentLabels = InsightsTabViewModel.DisplayMode.displayModeStrings()
        modeSegmentedControl.setLabel(segmentLabels[0], forSegment: 0)
        modeSegmentedControl.setLabel(segmentLabels[1], forSegment: 1)
        modeSegmentedControl.target = self
        modeSegmentedControl.action = #selector(displayModeChanged(_:))
        headerView.addSubview(modeSegmentedControl)
        modeSegmentedControl.snp.makeConstraints { make in
            make.centerY.equalTo(headerView)
            make.leading.equalTo(headerView).inset(11)
            make.width.equalTo(246)
        }
        
        rangePopUpButton.addItems(withTitles: InsightsTabViewModel.TopMerchantsRange.strings())
        rangePopUpButton.target = self
        rangePopUpButton.action = #selector(rangeChanged(_:))
        headerView.addSubview(rangePopUpButton)
        rangePopUpButton.snp.makeConstraints { make in
            make.centerY.equalTo(headerView)
            make.trailing.equalTo(headerView).inset(11)
            make.width.equalTo(120)
        }
    }
    
    func createTable() {
        noResultsField.alignment = .center
        noResultsField.font = CurrentTheme.transactions.cell.nameFont
        noResultsField.textColor = CurrentTheme.defaults.foregroundColor
        noResultsField.usesSingleLineMode = false
        noResultsField.alphaValue = 0.0
        self.view.addSubview(noResultsField)
        noResultsField.snp.makeConstraints { make in
            make.leading.equalTo(self.view).inset(5)
            make.trailing.equalTo(self.view).inset(5)
            make.top.equalTo(headerView.snp.bottom).offset(20)
            make.height.equalTo(60)
        }
        
        scrollView.documentView = tableView
        scrollView.contentInsets = NSEdgeInsetsMake(0, 0, 30, 0)
        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.equalTo(self.view)
            make.trailing.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        
        tableView.customDelegate = self
        tableView.customDataSource = self
        tableView.displaySectionRows = false
        // TODO: intercellSpacing doesn't seem to allow values lower than 1, so it's rendering as 2 pixels on retina
        tableView.intercellSpacing = CurrentTheme.defaults.cell.intercellSpacing
        tableView.gridColor = CurrentTheme.defaults.cell.spacerColor
        tableView.gridStyleMask = NSTableView.GridLineStyle.solidHorizontalGridLineMask
        tableView.rowHeight = 5000 // Hide grid lines on empty cells
        tableView.selectionHighlightStyle = .none
        
        tableView.reloadData()
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
        transactionCountField.font = CurrentTheme.transactions.cell.nameFont
        transactionCountField.textColor = CurrentTheme.defaults.foregroundColor
        transactionCountField.usesSingleLineMode = true
        footerView.addSubview(transactionCountField)
        transactionCountField.snp.makeConstraints { make in
            make.leading.equalTo(footerView).offset(10)
            make.centerY.equalTo(footerView).offset(-1)
        }
        
        totalField.font = CurrentTheme.transactions.cell.nameFont
        totalField.alignment = .right
        totalField.usesSingleLineMode = true
        footerView.addSubview(totalField)
        totalField.snp.makeConstraints { make in
            make.trailing.equalTo(footerView).inset(12)
            make.centerY.equalTo(footerView).offset(-1)
        }
    }
    
    fileprivate var noResultsDateFormatter = DateFormatter()
    fileprivate func showNoResultsField() {
        // Only show for top merchants, since new merchants will always have data
        if viewModel.displayMode == .topMerchants {
            let now = Date()
            var stringValue = ""
            switch viewModel.topMerchantsRange {
            case .thisWeek:
                if now.isFirstDayOfWeek {
                    stringValue = "Today is the first day of the week.\nYou haven't spent any money yet!"
                } else {
                    noResultsDateFormatter.dateFormat = "EEEE, MMM d"
                    let dateString = noResultsDateFormatter.string(from: Date.firstDayOfWeek())
                    stringValue = "You haven't spent any money this week,\nbetween \(dateString) and today."
                }
            case .thisMonth:
                if now.isFirstDayOfMonth {
                    stringValue = "Today is the first day of the month.\nYou haven't spent any money yet!"
                } else {
                    noResultsDateFormatter.dateFormat = "EEEE, MMM d"
                    let dateString = noResultsDateFormatter.string(from: Date.firstOfMonth())
                    stringValue = "You haven't spent any money this month,\nbetween \(dateString) and today."
                }
            case .thisYear:
                if now.isFirstDayOfYear {
                    stringValue = "Today is the first day of the year.\nYou haven't spent any money yet!"
                } else {
                    stringValue = "You haven't spent any money this year. Wow!"
                }
            case .past30Days:
                stringValue = "You haven't spent any money in the past 30 days."
            case .past90Days:
                stringValue = "You haven't spent any money in the past 90 days."
            case .allTime:
                stringValue = "You haven't spent any money ever.\nAre you sure you need this app?"
            }
            
            noResultsField.stringValue = stringValue
            self.noResultsField.animator().alphaValue = 1.0
        }
    }
    
    fileprivate func hideNoResultsField() {
        if noResultsField.alphaValue > 0.0 {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.8
                self.noResultsField.animator().alphaValue = 0.0
            }, completionHandler: nil)
        }
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
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(performMerchantSearch(_:)), name: InternalNotifications.PerformMerchantSearch)
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(popoverWillShow(_:)), name: Notifications.PopoverWillShow)
    }
    
    fileprivate func unregisterForNotifications() {
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.InstitutionAdded)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.InstitutionRemoved)
        
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.AccountHidden)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.AccountUnhidden)
        
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.SyncCompleted)
        
        NotificationCenter.removeObserverOnMainThread(self, name: InternalNotifications.PerformMerchantSearch)
        
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
    
    @objc fileprivate func popoverWillShow(_ notification: Notification) {
        if viewModel.dataChangedInBackground {
            viewModel.dataChangedInBackground = false
            async(after: 0.75) {
                self.reloadData()
            }
        }
    }
    
    fileprivate func reloadDataIfInForeground() {
        if AppDelegate.sharedInstance.statusItem.isStatusItemWindowVisible {
            reloadData()
        } else {
            viewModel.dataChangedInBackground = true
        }
    }
    
    fileprivate func reloadData() {
        viewModel.reloadData()
    }
    
    func reloadDataFinished() {
        tableView.reloadData()
        
        if viewModel.displayMode == .topMerchants {
            updateFooter()
            showFooter()
        }
    }
    
    func selectRange(index: Int) {
        rangePopUpButton.selectItem(at: index)
        rangeChanged(rangePopUpButton)
    }

    @objc fileprivate func performMerchantSearch(_ notification: Notification) {
        if let userInfo = notification.userInfo, let searchString = userInfo[InternalNotifications.Keys.SearchString] as? String {
            viewModel.performMerchantSearch(searchString: searchString)
        }
    }
    
    //
    // MARK: - Mode Selection -
    //
    
    @objc func displayModeChanged(_ sender: NSSegmentedControl) {
        if let mode = InsightsTabViewModel.DisplayMode(rawValue: sender.selectedSegment) {
            if viewModel.displayMode != mode {
                viewModel.displayMode = mode
                previousSelectedIndex = TableIndex.none
                cancelAllSearches()
                
                rangePopUpButton.removeAllItems()
                switch mode {
                case .topMerchants:
                    tableView.displaySectionRows = false
                    rangePopUpButton.addItems(withTitles: InsightsTabViewModel.TopMerchantsRange.strings())
                    rangePopUpButton.selectItem(at: viewModel.topMerchantsRange.rawValue)
                    
                    if viewModel.topMerchantsData[viewModel.topMerchantsRange.rawValue].count == 0 {
                        showNoResultsField()
                    } else {
                        hideNoResultsField()
                    }
                    
                    updateFooter()
                    showFooter()
                    
                    // Analytics
                    Answers.logContentView(withName: "Insights tab display mode changed top merchants", contentType: nil, contentId: nil, customAttributes: nil)
                case .newMerchants:
                    hideNoResultsField()
                    tableView.displaySectionRows = true
                    rangePopUpButton.addItems(withTitles: InsightsTabViewModel.NewMerchantsRange.strings())
                    rangePopUpButton.selectItem(at: viewModel.newMerchantsRange.rawValue)
                    
                    hideFooter()
                    
                    // Analytics
                    Answers.logContentView(withName: "Insights tab display mode changed new merchants", contentType: nil, contentId: nil, customAttributes: nil)
                }
            
                tableView.reloadData()
                
                self.invalidateTouchBar()
            }
        }
    }
    
    @objc func rangeChanged(_ sender: NSPopUpButton) {
        switch viewModel.displayMode {
        case .topMerchants:
            if let range = InsightsTabViewModel.TopMerchantsRange(rawValue: sender.indexOfSelectedItem) {
                if viewModel.topMerchantsRange != range {
                    viewModel.topMerchantsRange = range
                    if viewModel.searching {
                        performSearchNow(animated: false)
                    } else {
                        tableView.reloadData()
                    }
                    
                    updateFooter()
                    
                    if viewModel.topMerchantsData[viewModel.topMerchantsRange.rawValue].count == 0 {
                        showNoResultsField()
                    } else {
                        hideNoResultsField()
                    }
                }
            }
        case .newMerchants:
            if let range = InsightsTabViewModel.NewMerchantsRange(rawValue: sender.indexOfSelectedItem) {
                if viewModel.newMerchantsRange != range {
                    viewModel.newMerchantsRange = range
                    if viewModel.searching {
                        performSearchNow(animated: false)
                    } else {
                        tableView.reloadData()
                    }
                }
            }
        }
    }
    
    fileprivate func showFooter() {
        footerView.snp.updateConstraints { make in
            make.height.equalTo(32)
        }
    }
    
    fileprivate func hideFooter() {
        footerView.snp.updateConstraints { make in
            make.height.equalTo(0)
        }
    }
    
    fileprivate func updateFooter() {
        if viewModel.displayMode == .topMerchants {
            let data = viewModel.topMerchantsData[viewModel.topMerchantsRange.rawValue]
            
            transactionCountField.stringValue = "\(data.count) MERCHANTS"
            
            let totalCents = data.reduce(0, {$0 + $1.amountTotal})
            totalField.stringValue = centsToString(totalCents)
        }
    }
    
    //
    // MARK: - Search -
    //
    
    func textFieldDidBecomeFirstResponder(_ textField: NSTextField) {
        // Analytics
        Answers.logContentView(withName: "Insights tab search started", contentType: nil, contentId: nil, customAttributes: nil)
    }
    
    func cancelAllSearches() {
        viewModel.reloadAfterSearch = false
        viewModel.searching = false
        searchField.stringValue = ""
        
        viewModel.newMerchantsData = viewModel.unfilteredNewMerchantsData
        viewModel.lastNewMerchantsSearch = viewModel.newMerchantsData[viewModel.newMerchantsRange.rawValue]
        viewModel.topMerchantsData = viewModel.unfilteredTopMerchantsData
        viewModel.lastTopMerchantsSearch = viewModel.topMerchantsData[viewModel.topMerchantsRange.rawValue]
        
        self.view.window?.makeFirstResponder(self.view)
    }

    override func controlTextDidChange(_ obj: Notification) {
        searchField.attributedStringValue = Search.styleSearchString(searchField.stringValue)
        performSearchDelayed()
    }
    
    fileprivate let searchDelay: Double = 0.25
    func performSearchDelayed() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearchNowAnimated), object: nil)
        self.perform(#selector(performSearchNowAnimated), with: nil, afterDelay: searchDelay)
    }
    
    @objc func performSearchNowAnimated() {
        performSearchNow(animated: true)
    }
    
    @objc func performSearchNow(animated: Bool) {
        viewModel.searching = true
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearchNow), object: nil)
        
        if viewModel.displayMode == .topMerchants {
            if previousSelectedIndex.section >= 0 {
                tableView.deselectIndex(previousSelectedIndex)
                tableView.noteHeightOfIndex(previousSelectedIndex)
                previousSelectedIndex = TableIndex.none
                NotificationCenter.postOnMainThread(name: InternalNotifications.CellClosed)
            }
            
            let dataIndex = viewModel.topMerchantsRange.rawValue
            
            // Perform the search
            if searchField.stringValue.isEmpty {
                viewModel.searching = false
                viewModel.topMerchantsData[dataIndex] = viewModel.unfilteredTopMerchantsData[dataIndex]
                
                if viewModel.reloadAfterSearch {
                    reloadData()
                }
            } else {
                let searchString = searchField.stringValue.lowercased()
                viewModel.topMerchantsData[dataIndex] = Search.filterTransactions(data: viewModel.unfilteredTopMerchantsData[dataIndex], searchString: searchString)
            }
            
            updateNumberOfTransactionsAndTotal()
            
            tableView.updateRows(oldObjects: viewModel.lastTopMerchantsSearch as NSArray, newObjects: viewModel.topMerchantsData[dataIndex] as NSArray, animationOptions: [NSTableView.AnimationOptions.effectFade, NSTableView.AnimationOptions.slideDown])
            
            tableView.scrollToBeginningOfDocument(nil)
            viewModel.lastTopMerchantsSearch = viewModel.topMerchantsData[dataIndex]
            
            let alphaValue = CGFloat(viewModel.topMerchantsData[dataIndex].count == 0 ? 1.0 : 0.0)
            if noResultsField.alphaValue != alphaValue {
                if alphaValue == 0.0 {
                    self.noResultsField.animator().alphaValue = alphaValue
                } else {
                    NSAnimationContext.runAnimationGroup({ context in
                        context.duration = 0.8
                        self.noResultsField.animator().alphaValue = alphaValue
                    }, completionHandler: nil)
                }
            }
            
            if viewModel.searching && viewModel.topMerchantsData[dataIndex].count > 0 {
                footerView.snp.updateConstraints { make in
                    make.height.equalTo(32)
                }
            } else {
                footerView.snp.updateConstraints { make in
                    make.height.equalTo(0)
                }
            }
        } else if viewModel.displayMode == .newMerchants {
            if previousSelectedIndex.section >= 0 {
                tableView.deselectIndex(previousSelectedIndex)
                tableView.noteHeightOfIndex(previousSelectedIndex)
                previousSelectedIndex = TableIndex.none
                NotificationCenter.postOnMainThread(name: InternalNotifications.CellClosed)
            }
            
            let dataIndex = viewModel.newMerchantsRange.rawValue
            
            // Perform the search
            if searchField.stringValue.isEmpty {
                viewModel.searching = false
                viewModel.newMerchantsData[dataIndex] = viewModel.unfilteredNewMerchantsData[dataIndex]
                
                if viewModel.reloadAfterSearch {
                    reloadData()
                }
            } else {
                let searchString = searchField.stringValue.lowercased()
                viewModel.newMerchantsData[dataIndex] = Search.filterTransactions(data: viewModel.unfilteredNewMerchantsData[dataIndex], searchString: searchString).transactions
            }
            
            updateNumberOfTransactionsAndTotal()
            
            if animated {
                tableView.updateRows(oldObjects: viewModel.lastNewMerchantsSearch.flattened as NSArray, newObjects: viewModel.newMerchantsData[dataIndex].flattened as NSArray, animationOptions: [NSTableView.AnimationOptions.effectFade, NSTableView.AnimationOptions.slideDown])
            } else {
                tableView.reloadData()
            }
            
            tableView.scrollToBeginningOfDocument(nil)
            viewModel.lastNewMerchantsSearch = viewModel.newMerchantsData[dataIndex]
            
            let alphaValue = CGFloat(viewModel.newMerchantsData[dataIndex].count == 0 ? 1.0 : 0.0)
            if noResultsField.alphaValue != alphaValue {
                if alphaValue == 0.0 {
                    self.noResultsField.animator().alphaValue = alphaValue
                } else {
                    NSAnimationContext.runAnimationGroup({ context in
                        context.duration = 0.8
                        self.noResultsField.animator().alphaValue = alphaValue
                        }, completionHandler: nil)
                }
            }
            
            if viewModel.searching && viewModel.newMerchantsData[dataIndex].count > 0 {
                footerView.snp.updateConstraints { make in
                    make.height.equalTo(32)
                }
            } else {
                footerView.snp.updateConstraints { make in
                    make.height.equalTo(0)
                }
            }
        }
        
        self.view.layoutSubtreeIfNeeded()
    }
    
    func updateNumberOfTransactionsAndTotal() {
        var runningTotal: Int = 0
        var numberOfTransactions: Int = 0
        
        if viewModel.displayMode == .topMerchants {
            let data = viewModel.topMerchantsData[viewModel.topMerchantsRange.rawValue]
            for merchant in data {
                runningTotal = runningTotal + merchant.amountTotal
                numberOfTransactions += 1
            }
        } else if viewModel.displayMode == .newMerchants {
            let data = viewModel.newMerchantsData[viewModel.newMerchantsRange.rawValue]
            for date in data.keys {
                if let transactions = data[date] {
                    for transaction in transactions {
                        runningTotal = runningTotal + transaction.amount
                        numberOfTransactions += 1
                    }
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
        let cell = tableView.viewAtIndex(selectedIndex, makeIfNecessary: false) as? ContainerCell
        
        if previousSelectedIndex == selectedIndex {
            cell?.hideBottomContainer(notify: true)
            tableView.deselectIndex(selectedIndex)
            tableView.noteHeightOfIndex(selectedIndex)
            previousSelectedIndex = TableIndex.none
        } else {
            var previousCell: TransactionCell?
            var indexes = [selectedIndex]
            if previousSelectedIndex.section >= 0 {
                previousCell = tableView.viewAtIndex(previousSelectedIndex, makeIfNecessary: false) as? TransactionCell
                indexes.append(previousSelectedIndex)
            }
            previousSelectedIndex = selectedIndex
            
            previousCell?.hideBottomContainer(notify: false)
            
            // Dispatch async so that it runs in the next run loop, otherwise the showBottomContainer() call will animate
            async(after: 0.1) {
                cell?.showBottomContainer()
                tableView.noteHeightOfIndexes(indexes)
                
                let visibleIndexes = self.tableView.visibleIndexes
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
        return CurrentTheme.transactions.headerCell.height
    }
    
    func tableView(_ tableView: SectionedTableView, heightOfRow row: Int, inSection section: Int) -> CGFloat {
        switch viewModel.displayMode {
        case .topMerchants:
            if TableIndex(section: section, row: row) == tableView.selectedIndex {
                return CurrentTheme.transactions.cell.height + 30.0
            } else {
                return CurrentTheme.transactions.cell.height
            }
        case .newMerchants:
            if TableIndex(section: section, row: row) == tableView.selectedIndex, let transactions = viewModel.newMerchantsData[viewModel.newMerchantsRange.rawValue][section] {
                let transaction = transactions[row]
                var extraHeight: CGFloat = 0.0
                if transaction.hasLocation {
                    extraHeight = 207.0
                } else {
                    if transaction.categoryId == nil {
                        extraHeight = 56.0
                    } else {
                        extraHeight = 85.0
                    }
                }
                return CurrentTheme.transactions.cell.height + extraHeight
            } else {
                return CurrentTheme.transactions.cell.height
            }
        }
    }
    
    func tableView(_ tableView: SectionedTableView, rowViewForSection section: Int) -> NSTableRowView? {
        var row = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Group Row"), owner: self) as? NSTableRowView
        if row == nil {
            row = TableRowView()
            row?.identifier = NSUserInterfaceItemIdentifier(rawValue: "Group Row")
        }
        return row
    }
    
    func tableView(_ tableView: SectionedTableView, rowViewForRow row: Int, inSection section: Int) -> NSTableRowView? {
        var row = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Item Row"), owner: self) as? HoverTableRowView
        if row == nil {
            row = HoverTableRowView()
            row?.identifier = NSUserInterfaceItemIdentifier(rawValue: "Item Row")
            row?.color = CurrentTheme.defaults.cell.backgroundColor
            row?.hoverColor = CurrentTheme.defaults.cell.hoverBackgroundColor
        }
        return row
    }
    
    func tableView(_ tableView: SectionedTableView, viewForSection section: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Group Cell"), owner: self) as? GroupCell ?? GroupCell()
        cell.identifier = NSUserInterfaceItemIdentifier(rawValue: "Group Cell")
        cell.section = -1
        
        let date = viewModel.newMerchantsData[viewModel.newMerchantsRange.rawValue].keys[section]
        cell.updateModel(date, range: viewModel.newMerchantsRange)
        
        return cell
    }
    
    func tableView(_ tableView: SectionedTableView, viewForRow row: Int, inSection section: Int) -> NSView? {
        switch viewModel.displayMode {
        case .topMerchants:
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Merchant Cell"), owner: self) as? MerchantCell ?? MerchantCell()
            cell.identifier = NSUserInterfaceItemIdentifier(rawValue: "Merchant Cell")
            cell.index = TableIndex(section: section, row: row)
            let merchant = viewModel.topMerchantsData[viewModel.topMerchantsRange.rawValue][row]
            cell.updateModel(merchant, maxAmount: viewModel.topMerchantsMaxAmounts[viewModel.topMerchantsRange.rawValue])
            return cell
        case .newMerchants:
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Transaction Cell"), owner: self) as? TransactionCell ?? TransactionCell()
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
            
            let transaction = viewModel.newMerchantsData[viewModel.newMerchantsRange.rawValue][section]![row]
            cell.updateModel(transaction)
            cell.index = TableIndex(section: section, row: row)
            
            let selectedIndex = tableView.selectedIndex
            if selectedIndex != TableIndex.none {
                cell.alphaValue = cell.index == selectedIndex ? 1.0 : CurrentTheme.transactions.cell.dimmedAlpha
            }
            
            return cell
        }
    }
    
    // MARK: Table Cells
    
    fileprivate class GroupCell: View {
        var section = -1
        
        //        let blurryView = VisualEffectView()
        let blurryView = View()
        let dateField = LabelField()
        
        init() {
            super.init(frame: NSZeroRect)
            
            //            blurryView.blendingMode = .withinWindow
            //            blurryView.material = CurrentTheme.defaults.material
            blurryView.wantsLayer = true
            //            blurryView.state = .active
            blurryView.layerBackgroundColor = CurrentTheme.feed.headerCell.backgroundColor
            self.addSubview(blurryView)
            blurryView.snp.makeConstraints { make in
                make.leading.equalTo(self)
                make.trailing.equalTo(self)
                make.top.equalTo(self)
                make.bottom.equalTo(self)
            }
            
            dateField.font = CurrentTheme.feed.headerCell.dateFont
            dateField.textColor = CurrentTheme.feed.headerCell.dateColor
            self.addSubview(dateField)
            dateField.snp.makeConstraints { make in
                make.centerX.equalTo(self)
                make.centerY.equalTo(self).offset(1)
                make.height.equalTo(14)
            }
        }

        
        required init?(coder: NSCoder) {
            fatalError("unsupported")
        }
        
        fileprivate let dateFormatter = DateFormatter()
        func updateModel(_ model: Date, range: InsightsTabViewModel.NewMerchantsRange) {
            var dateString = ""
            
            if range == .eachWeek {
                let now = Date()
                let endDate = model.addingTimeInterval(3600.0 * 24 * 6)
                
                if (endDate as NSDate).laterDate(now) == endDate {
                    dateString = "This Week"
                } else if model.isLastWeek {
                    dateString = "Last Week"
                } else {
                    dateFormatter.dateFormat = (model.isThisYear ? "MMM d" : "MMM d y")
                    dateString = "\(dateFormatter.string(from: model)) - \(dateFormatter.string(from: endDate))"
                }
            } else if range == .eachMonth {                
                if model.isThisMonth {
                    dateString = "This Month"
                } else if model.isLastMonth {
                    dateString = "Last Month"
                } else {
                    dateFormatter.dateFormat = (model.isThisYear ? "MMMM" : "MMMM yyyy")
                    dateString = dateFormatter.string(from: model)
                }
            }
            dateString = dateString.uppercased()
            
            dateField.attributedStringValue = NSAttributedString(string: dateString, attributes: [NSAttributedStringKey.kern: 0.82])
        }
    }
    
    // Don't respond to gestures or clicks
    fileprivate class NoHitMapView: MKMapView {
        override func hitTest(_ aPoint: NSPoint) -> NSView? {
            return nil
        }
    }
    
    fileprivate class TransactionCell: View, ContainerCell {
        var model: Transaction?
        var index = TableIndex.none
        
        let topContainer = View()
        let institutionInitialsCircleView = InstitutionInitialsCircleView()
        let amountField = LabelField()
        let centerNameField = LabelField()
        let nameField = LabelField()
        let addressField = LabelField()
        
        var bottomContainer: View!
        var categoryView: CategoryView!
        var infoContainer: View!
        var accountContainer: View!
        var institutionField: LabelField!
        var accountField: LabelField!
        var mapView: MKMapView!
        
        init() {
            super.init(frame: NSZeroRect)
            
            self.addSubview(topContainer)
            topContainer.snp.makeConstraints { make in
                make.top.equalTo(self)
                make.leading.equalTo(self)
                make.trailing.equalTo(self)
                make.height.equalTo(CurrentTheme.transactions.cell.height)
            }
            
            topContainer.addSubview(institutionInitialsCircleView)
            institutionInitialsCircleView.snp.makeConstraints { make in
                make.height.equalTo(22)
                make.centerY.equalTo(topContainer)
                make.leading.equalTo(topContainer).inset(10)
                make.width.equalTo(22)
            }
            
            amountField.backgroundColor = CurrentTheme.defaults.cell.backgroundColor
            amountField.font = CurrentTheme.transactions.cell.amountFont
            amountField.usesSingleLineMode = true
            topContainer.addSubview(amountField)
            amountField.snp.makeConstraints { make in
                make.width.equalTo(100)
                make.trailing.equalTo(topContainer).inset(12)
                make.bottom.equalTo(-14.5)
            }
            
            centerNameField.backgroundColor = CurrentTheme.defaults.cell.backgroundColor
            centerNameField.alignment = .left
            centerNameField.font = CurrentTheme.transactions.cell.nameFont
            centerNameField.textColor = CurrentTheme.defaults.foregroundColor
            centerNameField.usesSingleLineMode = true
            centerNameField.cell?.lineBreakMode = .byTruncatingTail
            topContainer.addSubview(centerNameField)
            centerNameField.snp.makeConstraints { make in
                make.leading.equalTo(institutionInitialsCircleView.snp.trailing).offset(7)
                make.trailing.equalTo(amountField.snp.leading).inset(5)
                make.centerY.equalTo(topContainer)
            }
            
            nameField.backgroundColor = CurrentTheme.defaults.cell.backgroundColor
            nameField.alignment = .left
            nameField.font = CurrentTheme.transactions.cell.nameFont
            nameField.textColor = CurrentTheme.defaults.foregroundColor
            nameField.usesSingleLineMode = true
            nameField.cell?.lineBreakMode = .byTruncatingTail
            topContainer.addSubview(nameField)
            nameField.snp.makeConstraints { make in
                make.leading.equalTo(centerNameField)
                make.trailing.equalTo(centerNameField)
                make.top.equalTo(topContainer).offset(5)
            }
            
            addressField.backgroundColor = CurrentTheme.defaults.cell.backgroundColor
            addressField.alignment = .left
            addressField.font = CurrentTheme.transactions.cell.addressFont
            addressField.textColor = CurrentTheme.transactions.cell.addressColor
            addressField.usesSingleLineMode = true
            addressField.cell?.lineBreakMode = .byTruncatingTail
            topContainer.addSubview(addressField)
            addressField.snp.makeConstraints { make in
                make.leading.equalTo(nameField)
                make.trailing.equalTo(nameField)
                make.height.equalTo(14).priority(0.1)
                make.top.equalTo(nameField.snp.bottom).offset(2)
            }
            
            NotificationCenter.addObserverOnMainThread(self, selector: #selector(cellOpened(_:)), name: InternalNotifications.CellOpened)
            NotificationCenter.addObserverOnMainThread(self, selector: #selector(cellClosed(_:)), name: InternalNotifications.CellClosed)
        }
        
        required init?(coder: NSCoder) {
            fatalError("unsupported")
        }
        
        deinit {
            NotificationCenter.removeObserverOnMainThread(self, name: InternalNotifications.CellOpened)
            NotificationCenter.removeObserverOnMainThread(self, name: InternalNotifications.CellClosed)
        }
        
        func updateModel(_ updatedModel: Transaction) {
            hideBottomContainer()
            
            model = updatedModel
            
            institutionInitialsCircleView.circleColor = updatedModel.institution?.displayColor
            institutionInitialsCircleView.stringValue = updatedModel.institution?.initials ?? ""
            
            amountField.attributedStringValue = centsToStringFormatted(-updatedModel.amount)
            if updatedModel.hasLocation, let address = updatedModel.address {
                centerNameField.stringValue = ""
                nameField.stringValue = updatedModel.displayName
                
                if let city = updatedModel.city, let state = updatedModel.state, let zip = updatedModel.zip {
                    addressField.stringValue = "\(address.capitalizedStringIfAllCaps) \(city.capitalizedStringIfAllCaps) \(state) \(zip)"
                } else {
                    addressField.stringValue = address.capitalizedStringIfAllCaps
                }
                
                centerNameField.isHidden = true
                nameField.isHidden = false
                addressField.isHidden = false
            } else {
                centerNameField.stringValue = updatedModel.displayName
                nameField.stringValue = ""
                addressField.stringValue = ""
                
                centerNameField.isHidden = false
                nameField.isHidden = true
                addressField.isHidden = true
            }
            
            self.toolTip = updatedModel.displayName
        }
        
        func showBottomContainer() {
            guard bottomContainer == nil, let model = model else {
                return
            }
            
            let userInfo = [InternalNotifications.Keys.Cell: self]
            NotificationCenter.postOnMainThread(name: InternalNotifications.CellOpened, object: nil, userInfo: userInfo)
            
            let hasCategory = (model.categoryId != nil)
            
            bottomContainer = View()
            bottomContainer.cornerRadius = 5.0
            self.addSubview(bottomContainer)
            bottomContainer.snp.makeConstraints { make in
                make.top.equalTo(topContainer.snp.bottom)
                make.leading.equalTo(institutionInitialsCircleView)
                make.trailing.equalTo(amountField)
                make.height.equalTo(200)
            }
            
            infoContainer = View()
            infoContainer.cornerRadius = 5.0
            bottomContainer.addSubview(infoContainer)
            infoContainer.snp.makeConstraints { make in
                make.leading.equalTo(bottomContainer)
                make.trailing.equalTo(bottomContainer)
                make.top.equalTo(bottomContainer).offset(1)
                make.bottom.equalTo(bottomContainer)
            }
            
            accountContainer = View()
            accountContainer.cornerRadius = 5.0
            // TODO: Figure out why this shadow won't draw
            //accountContainer.layer?.shadowOpacity = 0.7
            //accountContainer.layer?.shadowRadius = 15.0
            //accountContainer.layer?.shadowOffset = CGSize(width: 0, height: 2)
            infoContainer.addSubview(accountContainer)
            accountContainer.snp.makeConstraints { make in
                make.leading.equalTo(infoContainer)
                make.trailing.equalTo(infoContainer)
                make.top.equalTo(infoContainer)
                make.height.equalTo(50)
            }
            
            let displayColor = model.institution?.displayColor ?? NSColor.gray
            
            institutionField = LabelField()
            institutionField.backgroundColor = displayColor.withAlphaComponent(1)
            institutionField.layerBackgroundColor = displayColor.withAlphaComponent(1)
            institutionField.alignment = .center
            institutionField.verticalAlignment = .center
            institutionField.font = CurrentTheme.transactions.cellExpansion.institutionFont
            institutionField.textColor = CurrentTheme.transactions.cellExpansion.fontColor
            accountContainer.addSubview(institutionField)
            institutionField.snp.makeConstraints { make in
                make.leading.equalTo(accountContainer)
                make.trailing.equalTo(accountContainer)
                make.height.equalTo(25)
                make.top.equalTo(accountContainer)
            }
            
            accountField = LabelField()
            accountField.backgroundColor = displayColor.lighterColor.withAlphaComponent(1)
            accountField.layerBackgroundColor = displayColor.lighterColor.withAlphaComponent(1)
            accountField.alignment = .center
            accountField.verticalAlignment = .center
            accountField.font = CurrentTheme.transactions.cellExpansion.accountFont
            accountField.textColor = CurrentTheme.transactions.cellExpansion.fontColor
            accountContainer.addSubview(accountField)
            accountField.snp.makeConstraints { make in
                make.leading.equalTo(accountContainer)
                make.trailing.equalTo(accountContainer)
                make.height.equalTo(25)
                make.top.equalTo(institutionField.snp.bottom)
            }
            
            if hasCategory {
                categoryView = CategoryView()
                infoContainer.addSubview(categoryView)
                categoryView.buttonHandler = { name in
                    let token = SearchToken.category.rawValue
                    let searchString = "\(token):(\(name))"
                    NotificationCenter.postOnMainThread(name: Notifications.PerformSearch, object: nil, userInfo: [Notifications.Keys.SearchString: searchString])
                }
            }
            
            
            if model.hasLocation, let latitude = model.latitude, let longitude = model.longitude {
                accountContainer.cornerRadius = 0.0
                
                mapView = NoHitMapView()
                mapView.wantsLayer = true
                mapView.isZoomEnabled = false
                mapView.isScrollEnabled = false
                mapView.isPitchEnabled = false
                mapView.isRotateEnabled = false
                infoContainer.addSubview(mapView, positioned: .below, relativeTo: accountContainer)
                mapView.snp.makeConstraints { make in
                    make.leading.equalTo(bottomContainer)
                    make.trailing.equalTo(bottomContainer)
                    make.top.equalTo(bottomContainer)
                    make.bottom.equalTo(bottomContainer)
                }
                
                var coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let annotation = Annotation(coordinate: coordinate)
                mapView.addAnnotation(annotation)
                let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                coordinate.latitude += 0.0025
                let region = MKCoordinateRegion(center: coordinate, span: span)
                mapView.setRegion(region, animated: false)
                
                if hasCategory {
                    categoryView.snp.makeConstraints { make in
                        make.bottom.equalTo(infoContainer)
                        make.leading.equalTo(infoContainer)
                        make.trailing.equalTo(infoContainer)
                        make.height.equalTo(30)
                    }
                }
            } else if hasCategory {
                categoryView.snp.makeConstraints { make in
                    make.top.equalTo(accountContainer.snp.bottom).offset(3)
                    make.leading.equalTo(institutionInitialsCircleView).offset(-5)
                    make.trailing.equalTo(infoContainer)
                    make.height.equalTo(30)
                }
            }
            
            categoryView?.category = model.category
            institutionField.stringValue = model.institution!.name
            accountField.stringValue = model.account!.name
        }
        
        func hideBottomContainer(notify: Bool = true) {
            if bottomContainer != nil {
                if notify {
                    NotificationCenter.postOnMainThread(name: InternalNotifications.CellClosed)
                }
                
                bottomContainer?.removeFromSuperview()
                bottomContainer = nil
                categoryView = nil
                infoContainer = nil
                accountContainer = nil
                institutionField = nil
                accountField = nil
                mapView = nil
            }
        }
        
        @objc fileprivate func cellOpened(_ notification: Notification) {
            if let cell = notification.userInfo?[InternalNotifications.Keys.Cell] as? TransactionCell {
                self.animator().alphaValue = cell == self ? 1.0 : CurrentTheme.transactions.cell.dimmedAlpha
            }
        }
        
        @objc fileprivate func cellClosed(_ notification: Notification) {
            self.animator().alphaValue = 1.0
        }
        
        override func rightMouseDown(with theEvent: NSEvent) {
            if let model = model {
                TransactionContextMenu.showMenu(transaction: model, view: self)
            }
        }
    }
    
    fileprivate class Annotation: NSObject, MKAnnotation {
        @objc var coordinate: CLLocationCoordinate2D
        
        init(coordinate: CLLocationCoordinate2D) {
            self.coordinate = coordinate
        }
    }
    
    fileprivate class MerchantCell: View, ContainerCell {
        var model: Merchant?
        var index = TableIndex.none
        
        let topContainer = View()
        let amountField = LabelField()
        let colorBar = View()
        let nameField = LabelField()
        let addressField = LabelField()
        
        var bottomContainer: View!
        var searchTransactionsButton: Button!
        
        init() {
            super.init(frame: NSZeroRect)
            
            self.addSubview(topContainer)
            topContainer.snp.makeConstraints { make in
                make.top.equalTo(self)
                make.leading.equalTo(self)
                make.trailing.equalTo(self)
                make.height.equalTo(CurrentTheme.transactions.cell.height)
            }

            amountField.backgroundColor = CurrentTheme.defaults.cell.backgroundColor
            amountField.font = CurrentTheme.transactions.cell.amountFont
            amountField.usesSingleLineMode = true
            topContainer.addSubview(amountField)
            amountField.snp.makeConstraints { make in
                make.top.equalTo(topContainer).offset(5)
                make.width.equalTo(100)
                make.trailing.equalTo(topContainer).inset(12)
            }
            
            let colorBarHeight = 10.0
            colorBar.cornerRadius = Float(colorBarHeight / 2.0)
            colorBar.layerBackgroundColor = NSColor.red
            topContainer.addSubview(colorBar)
            colorBar.snp.makeConstraints { make in
                make.trailing.equalTo(topContainer).inset(12)
                make.height.equalTo(colorBarHeight)
                make.width.equalTo(100)
                make.top.equalTo(amountField.snp.bottom).offset(2)
            }
            
            nameField.backgroundColor = CurrentTheme.defaults.cell.backgroundColor
            nameField.alignment = .left
            nameField.font = CurrentTheme.transactions.cell.nameFont
            nameField.textColor = CurrentTheme.defaults.foregroundColor
            nameField.usesSingleLineMode = true
            nameField.cell?.lineBreakMode = .byTruncatingTail
            topContainer.addSubview(nameField)
            nameField.snp.makeConstraints { make in
                make.leading.equalTo(topContainer).offset(12)
                make.trailing.equalTo(amountField.snp.leading).offset(-5)
                make.top.equalTo(topContainer).offset(5)
            }
            
            addressField.backgroundColor = CurrentTheme.defaults.cell.backgroundColor
            addressField.alignment = .left
            addressField.font = CurrentTheme.transactions.cell.addressFont
            addressField.textColor = CurrentTheme.transactions.cell.addressColor
            addressField.usesSingleLineMode = true
            addressField.cell?.lineBreakMode = .byTruncatingTail
            topContainer.addSubview(addressField)
            addressField.snp.makeConstraints { make in
                make.leading.equalTo(nameField)
                make.trailing.equalTo(nameField).offset(-5)
                make.height.equalTo(14).priority(0.1)
                make.top.equalTo(nameField.snp.bottom).offset(2)
            }
            
            NotificationCenter.addObserverOnMainThread(self, selector: #selector(cellOpened(_:)), name: InternalNotifications.CellOpened)
            NotificationCenter.addObserverOnMainThread(self, selector: #selector(cellClosed(_:)), name: InternalNotifications.CellClosed)
        }
        
        required init?(coder: NSCoder) {
            fatalError("unsupported")
        }
        
        deinit {
            NotificationCenter.removeObserverOnMainThread(self, name: InternalNotifications.CellOpened)
            NotificationCenter.removeObserverOnMainThread(self, name: InternalNotifications.CellClosed)
        }
        
        func updateModel(_ updatedModel: Merchant, maxAmount: Int) {
            model = updatedModel
            
            amountField.attributedStringValue = centsToStringFormatted(-updatedModel.amountTotal)
            nameField.stringValue = "\(index.row + 1): \(updatedModel.name.capitalizedStringIfAllCaps)"
            let count = updatedModel.numberOfTransactions
            let plural = "transaction".pluralize(count)
            addressField.stringValue = "in \(count) \(plural)"
            
            let maxColorBarWidth = 100.0
            let percent = Double(updatedModel.amountTotal) / Double(maxAmount)
            let width = maxColorBarWidth * percent
            colorBar.snp.updateConstraints { make in
                make.width.equalTo(width)
            }
            
            let maxHue = 203.0 / 360.0
            let hue = CGFloat(maxHue * percent)
            let saturation = CGFloat(CurrentTheme.type == .light ? 0.75 : 0.91)
            let color = NSColor(deviceHue: hue, saturation: saturation, brightness: 1.0, alpha: 1.0)
            colorBar.layerBackgroundColor = color
        }
        
        func showBottomContainer() {
            guard bottomContainer == nil else {
                return
            }
            
            // Analytics
            Answers.logContentView(withName: "Insights tab cell expanded", contentType: nil, contentId: nil, customAttributes: nil)
            
            let userInfo = [InternalNotifications.Keys.Cell: self]
            NotificationCenter.postOnMainThread(name: InternalNotifications.CellOpened, object: nil, userInfo: userInfo)
            
            bottomContainer = View()
            self.addSubview(bottomContainer)
            bottomContainer.snp.makeConstraints { make in
                make.top.equalTo(topContainer.snp.bottom)
                make.leading.equalTo(nameField)
                make.trailing.equalTo(amountField)
                make.height.equalTo(30)
            }
            
            searchTransactionsButton = Button()
            searchTransactionsButton.bezelStyle = .texturedRounded
            let searchIcon = NSImage(named: NSImage.Name(rawValue: "search"))
            searchIcon!.size = NSSize(width: 18, height: 18)
            searchTransactionsButton.image = tintImageWithColor(searchIcon!, color: CurrentTheme.defaults.foregroundColor)
            searchTransactionsButton.imagePosition = .imageLeft
            searchTransactionsButton.title = "Search transactions"
            searchTransactionsButton.toolTip = "Search transactions"
            searchTransactionsButton.font = CurrentTheme.accounts.cellExpansion.font
            searchTransactionsButton.target = self
            searchTransactionsButton.action = #selector(searchTransactionsAction(_:))
            bottomContainer.addSubview(searchTransactionsButton)
            searchTransactionsButton.snp.makeConstraints { make in
                make.leading.equalTo(bottomContainer)
                make.top.equalTo(bottomContainer.snp.top)
                
            }
        }
        
        func hideBottomContainer(notify: Bool = true) {
            if bottomContainer != nil {
                if notify {
                    NotificationCenter.postOnMainThread(name: InternalNotifications.CellClosed)
                }
                
                bottomContainer.removeFromSuperview()
                self.bottomContainer = nil
                searchTransactionsButton = nil
            }
        }
        
        @objc fileprivate func searchTransactionsAction(_ sender: NSButton) {
            if let model = model {
                let searchString = model.name.capitalizedStringIfAllCaps
                NotificationCenter.postOnMainThread(name: InternalNotifications.PerformMerchantSearch, object: nil, userInfo: [InternalNotifications.Keys.SearchString: searchString])
            }
        }
        
        @objc fileprivate func cellOpened(_ notification: Notification) {
            if let cell = notification.userInfo?[InternalNotifications.Keys.Cell] as? MerchantCell {
                self.animator().alphaValue = cell == self ? 1.0 : CurrentTheme.accounts.cell.dimmedAlpha
            }
        }
        
        @objc fileprivate func cellClosed(_ notification: Notification) {
            self.animator().alphaValue = 1.0
        }
    }
}

private protocol ContainerCell {
    func showBottomContainer()
    func hideBottomContainer(notify: Bool)
}
