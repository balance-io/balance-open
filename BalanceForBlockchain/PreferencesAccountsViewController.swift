//
//  PreferencesAccountsViewController.swift
//  Bal
//
//  Created by Benjamin Baron on 2/16/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Cocoa

class PreferencesAccountsViewController: NSViewController {
    
    let institutionsScrollView = ScrollView()
    let institutionsTableView = SectionedTableView()
    let addAccountButton = Button()
    let removeAccountButton = Button()
    
    let accountsScrollView = ScrollView()
    let accountsTableView = SectionedTableView()
    
    var statusField = LabelField()
    
    fileprivate var institutions = OrderedDictionary<Institution, [Account]>()
    fileprivate var selectedInstitution: Institution? {
        let selectedIndex = institutionsTableView.selectedIndex
        return selectedIndex == .none ? nil : institutions.keys[selectedIndex.row]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Institutions table
        
        let institutionsBackgroundView = PaintCodeView()
        institutionsBackgroundView.drawingBlock = PreferencesAccounts.drawAccountPreferencesBackground
        self.view.addSubview(institutionsBackgroundView)
        institutionsBackgroundView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(15)
            make.width.equalTo(193)
            make.height.equalTo(252)
        }
        
        institutionsScrollView.documentView = institutionsTableView
        institutionsBackgroundView.addSubview(institutionsScrollView)
        institutionsScrollView.snp.makeConstraints { make in
            make.width.equalToSuperview().offset(-2)
            make.height.equalToSuperview().offset(-2 - 32)
            make.top.equalToSuperview().offset(1)
            make.centerX.equalToSuperview()
        }
        
        institutionsTableView.customDelegate = self
        institutionsTableView.customDataSource = self
        institutionsTableView.selectionHighlightStyle = .none
        institutionsTableView.displaySectionRows = false
        institutionsTableView.intercellSpacing = NSSize(width: 1, height: 1)
        institutionsTableView.gridColor = NSColor(deviceWhiteInt: 243)
        institutionsTableView.gridStyleMask = .solidHorizontalGridLineMask
        institutionsTableView.rowHeight = 5000
        
        let institutionFooterHorizLine = View()
        institutionFooterHorizLine.layerBackgroundColor = NSColor(deviceWhiteInt: 235)
        institutionsBackgroundView.addSubview(institutionFooterHorizLine)
        institutionFooterHorizLine.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(1)
            make.trailing.equalToSuperview().offset(-1)
            make.bottom.equalToSuperview().offset(-33)
            make.height.equalTo(1)
        }
        
        let institutionFooterVertLine = View()
        institutionFooterVertLine.layerBackgroundColor = NSColor(deviceWhiteInt: 235)
        institutionsBackgroundView.addSubview(institutionFooterVertLine)
        institutionFooterVertLine.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.height.equalTo(32)
            make.bottom.equalToSuperview().offset(-1)
            make.left.equalTo(115)
        }
        
        addAccountButton.target = self
        addAccountButton.action = #selector(addAccount(_:))
        addAccountButton.isBordered = false
        addAccountButton.setButtonType(.momentaryChange)
        (addAccountButton.cell as? NSButtonCell)?.highlightsBy = .contentsCellMask
        var addAccountAttributes = [NSForegroundColorAttributeName: NSColor(deviceRedInt: 0, green: 111, blue: 243),
                                    NSFontAttributeName: NSFont.mediumSystemFont(ofSize: 13),
                                    NSParagraphStyleAttributeName: centeredParagraphStyle]
        addAccountButton.attributedTitle = NSAttributedString(string: "Add Account", attributes: addAccountAttributes)
        addAccountAttributes[NSForegroundColorAttributeName] = NSColor(deviceRedInt: 0, green: 111, blue: 243, alpha: 0.5)
        addAccountButton.attributedAlternateTitle = NSAttributedString(string: "Add Account", attributes: addAccountAttributes)
        
        institutionsBackgroundView.addSubview(addAccountButton)
        addAccountButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview().offset(-3.5)
            make.width.equalTo(115)
            make.height.equalTo(30)
        }
        
        removeAccountButton.target = self
        removeAccountButton.action = #selector(removeAccount(_:))
        removeAccountButton.isBordered = false
        removeAccountButton.setButtonType(.momentaryChange)
        (removeAccountButton.cell as? NSButtonCell)?.highlightsBy = .contentsCellMask
        var removeAccountAttributes = [NSForegroundColorAttributeName: NSColor(deviceWhiteInt: 92),
                                       NSFontAttributeName: NSFont.mediumSystemFont(ofSize: 13),
                                       NSParagraphStyleAttributeName: centeredParagraphStyle]
        removeAccountButton.attributedTitle = NSAttributedString(string: "Remove", attributes: removeAccountAttributes)
        removeAccountAttributes[NSForegroundColorAttributeName] = NSColor(deviceWhiteInt: 92, alpha: 0.5)
        removeAccountButton.attributedAlternateTitle = NSAttributedString(string: "Remove", attributes: removeAccountAttributes)
        institutionsBackgroundView.addSubview(removeAccountButton)
        removeAccountButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-3.5)
            make.width.equalToSuperview().offset(-115)
            make.height.equalTo(30)
        }
        
        // MARK: Accounts table
        
        let accountsBackgroundView = PaintCodeView()
        accountsBackgroundView.drawingBlock = PreferencesAccounts.drawAccountPreferencesBackground
        self.view.addSubview(accountsBackgroundView)
        accountsBackgroundView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(15)
            make.width.equalTo(269)
            make.height.equalTo(252)
        }
        
        let nameField = LabelField()
        nameField.alignment = .left
        nameField.verticalAlignment = .center
        nameField.font = .mediumSystemFont(ofSize: 12)
        nameField.textColor = NSColor(deviceWhite: 0, alpha: 0.46)
        nameField.usesSingleLineMode = true
        nameField.stringValue = "Account"
        accountsBackgroundView.addSubview(nameField)
        nameField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(9)
            make.width.equalTo(100)
            make.top.equalToSuperview()
            make.height.equalTo(24)
        }

        let showField = LabelField()
        showField.alignment = .right
        showField.verticalAlignment = .center
        showField.font = .mediumSystemFont(ofSize: 12)
        showField.textColor = NSColor(deviceWhite: 0, alpha: 0.46)
        showField.usesSingleLineMode = true
        showField.stringValue = "Show"
        accountsBackgroundView.addSubview(showField)
        showField.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-9)
            make.width.equalTo(100)
            make.top.equalToSuperview()
            make.height.equalTo(24)
        }
        
        let accountHeaderLine = View()
        accountHeaderLine.layerBackgroundColor = NSColor(deviceWhiteInt: 235)
        accountsBackgroundView.addSubview(accountHeaderLine)
        accountHeaderLine.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(1)
            make.trailing.equalToSuperview().offset(-1)
            make.top.equalToSuperview().offset(24)
            make.height.equalTo(1)
        }
        
        accountsScrollView.documentView = accountsTableView
        accountsBackgroundView.addSubview(accountsScrollView)
        accountsScrollView.snp.makeConstraints { make in
            make.width.equalToSuperview().offset(-2)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(25)
            make.bottom.equalToSuperview().offset(-1)
        }
        
        accountsTableView.customDelegate = self
        accountsTableView.customDataSource = self
        accountsTableView.selectionHighlightStyle = .none
        accountsTableView.displaySectionRows = false
        accountsTableView.allowSelectingRows = false
        accountsTableView.intercellSpacing = NSSize(width: 1, height: 1)
        accountsTableView.gridColor = NSColor(deviceWhiteInt: 243)
        accountsTableView.gridStyleMask = .solidHorizontalGridLineMask
        accountsTableView.rowHeight = 5000
        
        statusField.alignment = .left
        statusField.verticalAlignment = .center
        statusField.font = .systemFont(ofSize: 12)
        statusField.textColor = NSColor(deviceWhite: 0, alpha: 0.4)
        statusField.usesSingleLineMode = true
        self.view.addSubview(statusField)
        statusField.snp.makeConstraints { make in
            make.leading.equalTo(institutionsBackgroundView)
            make.trailing.equalTo(accountsBackgroundView)
            make.top.equalTo(institutionsBackgroundView.snp.bottom).offset(8.5)
            make.height.equalTo(17)
        }
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadData), name: Notifications.InstitutionAdded)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadData), name: Notifications.InstitutionRemoved)
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadData), name: Notifications.AccountAdded)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadData), name: Notifications.AccountRemoved)
    }
    
    deinit {
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.InstitutionAdded)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.InstitutionRemoved)
        
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.AccountAdded)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.AccountRemoved)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        reloadData()
    }
    
    fileprivate func selectFirstInstitution() {
        if institutionsTableView.selectedIndex == .none && institutions.count > 0 {
            institutionsTableView.selectIndex(TableIndex(section: 0, row: 0))
        }
        removeAccountButton.isEnabled = institutionsTableView.selectedIndex != .none
    }
    
    @objc fileprivate func reloadData() {
        institutions = Account.accountsByInstitution()
        institutionsTableView.reloadData()
        selectFirstInstitution()
        accountsTableView.reloadData()
    }
    
    @objc fileprivate func reloadAccountsTable() {
        accountsTableView.reloadData()
    }
    
    @IBAction func addAccount(_ sender: NSButton) {
        NotificationCenter.postOnMainThread(name: Notifications.ShowPopover)
        NotificationCenter.postOnMainThread(name: Notifications.ShowAddAccount)
    }
    
    @IBAction func removeAccount(_ sender: NSButton) {
        let alert = NSAlert()
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "OK")
        alert.messageText = "Are you sure you want to remove this account?"
        alert.alertStyle = .critical
        alert.beginSheetModal(for: self.view.window!) { returnCode in
            if returnCode == NSAlertSecondButtonReturn {
                self.institutionsTableView.isEnabled = false
                self.accountsTableView.isEnabled = false
                self.removeAccountButton.isEnabled = false
                self.addAccountButton.isEnabled = false
        
//                let institution = self.institutions.keys[self.institutionsTableView.selectedIndex.row]
//                if let accessToken = institution.accessToken {
//                    subscriptionManager.deleteAccessToken(accessToken: accessToken) { success, _, message, _, _ in
//                        self.institutionsTableView.isEnabled = true
//                        self.accountsTableView.isEnabled = true
//                        self.addAccountButton.isEnabled = true
//                        self.selectFirstInstitution()
//        
//                        // Handle Plaid's shitty test data
//                        if success || accessToken.hasPrefix("test_") {
//                            institution.remove()
//                        } else {
//                            let alert = NSAlert()
//                            alert.alertStyle = .critical
//                            alert.messageText = "Error removing account"
//                            alert.informativeText = message
//                            alert.addButton(withTitle: "OK")
//                            alert.runModal()
//                        }
//                    }
//                } else {
//                    institution.remove()
//                }
            }
        }
    }
}

extension PreferencesAccountsViewController: SectionedTableViewDelegate, SectionedTableViewDataSource {
    
    func numberOfSectionsInTableView(_ tableView: SectionedTableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: SectionedTableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == institutionsTableView {
            return institutions.keys.count
        } else if tableView == accountsTableView, let selectedInstitution = selectedInstitution {
            return institutions[selectedInstitution]?.count ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: SectionedTableView, heightOfRow row: Int, inSection section: Int) -> CGFloat {
        if tableView == institutionsTableView {
            return 37
        } else if tableView == accountsTableView {
            return 33
        }
        return 0
    }
    
    func tableView(_ tableView: SectionedTableView, rowViewForRow row: Int, inSection section: Int) -> NSTableRowView? {
        if tableView == institutionsTableView {
            var row = tableView.make(withIdentifier: "Institution Row", owner: self) as? InstitutionRow
            if row == nil {
                row = InstitutionRow()
                row?.identifier = "Institution Row"
            }
            return row
        }
        return nil
    }
    
    func tableView(_ tableView: SectionedTableView, viewForRow row: Int, inSection section: Int) -> NSView? {
        if tableView == institutionsTableView {
            let institution = institutions.keys[row]
            var cell = tableView.make(withIdentifier: "Institution Cell", owner: self) as? InstitutionCell
            if cell == nil {
                cell = InstitutionCell()
                cell?.identifier = "Institution Cell"
            }
            
            cell?.updateModel(institution, isSelected: tableView.selectedIndex.row == row)
            return cell
        } else if tableView == accountsTableView, let selectedInstitution = selectedInstitution, let accounts = institutions[selectedInstitution] {
            let account = accounts[row]
            var cell = tableView.make(withIdentifier: "Account Cell", owner: self) as? AccountCell
            if cell == nil {
                cell = AccountCell()
                cell?.identifier = "Account Cell"
            }
            
            cell?.updateModel(account)
            
            return cell
        }
        return nil
    }

    func tableView(_ tableView: SectionedTableView, selectionWillChange selectedIndex: TableIndex) {
        if tableView == institutionsTableView {
            let visibleIndexes = institutionsTableView.visibleIndexes
            for index in visibleIndexes {
                if let cell = institutionsTableView.viewAtIndex(index, makeIfNecessary: false) as? InstitutionCell {
                    cell.isSelected = (index == selectedIndex)
                    cell.needsDisplay = true
                }
            }
        }
    }
    
    func tableView(_ tableView: SectionedTableView, selectionDidChange selectedIndex: TableIndex) {
        if tableView == institutionsTableView {
            removeAccountButton.isEnabled = selectedIndex != .none
            accountsTableView.reloadData()
        }
    }
}

fileprivate class InstitutionRow: NSTableRowView {
    fileprivate override var isSelected: Bool {
        willSet {
            self.needsDisplay = true
        }
    }
    
    fileprivate override func drawBackground(in dirtyRect: NSRect) {
        if self.isSelected {
            var selectionFrame = NSRect(x: 0, y: 0, width: 185, height: 31)
            selectionFrame.origin.x = (self.frame.size.width - selectionFrame.size.width) / 2
            selectionFrame.origin.y = ((self.frame.size.height - selectionFrame.size.height) / 2) - 0.5
            //PreferencesAccounts.drawSelectedAccount(frame: selectionFrame)
        }
    }
}

fileprivate class InstitutionCell: View {
    let nameField = LabelField()
    
    var isSelected = false
    fileprivate var model: Institution?
    
    init() {
        super.init(frame: NSZeroRect)
        
        nameField.backgroundColor = .clear
        nameField.alignment = .left
        nameField.verticalAlignment = .center
        nameField.font = .mediumSystemFont(ofSize: 13.5)
        nameField.textColor = .black
        nameField.cell?.usesSingleLineMode = true
        nameField.cell?.lineBreakMode = .byTruncatingTail
        self.addSubview(nameField)
        nameField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview()
            make.height.equalToSuperview().offset(-2)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    func updateModel(_ updatedModel: Institution, isSelected: Bool) {
        self.model = updatedModel
        self.isSelected = isSelected
        self.needsDisplay = true
        
        nameField.stringValue = updatedModel.name.capitalizedStringIfAllCaps
    }
    
    fileprivate override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        nameField.textColor = isSelected ? .white : .black
        
        let color = isSelected ? .white : (model?.displayColor ?? .gray)
        var circleFrame = NSRect(x: 10, y: 0, width: 9, height: 9)
        circleFrame.origin.y = (self.frame.size.height - circleFrame.size.height) / 2
        //PreferencesAccounts.drawAccountColorCircle(frame: circleFrame, color: color)
    }
}

fileprivate class AccountCell: View {
    let nameField = LabelField()
    
    fileprivate var model: Account?
    
    init() {
        super.init(frame: NSZeroRect)
        
        nameField.backgroundColor = .clear
        nameField.alignment = .left
        nameField.verticalAlignment = .center
        nameField.font = .systemFont(ofSize: 13)
        nameField.textColor = .black
        nameField.cell?.usesSingleLineMode = true
        nameField.cell?.lineBreakMode = .byTruncatingTail
        self.addSubview(nameField)
        nameField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-30)
            make.top.equalToSuperview()
            make.height.equalToSuperview().offset(-1)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    func updateModel(_ updatedModel: Account) {
        model = updatedModel
        
        nameField.stringValue = updatedModel.name.capitalizedStringIfAllCaps
        nameField.textColor = .black
    }
}

