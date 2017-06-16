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
        
//        let sourceInstitutionId = institutionsDatabase.primaryInstitutionId(sourceInstitutionId: model.sourceInstitutionId) ?? model.sourceInstitutionId
//        if let headerView = InstitutionHeaders.headerViewForId(sourceInstitutionId: sourceInstitutionId) {
//            self.addSubview(headerView)
//            self.headerView = headerView
//        } else if let headerView = InstitutionHeaders.defaultHeaderView(backgroundColor: model.displayColor, foregroundColor: CurrentTheme.accounts.headerCell.genericInstitutionTextColor, font: CurrentTheme.accounts.headerCell.genericInstitutionFont, name: model.name) {
//            self.addSubview(headerView)
//            self.headerView = headerView
//        }
//        
//        self.alphaValue = (debugging.showAllInstitutionsAsIncorrectPassword || model.passwordInvalid) ? CurrentTheme.accounts.cell.passwordInvalidDimmedAlpha : 1.0
        
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
            make.bottom.equalTo(-14.5)
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
            make.trailing.equalToSuperview().inset(-5)
            make.top.equalToSuperview().inset(13)
            make.height.equalToSuperview()
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
        
        nameField.stringValue = updatedModel.displayName
        nameField.setAccessibilityLabel("Account Name")
        
        self.setAccessibilityLabel(updatedModel.displayName)
        
        if model?.accountType == .credit, let number = model?.number {
            nameField.stringValue = "\(nameField.stringValue) (\(number))"
        }
    }
}
