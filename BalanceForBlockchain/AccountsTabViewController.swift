//
//  AccountsTabViewController.swift
//  Bal
//
//  Created by Benjamin Baron on 2/9/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import AppKit
import SnapKit

class AccountsTabViewController: NSViewController, SectionedTableViewDelegate, SectionedTableViewDataSource, NSSearchFieldDelegate {
    
    //
    // MARK: - Properties -
    //
    
    let viewModel = AccountsTabViewModel()
    var previousSelectedIndex = TableIndex.none
    
    // MARK: Body
    let scrollView = ScrollView()
    let tableView = SectionedTableView()
    
    // MARK: Fix Password Prompt
    let fixPasswordPromptView = PaintCodeView()
    
    // MARK: Footer
    let totalFooterView = VisualEffectView()
    let balanceField = LabelField()
    let totalField = LabelField()
    
    //
    // MARK: - Lifecycle -
    //
    
    init() {
        super.init(nibName: nil, bundle: nil)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    deinit {
        unregisterForNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadData()
        
        registerForNotifications()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        adjustWindowHeight()
        
        // Fix row heights after rearranging accounts
        tableView.reloadData()
    }
    
    fileprivate var hackDelay = 0.25
    fileprivate var hackDelayCount = 2
    func adjustWindowHeight() {
        var finalHeight = CurrentTheme.defaults.size.height
        if let delegate = tableView.delegate {
            // Calculate the table rows total height
            var tableHeight: CGFloat = 200 // Account for other UI elements
            let numberOfRows = tableView.numberOfRows
            
            if numberOfRows > 0 {
                for i in 0...numberOfRows-1 {
                    tableHeight += delegate.tableView!(tableView, heightOfRow: i)
                }
            }
            
            // Calculate height
            let minHeight: CGFloat = 520
            let maxHeight: CGFloat = AppDelegate.sharedInstance.maxHeight
            var height = minHeight
            if tableHeight > minHeight && tableHeight < maxHeight {
                height = tableHeight
            } else if tableHeight >= maxHeight {
                height = maxHeight
            }
            finalHeight = height
        }
        
        // TODO: Remove delay hack. Currently there to allow for the resize to work on app launch
        DispatchQueue.main.async(after: hackDelay) {
            if self.hackDelay > 0.0 {
                self.hackDelayCount -= 1
                if self.hackDelayCount == 0 {
                    self.hackDelay = 0.0
                }
            }
            
            AppDelegate.sharedInstance.resizeWindowHeight(finalHeight, animated: true)
        }
    }
    
    //
    // MARK: - View Creation -
    //
    
    override func loadView() {
        self.view = View()
        
        createTable()
        createFixPasswordPrompt()
        //createTotalFooter()
    }
    
    func createTable() {
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.documentView = tableView
        scrollView.contentInsets = NSEdgeInsetsMake(0, 0, 110, 0)
        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(self.view).offset(10)
            make.leading.equalTo(self.view)
            make.trailing.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        
        tableView.setAccessibilityLabel("Accounts Table")
        tableView.customDelegate = self
        tableView.customDataSource = self
        tableView.displayEmptySectionRows = true
        tableView.intercellSpacing = NSZeroSize
        tableView.gridColor = NSColor.clear
        tableView.gridStyleMask = NSTableViewGridLineStyle()
        tableView.selectionHighlightStyle = .none
        
        tableView.reloadData()
    }
    
    fileprivate func createFixPasswordPrompt() {
        let fixPasswordInstitutions = Institution.institutionsWithInvalidPasswords()
        let count = fixPasswordInstitutions.count
        if count > 0 {
            for subview in fixPasswordPromptView.subviews {
                subview.removeFromSuperview()
            }
            
            let isLight = (CurrentTheme.type == .light)
            let backgroundInset = 20
            let rowInset = 12
            let headerRowHeight = 39
            let rowHeight = 44
            
            fixPasswordPromptView.isClickingEnabled = false
            fixPasswordPromptView.drawingBlock = isLight ? AccountConnectionErrors.drawConnectionErrorsLight : AccountConnectionErrors.drawConnectionErrorsDark
            self.view.addSubview(fixPasswordPromptView)
            fixPasswordPromptView.snp.makeConstraints { make in
                let height = (backgroundInset * 2) + headerRowHeight + (rowHeight * count) - 1
                make.height.equalTo(height)
                make.width.equalTo(400)
                make.centerX.equalTo(self.view)
                make.bottom.equalTo(self.view).offset(-31)
            }
            
            let containerView = View()
            fixPasswordPromptView.addSubview(containerView)
            containerView.snp.makeConstraints { make in
                make.leading.equalTo(fixPasswordPromptView).offset(backgroundInset)
                make.trailing.equalTo(fixPasswordPromptView).offset(-backgroundInset)
                make.top.equalTo(fixPasswordPromptView).offset(backgroundInset)
                make.bottom.equalTo(fixPasswordPromptView).offset(-backgroundInset)
            }
            
            let headerRow = View()
            containerView.addSubview(headerRow)
            headerRow.snp.makeConstraints { make in
                make.height.equalTo(headerRowHeight)
                make.top.equalTo(containerView)
                make.leading.equalTo(containerView).offset(rowInset)
                make.trailing.equalTo(containerView).offset(-rowInset)
            }
            
            let headerIcon = ImageView()
            headerIcon.image = isLight ? #imageLiteral(resourceName: "errorAlertLight") : #imageLiteral(resourceName: "errorAlertDark")
            headerRow.addSubview(headerIcon)
            headerIcon.snp.makeConstraints { make in
                make.width.equalTo(headerIcon.image?.size.width ?? 0)
                make.height.equalTo(headerIcon.image?.size.width ?? 0)
                make.leading.equalTo(headerRow)
                make.centerY.equalTo(headerRow)
            }
            
            let headerLabel = LabelField()
            headerLabel.stringValue = "We're having trouble connecting..."
            headerLabel.font = CurrentTheme.accounts.fixPasswordPrompt.headerFont
            headerLabel.textColor = CurrentTheme.accounts.fixPasswordPrompt.headerTextColor
            headerLabel.verticalAlignment = .center
            headerRow.addSubview(headerLabel)
            headerLabel.snp.makeConstraints { make in
                make.height.equalTo(headerRow)
                make.leading.equalTo(headerIcon.snp.trailing).offset(7)
                make.trailing.equalTo(headerRow)
                make.top.equalTo(headerRow).offset(-1)
            }
            
            var row = 0
            for institution in fixPasswordInstitutions {
                let rowView = View()
                containerView.addSubview(rowView)
                rowView.snp.makeConstraints { make in
                    make.height.equalTo(rowHeight)
                    let top = headerRowHeight + (rowHeight * row)
                    make.top.equalTo(top)
                    make.leading.equalTo(containerView).offset(rowInset)
                    make.trailing.equalTo(containerView).offset(-rowInset)
                }
                
                let colorBox = View()
                colorBox.cornerRadius = 3.0
                colorBox.layerBackgroundColor = institution.displayColor
                rowView.addSubview(colorBox)
                colorBox.snp.makeConstraints { make in
                    make.width.equalTo(10)
                    make.height.equalTo(10)
                    make.leading.equalTo(rowView).offset(1)
                    make.centerY.equalTo(rowView)
                }
                
                let reconnectButton = PaintCodeButton()
                reconnectButton.textDrawingFunction = isLight ? AccountConnectionErrors.drawReconnectButtonLight : AccountConnectionErrors.drawReconnectButtonDark
                reconnectButton.buttonText = "Reconnect"
                reconnectButton.buttonTextColor = CurrentTheme.accounts.fixPasswordPrompt.buttonTextColor
                reconnectButton.object = institution
                reconnectButton.target = self
                reconnectButton.action = #selector(reconnect(sender:))
                rowView.addSubview(reconnectButton)
                reconnectButton.snp.makeConstraints { make in
                    make.width.equalTo(82)
                    make.height.equalTo(27)
                    make.trailing.equalTo(rowView).offset(1)
                    make.centerY.equalTo(rowView)
                }
                
                let nameLabel = LabelField()
                nameLabel.stringValue = institution.name
                nameLabel.verticalAlignment = .center
                nameLabel.font = CurrentTheme.accounts.fixPasswordPrompt.nameFont
                nameLabel.textColor = CurrentTheme.accounts.fixPasswordPrompt.nameTextColor
                rowView.addSubview(nameLabel)
                nameLabel.snp.makeConstraints { make in
                    make.height.equalTo(rowView)
                    make.leading.equalTo(colorBox.snp.trailing).offset(8)
                    make.trailing.equalTo(reconnectButton.snp.leading).offset(-5)
                    make.centerY.equalTo(rowView).offset(-1)
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
        } else {
            fixPasswordPromptHide()
        }
    }
    
    fileprivate func fixPasswordPromptHide() {
        for subview in fixPasswordPromptView.subviews {
            subview.removeFromSuperview()
        }
        fixPasswordPromptView.removeFromSuperview()
    }
    
    @objc fileprivate func reconnect(sender: Button) {
//        if let institution = sender.object as? Institution {
//            if let plaidInstitution = institutionsDatabase.search(type: institution.sourceInstitutionId) {
//                let userInfo = Notifications.userInfoForPatchAccount(institution: institution, plaidInstitution: plaidInstitution)
//                NotificationCenter.postOnMainThread(name: Notifications.ShowPatchAccount, object: nil, userInfo: userInfo)
//            }
//        }
    }
    
    fileprivate func createTotalFooter() {
        totalFooterView.blendingMode = .withinWindow
        totalFooterView.material = CurrentTheme.defaults.material
        totalFooterView.state = .active
        totalFooterView.layerBackgroundColor = CurrentTheme.defaults.totalFooter.totalBackgroundColor
        self.view.addSubview(totalFooterView)
        totalFooterView.snp.makeConstraints { make in
            make.height.equalTo(32)
            make.leading.equalTo(self.view)
            make.trailing.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }

        balanceField.stringValue = "Balance:"
        balanceField.alignment = .center
        balanceField.font = CurrentTheme.accounts.cell.nameFont
        balanceField.textColor = CurrentTheme.defaults.foregroundColor
        balanceField.usesSingleLineMode = true
        totalFooterView.addSubview(balanceField)
        balanceField.snp.makeConstraints { make in
            make.leading.equalTo(totalFooterView).offset(10)
            make.centerY.equalTo(totalFooterView).offset(-1)
        }
        
        totalField.stringValue = "$0.00"
        totalField.alignment = .right
        totalField.font = CurrentTheme.accounts.cell.amountFont
        totalField.usesSingleLineMode = true
        totalField.setAccessibilityLabel("Total Balance")
        totalFooterView.addSubview(totalField)
        totalField.snp.makeConstraints { make in
            make.trailing.equalTo(totalFooterView).inset(12)
            make.centerY.equalTo(totalFooterView).offset(-1)
        }
    }
    
    //
    // MARK: - Notifications -
    //
    
    func registerForNotifications() {
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(institutionAdded(_:)), name: Notifications.InstitutionAdded)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(institutionRemoved(_:)), name: Notifications.InstitutionRemoved)
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(accountRemoved(_:)), name: Notifications.AccountRemoved)

        NotificationCenter.addObserverOnMainThread(self, selector: #selector(syncCompleted(_:)), name: Notifications.SyncCompleted)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(accountPatched(_:)), name: Notifications.AccountPatched)
    }
    
    func unregisterForNotifications() {
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.InstitutionAdded)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.InstitutionRemoved)
    
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.AccountRemoved)

        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.SyncCompleted)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.AccountPatched)
    }
    
    fileprivate let institutionUpdateDelay = 0.3
    
    // Have to do all this because tableView.updateRows equality checks don't work for Swift objects, so we need to make sure
    // that the references are equal or the animation is broken
    @objc fileprivate func institutionAdded(_ notification: Notification) {
        var reload = true
        if let institutionId = notification.userInfo?[Notifications.Keys.InstitutionId] as? Int {
            if let institution = Institution(institutionId: institutionId) {
                let oldData = viewModel.data
                viewModel.institutionAdded(institution: institution)
                reload = false
                
                // Wait for the animation to finish before sliding in the rows
                DispatchQueue.main.async(after: institutionUpdateDelay) {
                    do {
                        try ObjC.catchException {
                            self.tableView.updateRows(oldObjects: oldData.flattened as NSArray, newObjects: self.viewModel.data.flattened as NSArray, animationOptions: [.effectFade, .slideDown])
                        }
                    } catch {
                        self.tableView.reloadData()
                    }
                    
                    self.updateTotalBalance()
                    
                    self.adjustWindowHeight()
                    
                    // Scroll to the end of the table
                    DispatchQueue.main.async(after: self.institutionUpdateDelay) {
                        NSAnimationContext.runAnimationGroup({ context in
                            context.allowsImplicitAnimation = true
                            self.tableView.scrollRowToVisible(self.viewModel.data.count - 1)
                        }, completionHandler: nil)
                    }
                }
            }
        }
        
        if reload {
            // Note: This should never happen, just a fallback
            DispatchQueue.main.async(after: institutionUpdateDelay) {
                self.reloadData()
            }
        }
    }
    
    // Have to do all this because tableView.updateRows equality checks don't work for Swift objects, so we need to make sure
    // that the references are equal or the animation is broken
    @objc fileprivate func institutionRemoved(_ notification: Notification) {
        var reload = true
        if let institution = notification.userInfo?[Notifications.Keys.Institution] as? Institution {
            let oldData = viewModel.data
            viewModel.institutionRemoved(institution: institution)
            reload = false
            
            // Wait for the animation to finish before sliding in the rows
            DispatchQueue.main.async(after: institutionUpdateDelay) {
                do {
                    try ObjC.catchException {
                        self.tableView.updateRows(oldObjects: oldData.flattened as NSArray, newObjects: self.viewModel.data.flattened as NSArray, animationOptions: [.effectFade, .slideDown])
                    }
                } catch {
                    self.tableView.reloadData()
                }
                
                self.updateTotalBalance()
                
                // Only adjust if we're visible
                if self.view.window != nil {
                    self.adjustWindowHeight()
                }
            }
        }
        
        if reload {
            // Note: This should never happen, just a fallback
            DispatchQueue.main.async(after: institutionUpdateDelay) {
                self.reloadData()
            }
        }
    }
    
    // Have to do all this because tableView.updateRows equality checks don't work for Swift objects, so we need to make sure
    // that the references are equal or the animation is broken
    @objc fileprivate func accountRemoved(_ notification: Notification) {
        var reload = true
        if let account = notification.userInfo?[Notifications.Keys.Account] as? Account {
            let oldData = viewModel.data
            viewModel.accountRemoved(account: account)
            reload = false
            
            do {
                try ObjC.catchException {
                    self.tableView.updateRows(oldObjects: oldData.flattened as NSArray, newObjects: viewModel.data.flattened as NSArray, animationOptions: [.effectFade, .slideDown])
                }
            } catch {
                self.tableView.reloadData()
            }
            
            self.updateTotalBalance()
            
            self.adjustWindowHeight()
        }
        
        if reload {
            // Note: This should never happen, just a fallback
            DispatchQueue.main.async(after: institutionUpdateDelay) {
                self.reloadData()
            }
        }
    }
    
    @objc fileprivate func syncCompleted(_ notification: Notification) {
        reloadData()
    }
    
    @objc fileprivate func accountPatched(_ notification: Notification) {
        reloadData()
    }
    
    //
    // MARK: - Data Reloading -
    //
    
    func reloadData() {
        // Load the sort order
        viewModel.reloadData()
        updateTotalBalance()
        tableView.reloadData()
        createFixPasswordPrompt()
    }
    
    func updateTotalBalance() {
        //totalField.attributedStringValue = amountToStringFormatted(amount: viewModel.totalBalance(), showNegative: true)
    }
    
    //
    // MARK: - Table View -
    //
    
    func numberOfSectionsInTableView(_ tableView: SectionedTableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: SectionedTableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(inSection: section)
    }
    
    func tableView(_ tableView: SectionedTableView, heightOfSection section: Int) -> CGFloat {
        return CurrentTheme.accounts.headerCell.height
    }
    
    func tableView(_ tableView: SectionedTableView, heightOfRow row: Int, inSection section: Int) -> CGFloat {
        var height = CurrentTheme.accounts.cell.height
        if row == 0 {
            height -= 4
        }
        
        if TableIndex(section: section, row: row) == tableView.selectedIndex {
            return height + 50.0
        } else {
            return height
        }
    }
    
    func tableView(_ tableView: SectionedTableView, rowViewForSection section: Int) -> NSTableRowView? {
        var row = tableView.make(withIdentifier: "Institution Row", owner: self) as? HoverTableRowView
        if row == nil {
            row = HoverTableRowView()
            row?.identifier = "Institution Row"
            row?.color = CurrentTheme.defaults.cell.backgroundColor
            row?.hoverColor = CurrentTheme.defaults.cell.hoverBackgroundColor
        }
        return row
    }
    
    func tableView(_ tableView: SectionedTableView, rowViewForRow row: Int, inSection section: Int) -> NSTableRowView? {
        var row = tableView.make(withIdentifier: "Account Row", owner: self) as? HoverTableRowView
        if row == nil {
            row = HoverTableRowView()
            row?.identifier = "Account Row"
            row?.color = CurrentTheme.defaults.cell.backgroundColor
            row?.hoverColor = CurrentTheme.defaults.cell.hoverBackgroundColor
        }
        return row
    }
    
    func tableView(_ tableView: SectionedTableView, viewForSection section: Int) -> NSView? {
        var cell = tableView.make(withIdentifier: "Group Cell", owner: self) as? AccountsTabGroupCell
        if cell == nil {
            cell = AccountsTabGroupCell()
            cell?.identifier = "Group Cell"
        }
        
        if let institution = viewModel.institution(forSection: section) {
            cell?.updateModel(institution)
        }
        
        return cell
    }
    
    func tableView(_ tableView: SectionedTableView, viewForRow row: Int, inSection section: Int) -> NSView? {
        let cell = tableView.make(withIdentifier: "Account Cell", owner: self) as? AccountsTabAccountCell ?? AccountsTabAccountCell()
        cell.identifier = "Account Cell"
        
        let index = TableIndex(section: section, row: row)
        cell.index = index
        
        if let account = viewModel.account(forRow: row, inSection: section) {
            cell.updateModel(account)
        }
        
        cell.rowBackgroundColor = { TableIndex -> NSColor? in
            if let rowView = self.tableView.rowViewAtIndex(index, makeIfNecessary: false) as? HoverTableRowView {
                return rowView.currentColor
            }
            return nil
        }
        
        if index == previousSelectedIndex {
            tableView.deselectIndex(index)
            tableView.noteHeightOfIndex(index)
            previousSelectedIndex = TableIndex.none
        }

        let selectedIndex = tableView.selectedIndex
        if selectedIndex != TableIndex.none {
            cell.alphaValue = index == selectedIndex ? 1.0 : CurrentTheme.accounts.cell.dimmedAlpha
        }
        
        return cell
    }
    
    // MARK: Rearranging
    
    func tableView(_ tableView: SectionedTableView, canDragIndex index: TableIndex) -> Bool {
        return true
    }

    func tableView(_ tableView: SectionedTableView, dragImageForProposedDragImage dragImage: NSImage, index: TableIndex) -> NSImage {
        let size = NSSize(width: dragImage.size.width, height: CurrentTheme.accounts.cell.height)
        let clippedImage = dragImage.clippedImage(size)
        let alphaImage = clippedImage.alphaImage(0.35)
        return alphaImage
    }
    
    func tableView(_ tableView: SectionedTableView, validateDropFromIndex fromIndex: TableIndex, toIndex: TableIndex) -> NSDragOperation {
        if fromIndex.row == -1 {
            // Dragging a section
            if toIndex.row == -1 && fromIndex.section != toIndex.section && fromIndex.section != toIndex.section - 1 {
                return .move
            }
        } else {
            // Dragging a row
            if fromIndex.section == toIndex.section {
                // Only allow drops within the same section and not to the same place
                if toIndex.row >= 0 && fromIndex.row != toIndex.row && fromIndex.row != toIndex.row - 1 {
                    return .move
                }
            } else if fromIndex.section == toIndex.section - 1 && toIndex.row == -1 {
                // Allow drops to the end of the section
                return .move
            }
        }
        
        return NSDragOperation()
    }
    
    func tableView(_ tableView: SectionedTableView, acceptDropFromIndex fromIndex: TableIndex, toIndex: TableIndex, dropOperation: NSTableViewDropOperation) -> Bool {
        if fromIndex.row == -1 {
            // Moving a section
            var keys = viewModel.data.keys
            let fromInstitution = keys[fromIndex.section]

            // Correct row index for moving rows down
            if fromIndex < toIndex {
                toIndex.section -= 1
            }
            
            // Modify the data model
            let oldData = viewModel.data
            keys.remove(at: fromIndex.section)
            keys.insert(fromInstitution, at: toIndex.section)
            viewModel.data.keys = keys
            viewModel.persistSortOrder()
            
            // Update the UI
            tableView.updateRows(oldObjects: oldData.flattened as NSArray, newObjects: viewModel.data.flattened as NSArray, animationOptions: .slideDown)
            
            return true
        } else {
            // Moving a row
            if var accounts = viewModel.data[fromIndex.section] {
                // Handle dragging to end of section
                if toIndex.section > fromIndex.section {
                    toIndex.section = fromIndex.section
                    toIndex.row = accounts.count
                }
                
                // Correct row index for moving rows down
                if fromIndex < toIndex {
                    toIndex.row -= 1
                }
                
                // Modify the data model
                let fromAccount = accounts[fromIndex.row]
                accounts.remove(at: fromIndex.row)
                accounts.insert(fromAccount, at: toIndex.row)
                viewModel.data[fromIndex.section] = accounts
                viewModel.persistSortOrder()
                
                // Update the UI
                tableView.moveRowAtTableIndex(fromIndex, toIndex: toIndex)
                
                return true
            }
        }
        
        return false
    }
}
