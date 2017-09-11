//
//  RuleEditor.swift
//  RuleEditor
//
//  Created by Benjamin Baron on 8/3/16.
//  Copyright © 2016 test. All rights reserved.
//

import Cocoa
import SnapKit

// MARK: - RuleEditor -

@objc protocol RuleEditorDelegate {
    @objc optional func ruleEditorDidAddRule(_ ruleEditor: RuleEditor, index: Int)
    @objc optional func ruleEditorDidRemoveRule(_ ruleEditor: RuleEditor, index: Int)
    @objc optional func ruleEditorRuleDidChange(_ ruleEditor: RuleEditor, index: Int)
}

class RuleEditor: NSView, NSTableViewDelegate, NSTableViewDataSource, RuleViewDelegate {
    
    // MARK: Properties
    
    var delegate: RuleEditorDelegate?
    var rowHeight: CGFloat = 42
    var ruleTemplates = [RuleTemplate]()
    var rules = [RuleTemplate]()
    
    var suggestedHeight: CGFloat {
        let extraRow = chooserRuleShouldShow ? 1 : 0
        return CGFloat(rules.count + extraRow) * rowHeight
    }
    
    fileprivate var scrollingEnabled = true
    fileprivate let scrollView = NSScrollView()
    fileprivate let tableView = NSTableView()
    
    fileprivate var chooserRuleView: RuleView?
    fileprivate var chooserRuleDefaultValue: [String] {
        return ruleTemplates.filter({!rules.contains($0)}).map({$0.name}).sorted()
    }
    fileprivate var chooserRuleSelectedString = ""
    fileprivate var chooserRuleShouldShow = true
    
    // Set the view to flipped to keep things at the top as the table rows change
    override var isFlipped: Bool {
        return true
    }
    
    // MARK: Lifecycle
    
    init(ruleTemplates: [RuleTemplate], rules: [RuleTemplate], scrollingEnabled: Bool = true) {
        super.init(frame: NSZeroRect)
        self.ruleTemplates = ruleTemplates
        self.rules = rules
        self.scrollingEnabled = scrollingEnabled
        self.chooserRuleShouldShow = (rules.count == 0)
        commonInit()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        self.wantsLayer = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setAccessibilityLabel("Rule Editor " + String(rules.count + 1))
        
        if scrollingEnabled {
            scrollView.layerBackgroundColor = NSColor.clear
            scrollView.hasVerticalScroller = true
            scrollView.hasHorizontalScroller = false
            scrollView.verticalScrollElasticity = .none
            self.addSubview(scrollView)
            scrollView.snp.makeConstraints { make in
                make.top.equalTo(self)
                make.leading.equalTo(self)
                make.trailing.equalTo(self)
                make.bottom.equalTo(self)
            }
        }
        
        tableView.wantsLayer = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.addTableColumn(NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "main")))
        tableView.selectionHighlightStyle = .none
        tableView.headerView = nil
        tableView.allowsEmptySelection = true
        tableView.allowsColumnReordering = false
        tableView.allowsColumnResizing = false
        tableView.allowsColumnSelection = false
        tableView.allowsMultipleSelection = false
        tableView.rowHeight = 5000 // Hide grid lines on empty cells
        tableView.focusRingType = .none
        tableView.backgroundColor = NSColor.clear
        
        if scrollingEnabled {
            scrollView.documentView = tableView
        } else {
            self.addSubview(tableView)
            tableView.snp.makeConstraints { make in
                make.top.equalTo(self)
                make.leading.equalTo(self)
                make.trailing.equalTo(self)
                make.bottom.equalTo(self)
            }
        }
    }
    
    // MARK: Private 
    
    fileprivate func showChooserRow() {
        if !chooserRuleShouldShow {
            chooserRuleShouldShow = true
            tableView.insertRows(at: IndexSet(integer: rules.count), withAnimation: [NSTableView.AnimationOptions.slideUp, NSTableView.AnimationOptions.effectFade])
        }
    }
    
    fileprivate func hideChooserRow() {
        if chooserRuleShouldShow {
            chooserRuleShouldShow = false
            tableView.removeRows(at: IndexSet(integer: rules.count), withAnimation: [NSTableView.AnimationOptions.slideUp, NSTableView.AnimationOptions.effectFade])
        }
    }
    
    fileprivate func updateRowAddButtons() {
        if rules.count > 0 {
            let remainingDefaultRules = chooserRuleDefaultValue.count
            for i in 0...rules.count-1 {
                if let ruleView = tableView.view(atColumn: 0, row: i, makeIfNecessary: false) as? RuleView {
                    let lastRow = (i == rules.count - 1)
                    if lastRow && remainingDefaultRules > 0 {
                        ruleView.showAddButton()
                    } else {
                        ruleView.hideAddButton()
                    }
                }
            }
        }
    }
    
    // MARK: Public API
    
    func addRule(_ rule: RuleTemplate, animated: Bool = true) {
        // Add the row
        let index = rules.count
        rules.append(rule)
        if animated {
            tableView.insertRows(at: IndexSet(integer: index), withAnimation: [NSTableView.AnimationOptions.slideUp, NSTableView.AnimationOptions.effectFade])
        } else {
            tableView.reloadData()
        }
        
        hideChooserRow()
        updateRowAddButtons()
        
        // Enable scroll elasticity if contents are larger than scrollView
        if scrollingEnabled && tableView.frame.size.height > scrollView.frame.size.height {
            scrollView.verticalScrollElasticity = .allowed
        }
        
        // Inform the delegate
        delegate?.ruleEditorDidAddRule?(self, index: index)
    }
    
    func removeRuleAtIndex(_ index: Int, animated: Bool = true) {
        // Remove the row
        rules.remove(at: index)
        if animated {
            tableView.removeRows(at: IndexSet(integer: index), withAnimation: [NSTableView.AnimationOptions.slideUp, NSTableView.AnimationOptions.effectFade])
        } else {
            tableView.reloadData()
        }
        
        if rules.count == 0 {
            showChooserRow()
        }
        updateRowAddButtons()
        
        // Disable scroll elasticity if contents are smaller than scrollView
        // NOTE: For some reason, it doesn't get the correct table view height right away, 
        // so either do a hacky dispatch_after or subtract the row height from the table height
        if scrollingEnabled && tableView.frame.size.height - rowHeight < scrollView.frame.size.height {
            scrollView.verticalScrollElasticity = .none
        }
        
        // Inform the delegate
        delegate?.ruleEditorDidRemoveRule?(self, index: index)
    }
    
    // MARK: NSTableViewDataSource/Delegate
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        let extraRow = (chooserRuleShouldShow ? 1 : 0)
        return rules.count + extraRow
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return rowHeight
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if row < rules.count {
            let hideAddButton = (row < rules.count - 1)
            return RuleView(type: .rule, rule: rules[row], hideAddButton: hideAddButton, delegate: self)
        } else {
            let chooserComboDefault = chooserRuleDefaultValue
            chooserRuleSelectedString = chooserComboDefault[0]
            let elements = [Element(type: .label, defaultValue: ["Applies to the "]),
                            Element(type: .comboBox, defaultValue: chooserComboDefault, label: "Rule Field"),
                            Element(type: .label, defaultValue: ["     "]),
                            Element(type: .button, defaultValue: ["Add condition"])]
            let chooserRule = RuleTemplate(templateId: -1, name: "", elements: elements)
            let ruleView = RuleView(type: .chooser, rule: chooserRule, showAddRemoveButtons: false, delegate: self)
            ruleView.type = .chooser
            return ruleView
        }
    }
    
    // MARK: RuleTableCellDelegate
    
    @objc fileprivate func ruleViewShowChooserRule(_ ruleView: RuleView) {
        showChooserRow()
        delegate?.ruleEditorDidAddRule?(self, index: rules.count)
    }
    
    @objc fileprivate func ruleViewRemoveRule(_ ruleView: RuleView) {
        let index = tableView.row(for: ruleView)
        if index < rules.count {
            removeRuleAtIndex(index)
        }
    }
    
    @objc fileprivate func ruleViewElementValueChanged(_ ruleView: RuleView, rule: RuleTemplate, element: Element, elementView: NSView) {
        if ruleView.type == .chooser {
            if element.type == .comboBox, let stringValue = element.stringValue {
                chooserRuleSelectedString = stringValue
            } else if element.type == .button {
                if let index = ruleTemplates.index(where: {$0.name == chooserRuleSelectedString}) {
                    let template = ruleTemplates[index]
                    addRule(template, animated: true)
                    
                    if let comboBox = elementView as? NSComboBox {
                        comboBox.selectItem(at: 0)
                    }
                }
            }
            
        } else if let index = rules.index(of: rule) {
            // Update the data model
            rules[index] = rule
            
            // Inform the delegate
            delegate?.ruleEditorRuleDidChange?(self, index: index)
        }
    }
}

// MARK: - RuleView -

@objc private protocol RuleViewDelegate {
    func ruleViewShowChooserRule(_ ruleView: RuleView)
    func ruleViewRemoveRule(_ ruleView: RuleView)
    func ruleViewElementValueChanged(_ ruleView: RuleView, rule: RuleTemplate, element: Element, elementView: NSView)
}

@objc enum RuleViewType: Int {
    case rule
    case chooser
}

@objc private class RuleView: NSView, NSComboBoxDelegate, NSTextFieldDelegate {
    
    // MARK: Properties
    
    var delegate: RuleViewDelegate?
    var type: RuleViewType
    
    let rule: RuleTemplate
    fileprivate var elementViews: [NSView]
    
    fileprivate let removeButton = NSButton()
    fileprivate let addButton = NSButton()
    
    // MARK: Lifecycle
    
    init(type: RuleViewType, rule: RuleTemplate, showAddRemoveButtons: Bool = true, hideAddButton: Bool = true, delegate: RuleViewDelegate? = nil) {
        self.type = type
        self.rule = rule
        self.elementViews = [NSView]()
        self.delegate = delegate
        super.init(frame: NSZeroRect)
        self.wantsLayer = true
        
        //TODO why is the chooser height different from the rule height
        if type == .chooser {
            self.layerBackgroundColor = NSColor(calibratedRedInt: 242, green: 249, blue: 255)
        } else {
            self.layerBackgroundColor = .white
        }
        
        if showAddRemoveButtons {
            removeButton.wantsLayer = true
            removeButton.bezelStyle = .rounded
            removeButton.translatesAutoresizingMaskIntoConstraints = false
            let removeIcon = NSImage(named: NSImage.Name.removeTemplate)
            removeButton.image = tintImageWithColor(removeIcon!, color: CurrentTheme.defaults.foregroundColor)
            removeButton.imagePosition = .imageOnly
            removeButton.title = ""
            removeButton.setAccessibilityLabel("Remove Rule")
            removeButton.target = self
            removeButton.sizeToFit()
            removeButton.action = #selector(removeButtonAction)
            self.addSubview(removeButton)
            removeButton.snp.makeConstraints { make in
                make.centerY.equalTo(self)
                make.width.equalTo(22)
                make.trailing.equalTo(self).offset(-10)
            }
            
            addButton.wantsLayer = true
            addButton.bezelStyle = .rounded
            addButton.translatesAutoresizingMaskIntoConstraints = false
            let addIcon = NSImage(named: NSImage.Name.addTemplate)
            addButton.image = tintImageWithColor(addIcon!, color: CurrentTheme.defaults.foregroundColor)
            addButton.imagePosition = .imageOnly
            addButton.title = ""
            addButton.setAccessibilityLabel("Add Rule")
            addButton.target = self
            addButton.sizeToFit()
            addButton.action = #selector(addButtonAction)
            self.addSubview(addButton)
            addButton.snp.makeConstraints { make in
                make.centerY.equalTo(self)
                make.width.equalTo(22)
                make.trailing.equalTo(removeButton.snp.leading).offset(-2)
            }
            
            if hideAddButton {
                self.hideAddButton()
            }
        }
        
        createElementViews()
    }
    
    override init(frame frameRect: NSRect) {
        fatalError("Initialize using init(row:elements:)")
    }
    
    required init?(coder: NSCoder) {
        fatalError("Initialize using init(row:elements:)")
    }
    
    // MARK: Public
    
    func showAddButton() {
        addButton.isHidden = false
    }
    
    func hideAddButton() {
        addButton.isHidden = true
    }
    
    // MARK: Private
    
    fileprivate func createElementViews() {
        var previousElementView: NSView?
        
        var index = 0
        for element in rule.elements {
            switch element.type {
            case .label, .textField, .numberField:
                // Create view
                let textField: TextField = element.type == .label ? LabelField() : TextField()
                textField.usesSingleLineMode = true
                textField.verticalAlignment = element.type == .label ? .bottom : .default
                if element.type != .label {
                    textField.delegate = self
                }
                self.addSubview(textField)
                elementViews.append(textField)
                
                // Set value
                textField.stringValue = element.stringValue ?? element.defaultValue[0]
                
                if element.label != nil {
                    textField.setAccessibilityLabel(element.label);
                }
                else if ( element.type == .textField || element.type == .numberField ) {
                    textField.setAccessibilityLabel("Rule Value")
                }
                
                // Layout
                var width: CGFloat = 0
                if let elementWidth = element.width {
                    width = elementWidth
                } else {
                    let size = textField.attributedStringValue.size()
                    width = element.type == .label ? size.width + 5 : size.width + 15
                }
                
                textField.snp.makeConstraints { make in
                    if let previousElementView = previousElementView {
                        make.leading.equalTo(previousElementView.snp.trailing).offset(5)
                    } else {
                        make.leading.equalToSuperview().offset(10)
                    }
                    make.centerY.equalTo(self)
                    make.width.equalTo(width)
                }
                
                previousElementView = textField
            case .comboBox:
                // Create view
                let comboBox = ComboBox()
                comboBox.isEditable = false
                comboBox.setAccessibilityLabel("Rule Type")
                self.addSubview(comboBox)
                elementViews.append(comboBox)
                
                if element.label != nil {
                    comboBox.setAccessibilityLabel(element.label);
                }
                
                // Set value
                comboBox.addItems(withObjectValues: element.defaultValue)
                
                if element.defaultValue.count > 0 {
                    var index = 0
                    if let stringValue = element.stringValue {
                        if let stringValueIndex = element.defaultValue.index(of: stringValue) {
                            index = stringValueIndex
                        }
                    }
                    
                    comboBox.selectItem(at: index)
                    element.stringValue = element.stringValue ?? element.defaultValue[0]
                }
                
                // Set the delegate after setting the default value
                comboBox.delegate = self
                
                // Layout
                let font = comboBox.font!
                var width: CGFloat = 0
                for value in element.defaultValue {
                    let attributedString = NSAttributedString(string: value, attributes: [NSAttributedStringKey.font: font])
                    let size = attributedString.size()
                    if size.width > width {
                        width = size.width
                    }
                }
                comboBox.snp.makeConstraints { make in
                    if let previousElementView = previousElementView {
                        make.leading.equalTo(previousElementView.snp.trailing).offset(5)
                    } else {
                        make.leading.equalToSuperview().offset(5)
                    }
                    make.centerY.equalTo(self)
                    make.width.equalTo(width + 50)
                }
                
                previousElementView = comboBox
            case .button:
                // Create view
                let button = Button()
                button.bezelStyle = .rounded
                button.target = self
                button.action = #selector(buttonAction(_:))
                self.addSubview(button)
                elementViews.append(button)
                
                // Set value
                button.title = element.defaultValue[0]
                button.setAccessibilityLabel(element.label != nil ? element.label : button.title)
                
                // Layout
                var width: CGFloat = 0
                if let elementWidth = element.width {
                    width = elementWidth
                } else {
                    let font = button.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
                    let attributedString = NSAttributedString(string: button.title, attributes: [NSAttributedStringKey.font: font])
                    let size = attributedString.size()
                    width = size.width + 15
                }
                
                button.snp.makeConstraints { make in
                    make.trailing.equalToSuperview().offset(-10)
                    make.centerY.equalTo(self)
                    make.width.equalTo(width)
                }
                
                previousElementView = button
            }
            
            index += 1
        }
    }
    
    fileprivate let fullCharSet = CharacterSet(charactersIn: "1234567890.$")
    fileprivate let numDolSet = CharacterSet(charactersIn: "1234567890$")
    fileprivate let dolSet = CharacterSet(charactersIn: "$")
    @objc fileprivate override func controlTextDidChange(_ notification: Notification) {
        let textField = notification.object as! NSTextField
        if let index = elementViews.index(of: textField) {
            let element = rule.elements[index]
            let stringValue = textField.stringValue
            var allowed = true
            
            if element.type == .numberField {
                // Check if a non-number was entered
                let string = stringValue.hasPrefix("$") ? stringValue.substring(from: 1) : stringValue
                let chars = string.characters
                let isNumber = string.trimmingCharacters(in: fullCharSet.inverted).length == chars.count
                let multipleDecimals = string.trimmingCharacters(in: numDolSet).length > 1
                let isDollarAfterFirst = chars.count > 0 && string.trimmingCharacters(in: dolSet.inverted).length > 0
                allowed = isNumber && !multipleDecimals && !isDollarAfterFirst
                
                if !allowed {
                    // Reset the value
                    textField.stringValue = element.stringValue ?? ""
                    
                    // Reset the cursor
                    if let range = textField.currentEditor()?.selectedRange {
                        var location = 0
                        if let count = element.stringValue?.length {
                            if range.location == count {
                                location = count
                            } else if range.location > 0 {
                                location = range.location - 1
                            }
                            textField.currentEditor()?.selectedRange = NSMakeRange(location, 0)
                        }
                    }
                    
                    // Shake the view
                    textField.window?.shake()
                }
            }
            
            if allowed {
                rule.elements[index].stringValue = stringValue
                delegate?.ruleViewElementValueChanged(self, rule: rule, element: element, elementView: textField)
            }
        }
    }
    
    @objc fileprivate func comboBoxSelectionDidChange(_ notification: Notification) {
        let comboBox = notification.object as! NSComboBox
        if let index = elementViews.index(of: comboBox) {
            let stringValue = comboBox.itemObjectValue(at: comboBox.indexOfSelectedItem) as! String
            rule.elements[index].stringValue = stringValue
            delegate?.ruleViewElementValueChanged(self, rule: rule, element: rule.elements[index], elementView: comboBox)
        }
    }
    
    @objc fileprivate func removeButtonAction() {
        delegate?.ruleViewRemoveRule(self)
    }
    
    @objc fileprivate func addButtonAction() {
        delegate?.ruleViewShowChooserRule(self)
    }
    
    @objc fileprivate func buttonAction(_ sender: NSButton) {
        if let index = elementViews.index(of: sender) {
            delegate?.ruleViewElementValueChanged(self, rule: rule, element: rule.elements[index], elementView: sender)
        }
    }
}
