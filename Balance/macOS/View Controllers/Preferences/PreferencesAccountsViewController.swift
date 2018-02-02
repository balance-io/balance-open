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
            make.left.equalToSuperview().offset(15)
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
        institutionsTableView.gridStyleMask = NSTableView.GridLineStyle.solidHorizontalGridLineMask
        institutionsTableView.rowHeight = 5000
        
        let institutionFooterHorizLine = View()
        institutionFooterHorizLine.layerBackgroundColor = NSColor(deviceWhiteInt: 235)
        institutionsBackgroundView.addSubview(institutionFooterHorizLine)
        institutionFooterHorizLine.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(1)
            make.right.equalToSuperview().offset(-1)
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
        (addAccountButton.cell as? NSButtonCell)?.highlightsBy = NSCell.StyleMask.contentsCellMask
        var addAccountAttributes = [NSAttributedStringKey.foregroundColor: NSColor(deviceRedInt: 0, green: 111, blue: 243),
                                    NSAttributedStringKey.font: NSFont.mediumSystemFont(ofSize: 13),
                                    NSAttributedStringKey.paragraphStyle: centeredParagraphStyle]
        addAccountButton.attributedTitle = NSAttributedString(string: "Add Account", attributes: addAccountAttributes)
        addAccountAttributes[NSAttributedStringKey.foregroundColor] = NSColor(deviceRedInt: 0, green: 111, blue: 243, alpha: 0.5)
        addAccountButton.attributedAlternateTitle = NSAttributedString(string: "Add Account", attributes: addAccountAttributes)
        
        institutionsBackgroundView.addSubview(addAccountButton)
        addAccountButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.bottom.equalToSuperview().offset(-3.5)
            make.width.equalTo(115)
            make.height.equalTo(30)
        }
        
        removeAccountButton.target = self
        removeAccountButton.action = #selector(removeAccount(_:))
        removeAccountButton.isBordered = false
        removeAccountButton.setButtonType(.momentaryChange)
        (removeAccountButton.cell as? NSButtonCell)?.highlightsBy = NSCell.StyleMask.contentsCellMask
        var removeAccountAttributes = [NSAttributedStringKey.foregroundColor: NSColor(deviceWhiteInt: 92),
                                       NSAttributedStringKey.font: NSFont.mediumSystemFont(ofSize: 13),
                                       NSAttributedStringKey.paragraphStyle: centeredParagraphStyle]
        removeAccountButton.attributedTitle = NSAttributedString(string: "Remove", attributes: removeAccountAttributes)
        removeAccountAttributes[NSAttributedStringKey.foregroundColor] = NSColor(deviceWhiteInt: 92, alpha: 0.5)
        removeAccountButton.attributedAlternateTitle = NSAttributedString(string: "Remove", attributes: removeAccountAttributes)
        institutionsBackgroundView.addSubview(removeAccountButton)
        removeAccountButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-3.5)
            make.width.equalToSuperview().offset(-115)
            make.height.equalTo(30)
        }
        
        // MARK: Accounts table
        
        let accountsBackgroundView = PaintCodeView()
        accountsBackgroundView.drawingBlock = PreferencesAccounts.drawAccountPreferencesBackground
        self.view.addSubview(accountsBackgroundView)
        accountsBackgroundView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
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
            make.left.equalToSuperview().offset(9)
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
            make.right.equalToSuperview().offset(-9)
            make.width.equalTo(100)
            make.top.equalToSuperview()
            make.height.equalTo(24)
        }
        
        let accountHeaderLine = View()
        accountHeaderLine.layerBackgroundColor = NSColor(deviceWhiteInt: 235)
        accountsBackgroundView.addSubview(accountHeaderLine)
        accountHeaderLine.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(1)
            make.right.equalToSuperview().offset(-1)
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
        accountsTableView.gridStyleMask = NSTableView.GridLineStyle.solidHorizontalGridLineMask
        accountsTableView.rowHeight = 5000
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadData), name: Notifications.InstitutionAdded)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadData), name: Notifications.InstitutionRemoved)
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadData), name: Notifications.AccountAdded)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadData), name: Notifications.AccountRemoved)
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadAccountsTable), name: Notifications.AccountHidden)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadAccountsTable), name: Notifications.AccountUnhidden)
    }
    
    deinit {
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.InstitutionAdded)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.InstitutionRemoved)
        
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.AccountAdded)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.AccountRemoved)
        
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.AccountHidden)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.AccountUnhidden)
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
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(reloadDataDelayed), object: nil)
        self.perform(#selector(reloadDataDelayed), with: nil, afterDelay: 0.5)
    }
    
    @objc fileprivate func reloadDataDelayed() {
        institutions = AccountRepository.si.accountsByInstitution(includeHidden: true)
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
        let institution = self.institutions.keys[self.institutionsTableView.selectedIndex.row]
        let messageText = "Are you sure you want to remove \"\(institution.displayName)\"?"
        let informativeText = "This will permanently delete all related coins, tokens, transactions, and API keys from Balance."
        
        let alert = NSAlert()
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Remove Account")
        alert.messageText = messageText
        alert.informativeText = informativeText
        alert.alertStyle = .critical
        alert.beginSheetModal(for: self.view.window!) { returnCode in
            if returnCode == NSApplication.ModalResponse.alertSecondButtonReturn {
                institution.delete()
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
            var row = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Institution Row"), owner: self) as? InstitutionRow
            if row == nil {
                row = InstitutionRow()
                row?.identifier = NSUserInterfaceItemIdentifier(rawValue: "Institution Row")
            }
            return row
        }
        return nil
    }
    
    func tableView(_ tableView: SectionedTableView, viewForRow row: Int, inSection section: Int) -> NSView? {
        if tableView == institutionsTableView {
            let institution = institutions.keys[row]
            var cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Institution Cell"), owner: self) as? InstitutionCell
            if cell == nil {
                cell = InstitutionCell()
                cell?.identifier = NSUserInterfaceItemIdentifier(rawValue: "Institution Cell")
            }
            
            cell?.updateModel(institution, isSelected: tableView.selectedIndex.row == row)
            return cell
        } else if tableView == accountsTableView, let selectedInstitution = selectedInstitution, let accounts = institutions[selectedInstitution] {
            let account = accounts[row]
            var cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Account Cell"), owner: self) as? AccountCell
            if cell == nil {
                cell = AccountCell()
                cell?.identifier = NSUserInterfaceItemIdentifier(rawValue: "Account Cell")
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
            PreferencesAccounts.drawSelectedAccount(frame: selectionFrame)
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
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-10)
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
        
        nameField.stringValue = updatedModel.displayName
    }
    
    fileprivate override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        nameField.textColor = isSelected ? .white : .black
        
        let color = isSelected ? .white : (model?.source.color ?? .gray)
        var circleFrame = NSRect(x: 10, y: 0, width: 9, height: 9)
        circleFrame.origin.y = (self.frame.size.height - circleFrame.size.height) / 2
        PreferencesAccounts.drawAccountColorCircle(frame: circleFrame, color: color)
    }
}

fileprivate class AccountCell: View {
    let nameField = LabelField()
    let showButton = Button()
    
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
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-30)
            make.top.equalToSuperview()
            make.height.equalToSuperview().offset(-1)
        }
        
        showButton.setButtonType(.switch)
        showButton.title = ""
        showButton.target = self
        showButton.action = #selector(showButtonAction(button:))
        self.addSubview(showButton)
        showButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    func updateModel(_ updatedModel: Account) {
        model = updatedModel
        
        let hidden = defaults.hiddenAccountIds.contains(updatedModel.accountId)
        showButton.state = hidden ? .off : .on
        
        nameField.stringValue = updatedModel.displayName
        nameField.textColor = hidden ? NSColor(deviceWhite: 0, alpha: 0.46) : .black
    }
    
    @objc fileprivate func showButtonAction(button: Button) {
        if let model = model {
            model.isHidden = (button.state == .off)
        }
    }
}

