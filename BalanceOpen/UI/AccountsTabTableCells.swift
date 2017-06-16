//
//  AccountsTabTableCells.swift
//  Bal
//
//  Created by Benjamin Baron on 5/22/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

class AccountsTabGroupCell: View {
    var headerView: NSView?
    
    init() {
        super.init(frame: NSZeroRect)
        self.layerBackgroundColor = CurrentTheme.defaults.cell.backgroundColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    func updateModel(_ model: Institution) {
        self.headerView?.removeFromSuperview()
        self.headerView = nil
        
        if let headerView = InstitutionHeaders.headerViewForId(model.sourceId.description) {
            self.addSubview(headerView)
            self.headerView = headerView
        } else if let headerView = InstitutionHeaders.defaultHeaderView(backgroundColor: model.displayColor, foregroundColor: CurrentTheme.accounts.headerCell.genericInstitutionTextColor, font: CurrentTheme.accounts.headerCell.genericInstitutionFont, name: model.name) {
            self.addSubview(headerView)
            self.headerView = headerView
        }
        
        self.setAccessibilityLabel("Section: " + model.name)
    }
}

typealias RowBackgroundColor = (_ index: TableIndex) -> NSColor?
class AccountsTabAccountCell: View {
    var model: Account?
    var index = TableIndex.none
    var rowBackgroundColor: RowBackgroundColor?
    
    let nameField = LabelField()
    let inclusionIndicator = ImageView()
    let amountField = LabelField()
    let altAmountField = LabelField()
    
    static var dateFormatter = DateFormatter()
    
    init() {
        super.init(frame: NSZeroRect)
        self.layerBackgroundColor = CurrentTheme.defaults.cell.backgroundColor
        
        amountField.backgroundColor = CurrentTheme.defaults.cell.backgroundColor
        amountField.font = CurrentTheme.accounts.cell.amountFont
        amountField.usesSingleLineMode = true
        self.addSubview(amountField)
        amountField.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.trailing.equalToSuperview().inset(12)
            make.top.equalToSuperview().offset(8)
        }
        
        altAmountField.backgroundColor = CurrentTheme.defaults.cell.backgroundColor
        altAmountField.font = CurrentTheme.accounts.cell.altAmountFont
        altAmountField.textColor = CurrentTheme.accounts.cell.altAmountColor
        altAmountField.usesSingleLineMode = true
        self.addSubview(altAmountField)
        altAmountField.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        nameField.backgroundColor = CurrentTheme.defaults.cell.backgroundColor
        nameField.alignment = .left
        nameField.font = CurrentTheme.accounts.cell.nameFont
        nameField.textColor = CurrentTheme.defaults.foregroundColor
        nameField.usesSingleLineMode = true
        nameField.cell?.lineBreakMode = .byTruncatingTail
        self.addSubview(nameField)
        nameField.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.trailing.equalTo(amountField.snp.leading).inset(-5)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    func updateModel(_ updatedModel: Account) {
        model = updatedModel
        
        if let currency = Currency(rawValue: updatedModel.currency) {
            amountField.attributedStringValue = amountToStringFormatted(amount: updatedModel.displayBalance, currency: currency, showNegative: true)
            amountField.setAccessibilityLabel("Account Total")
            amountField.snp.updateConstraints { make in
                let width = amountField.stringValue.size(font: CurrentTheme.accounts.cell.amountFont)
                make.width.equalTo(width)
            }
        }
        
        if updatedModel.altCurrency != nil && updatedModel.currency != updatedModel.altCurrency {
            if let altCurrency = Currency(rawValue: updatedModel.altCurrency!), let altCurrentBalance = updatedModel.altCurrentBalance {
                altAmountField.stringValue = amountToString(amount: altCurrentBalance, currency: altCurrency, showNegative: true)
                altAmountField.setAccessibilityLabel("Account Total")
                altAmountField.snp.updateConstraints { make in
                    let width = altAmountField.stringValue.size(font: CurrentTheme.accounts.cell.amountFont)
                    make.width.equalTo(width)
                }
            }
            
            altAmountField.isHidden = false
            amountField.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(8)
            }
        } else {
            altAmountField.isHidden = true
            amountField.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(20)
            }
        }
        
        nameField.stringValue = updatedModel.displayName
        nameField.setAccessibilityLabel("Account Name")
        
        self.setAccessibilityLabel(updatedModel.displayName)
        
        if model?.accountType == .credit, let number = model?.number {
            nameField.stringValue = "\(nameField.stringValue) (\(number))"
        }
    }
}
