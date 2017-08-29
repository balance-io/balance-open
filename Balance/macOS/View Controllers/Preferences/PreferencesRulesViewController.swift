//
//  PreferencesRulesViewController.swift
//  Bal
//
//  Created by Benjamin Baron on 8/2/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation
import Crashlytics
import BalanceVectorGraphics
import RealmSwift

class PreferencesRulesViewController: NSViewController {
    
    fileprivate let scrollViewContainer = View()
    fileprivate let scrollView = ScrollView()
    fileprivate let rulesTableView = TableView()
    fileprivate let newRuleButton = Button()
    
    fileprivate var ruleViews = [View]()
    fileprivate var ruleDeleteButtons = [Button]()
    fileprivate var ruleNotifyButtons = [Button]()
    fileprivate var ruleNameFields = [LabelField]()
    fileprivate var ruleEditors = [RuleEditor]()
    
    fileprivate var ruleNameSpacing: CGFloat = 10
    fileprivate var editorSpacing: CGFloat = 5
    fileprivate var nameFieldHeight: CGFloat = 25
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ruleIcon = NSImage(named: NSImage.Name.addTemplate)
        newRuleButton.image = tintImageWithColor(ruleIcon!, color: CurrentTheme.defaults.foregroundColor)
        newRuleButton.imagePosition = .imageLeft
        newRuleButton.bezelStyle = .rounded
        newRuleButton.title = "Add a Rule"
        newRuleButton.setAccessibilityLabel("Add a Rule")
        newRuleButton.target = self
        newRuleButton.sizeToFit()
        newRuleButton.action = #selector(createNewRule)
        self.view.addSubview(newRuleButton)
        newRuleButton.snp.makeConstraints { make in
            make.height.equalTo(25)
            make.trailing.equalTo(self.view).offset(-15)
            make.bottom.equalTo(self.view).offset(-15)
        }
        
        let institutionsBackgroundView = PaintCodeView()
        institutionsBackgroundView.drawingBlock = PreferencesAccounts.drawAccountPreferencesBackground
        self.view.addSubview(institutionsBackgroundView)
        institutionsBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(self.view).offset(15)
            make.left.equalTo(self.view).offset(15)
            make.right.equalTo(self.view).offset(-15)
            make.bottom.equalTo(newRuleButton.snp.top).offset(-15)
        }
        
        scrollView.focusRingType = .none
        scrollView.contentInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        institutionsBackgroundView.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(institutionsBackgroundView).offset(4)
            make.left.equalTo(institutionsBackgroundView).offset(7)
            make.right.equalTo(institutionsBackgroundView).offset(-7)
            make.bottom.equalTo(institutionsBackgroundView).offset(-4)
        }
        
        rulesTableView.delegate = self
        rulesTableView.dataSource = self
        rulesTableView.intercellSpacing = NSSize(width: 1, height: 10)
        rulesTableView.focusRingType = .none
        rulesTableView.selectionHighlightStyle = .none
        rulesTableView.setAccessibilityLabel("Rules Table")
        rulesTableView.allowsColumnSelection = false
        scrollView.documentView = rulesTableView
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        if feed.rules.count == 0 {
            createNewRule()
        }
        
        reloadData()
        
        registerForRuleChangeNotifications()
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        rulesNotificationToken?.stop()
        rulesNotificationToken = nil
        prefsRealm = nil
        feed.dedupeRules()
    }
    
    fileprivate var prefsRealm: Realm?
    fileprivate var rulesNotificationToken: NotificationToken?
    fileprivate func registerForRuleChangeNotifications() {
        if rulesNotificationToken == nil, let realm = realmManager.prefsRealm {
            // Keep a reference to the realm so that we keep getting notifications
            prefsRealm = realm
            rulesNotificationToken = realm.objects(Rule.self).addNotificationBlock { [weak self] changes in
                switch changes {
                case .update(_, _, _, _):
                    self?.reloadData()
                default:
                    // TODO: Probably handle the other cases
                    break
                }
            }
        }
    }
    
    func reloadData() {
        destroyRuleViews()
        createRuleViews()
        rulesTableView.reloadData()
    }
    
    func destroyRuleViews() {
        ruleViews = [View]()
        ruleDeleteButtons = [Button]()
        ruleNotifyButtons = [Button]()
        ruleNameFields = [LabelField]()
        ruleEditors = [RuleEditor]()
    }
    
    func destroyRuleViewAtIndex(_ index: Int) {
        ruleViews.remove(at: index)
        ruleDeleteButtons.remove(at: index)
        ruleNameFields.remove(at: index)
        ruleEditors.remove(at: index)
    }
    
    fileprivate func createRuleView(rule: Rule) -> View {
        let ruleView = View()
        ruleView.setAccessibilityLabel("Rule: " + (rule.name.isEmpty ? "New Rule" : rule.name))
        ruleView.layerBackgroundColor = NSColor(deviceRedInt: 245, green: 245, blue: 245)
        ruleView.layer?.cornerRadius = 4
        ruleView.layer?.borderWidth = 1
        ruleView.layer?.borderColor = NSColor(deviceRedInt: 220, green: 220, blue: 220).cgColor
//TODO figure out how to inset this so the shadow doesn't get clipped.
//        ruleView.shadow = NSShadow()
//        ruleView.layer?.shadowColor = NSColor(deviceRedInt: 64, green: 47, blue: 47).cgColor
//        ruleView.layer?.shadowRadius = 4
//        ruleView.layer?.shadowOffset = CGSize(width: 0, height: -1)
//        ruleView.layer?.shadowOpacity = 0.5
//        ruleView.snp.makeConstraints { make in
//            make.leading.equalTo(scrollView).offset(10)
//            make.trailing.equalTo(scrollView).offset(-10)
////            make.top.equalTo(ruleView).offset(5)
//        }
        ruleViews.append(ruleView)
        
//        let backgroundHeaderView = View()
////        backgroundHeaderView.layerBackgroundColor = NSColor(deviceRedInt: 237, green: 237, blue: 237)
//        backgroundHeaderView.layerBackgroundColor = NSColor.white
//        ruleView.addSubview(backgroundHeaderView)
//        backgroundHeaderView.snp.makeConstraints { make in
//            make.leading.equalTo(ruleView)
//            make.trailing.equalTo(ruleView)
//            make.top.equalTo(ruleView)
//            make.height.equalTo(35)
//        }
        
        let nameField = LabelField()
        nameField.verticalAlignment = .center
        nameField.lineBreakMode = .byWordWrapping
        nameField.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(rawValue: 250), for: .horizontal)
        nameField.usesSingleLineMode = false
        nameField.setAccessibilityLabel("Rule Name")
        nameField.font = NSFont.systemFont(ofSize: 14)
        nameField.stringValue = rule.displayName
        ruleView.addSubview(nameField)
        nameField.snp.makeConstraints { make in
            make.leading.equalTo(ruleView).offset(10)
            make.trailing.equalTo(ruleView).offset(-10)
            make.top.equalTo(ruleView).offset(5)
            make.height.equalTo(nameFieldHeight)
        }
        ruleNameFields.append(nameField)
        
//        let lineView = View()
//        lineView.layerBackgroundColor = NSColor(deviceRedInt: 230, green: 230, blue: 230)
//        ruleView.addSubview(lineView)
//        lineView.snp.makeConstraints { make in
//            make.leading.equalTo(ruleView).offset(10)
//            make.trailing.equalTo(ruleView).offset(-10)
//            make.top.equalTo(nameField.snp.bottom).offset(5)
//            make.height.equalTo(1)
//        }
        
        let rules = feed.ruleTemplatesForSearchTokens(rule.searchTokens)
        let editor = RuleEditor(ruleTemplates: Array(feed.defaultRuleTemplates().values), rules: rules, scrollingEnabled: false)
        editor.delegate = self
        ruleView.addSubview(editor)
        editor.snp.makeConstraints { make in
            make.leading.equalTo(ruleView)
            make.trailing.equalTo(ruleView)
            make.top.equalTo(nameField.snp.bottom).offset(editorSpacing)
            make.height.equalTo(editor.suggestedHeight)
        }
        ruleEditors.append(editor)
        
        let notifyButton = Button()
        notifyButton.setButtonType(.switch)
        notifyButton.title = "Desktop Notification "
        notifyButton.setAccessibilityLabel("Desktop Notification ")
        notifyButton.state = (rule.notify ? .on : .off)
        notifyButton.imagePosition = .imageRight
        notifyButton.target = self
        notifyButton.action = #selector(ruleNotifyButtonAction(_:))
        ruleView.addSubview(notifyButton)
        notifyButton.snp.makeConstraints { make in
            make.trailing.equalTo(ruleView).offset(-14)
            make.top.equalTo(editor.snp.bottom).offset(7)
            make.height.equalTo(20)
        }
        ruleNotifyButtons.append(notifyButton)
        
        
        let deleteButton = Button()
        deleteButton.bezelStyle = .rounded
        deleteButton.title = "Remove"
        deleteButton.target = self
        deleteButton.setAccessibilityLabel("Remove Rule")
        deleteButton.action = #selector(ruleDeleteButtonAction(_:))
        deleteButton.sizeToFit()
        ruleView.addSubview(deleteButton)
        deleteButton.snp.makeConstraints { make in
            make.leading.equalTo(ruleView).offset(10)
            make.top.equalTo(editor.snp.bottom).offset(6)
        }
        ruleDeleteButtons.append(deleteButton)

//        let baseLineView = View()
//        baseLineView.layerBackgroundColor = NSColor(deviceRedInt: 210, green: 210, blue: 210)
//        ruleView.addSubview(baseLineView)
//        baseLineView.snp.makeConstraints { make in
//            make.leading.equalTo(ruleView).offset(0)
//            make.trailing.equalTo(ruleView).offset(0)
////            make.top.equalTo(notifyButton.snp.bottom).offset(10)
//            make.bottom.equalTo(ruleView)
//            make.height.equalTo(1)
//        }
        
//        let topLineView = View()
//        topLineView.layerBackgroundColor = NSColor(deviceRedInt: 210, green: 210, blue: 210)
//        ruleView.addSubview(topLineView)
//        topLineView.snp.makeConstraints { make in
//            make.leading.equalTo(ruleView).offset(5)
//            make.trailing.equalTo(ruleView).offset(-5)
//            make.top.equalTo(notifyButton.snp.bottom).offset(10)
//            make.height.equalTo(1)
//        }
        
        return ruleView
    }
    
    func createRuleViews() {
        for rule in feed.rules {
            _ = createRuleView(rule: rule)
        }
    }
    
    @objc fileprivate func createNewRule() {
        _ = feed.createRule(name: "")
        
        // Scroll to the end of the table
        async(after: 0.3) {
            NSAnimationContext.runAnimationGroup({ context in
                context.allowsImplicitAnimation = true
                self.rulesTableView.scrollRowToVisible(feed.rules.count - 1)
                }, completionHandler: nil)
        }
        
        // Analytics
        Answers.logContentView(withName: "Preferences new feed rule created", contentType: nil, contentId: nil, customAttributes: nil)
    }
    
    @objc fileprivate func ruleDeleteButtonAction(_ sender: Button) {
        if let index = ruleDeleteButtons.index(of: sender) {
            let rule = feed.rules[index]
            let oldRules = feed.rules
            feed.deleteRule(rule, withoutNotifying: [rulesNotificationToken!])
            
            destroyRuleViewAtIndex(index)
            
            do {
                try ObjC.catchException {
                    self.rulesTableView.updateRows(oldObjects: oldRules as NSArray, newObjects: feed.rules as NSArray, animationOptions: [NSTableView.AnimationOptions.effectFade, NSTableView.AnimationOptions.slideDown])
                }
            } catch {
                self.rulesTableView.reloadData()
            }
        }
    }
    
    @objc fileprivate func ruleNotifyButtonAction(_ sender: Button) {
        if let index = ruleNotifyButtons.index(of: sender) {
            let rule = feed.rules[index]
            realmManager.writePrefs(withoutNotifying: [rulesNotificationToken!]) { _ in
                rule.notify = (sender.state == .on)
            }
        }
    }
}

extension PreferencesRulesViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return ruleViews.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        guard ruleViews.count > 0 else {
            return 0
        }
        
        return ruleNameSpacing + nameFieldHeight + nameFieldHeight + editorSpacing + ruleEditors[row].suggestedHeight + editorSpacing
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return ruleViews[row]
    }
}

extension PreferencesRulesViewController: RuleEditorDelegate {
    func ruleEditorDidAddRule(_ ruleEditor: RuleEditor, index: Int) {
        persistRuleEditor(ruleEditor)
        resizeRuleEditor(ruleEditor)
    }
    
    func ruleEditorDidRemoveRule(_ ruleEditor: RuleEditor, index: Int) {
        persistRuleEditor(ruleEditor)
        resizeRuleEditor(ruleEditor)
    }
    
    func ruleEditorRuleDidChange(_ ruleEditor: RuleEditor, index: Int) {
        persistRuleEditor(ruleEditor)
        resizeRuleEditor(ruleEditor)
    }
    
    fileprivate func resizeRuleEditor(_ ruleEditor: RuleEditor) {
        ruleEditor.snp.updateConstraints { make in
            make.height.equalTo(ruleEditor.suggestedHeight)
        }
        
        if let index = ruleEditors.index(of: ruleEditor) {
            rulesTableView.noteHeightOfRows(withIndexesChanged: IndexSet(integer: index))
        }
    }
    
    fileprivate func persistRuleEditor(_ ruleEditor: RuleEditor) {
        if let index = ruleEditors.index(of: ruleEditor) {
            let rule = feed.rules[index]
            let searchTokens = feed.searchTokensForRuleTemplates(ruleEditor.rules)
            rule.updateSearchTokens(searchTokens, withoutNotifying: [rulesNotificationToken!])
            
            let nameField = ruleNameFields[index]
            nameField.stringValue = rule.displayName
        }
    }
}
