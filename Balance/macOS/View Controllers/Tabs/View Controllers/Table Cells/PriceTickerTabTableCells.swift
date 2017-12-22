//
//  PriceTickerTabTableCells.swift
//  BalancemacOS
//
//  Created by Benjamin Baron on 11/2/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

fileprivate let padding = 18
fileprivate let linePadding = padding - 2

class PriceTickerRateCell: View {
    var model: ExchangeRate?
    
    let topContainer = View()
    let codeField = LabelField()
    let nameField = LabelField()
    let rateField = LabelField()
    let lineView = View()
    
    init() {
        super.init(frame: NSZeroRect)
        self.layerBackgroundColor = CurrentTheme.defaults.cell.backgroundColor
        
        self.addSubview(topContainer)
        topContainer.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(CurrentTheme.priceTicker.cell.height)
        }
        
        codeField.setAccessibilityLabel("Currency Code")
        codeField.alphaValue = 0.80
        codeField.backgroundColor = CurrentTheme.defaults.cell.backgroundColor
        codeField.alignment = .left
        codeField.font = CurrentTheme.priceTicker.cell.codeFont
        codeField.textColor = CurrentTheme.priceTicker.cell.codeColor
        codeField.usesSingleLineMode = true
        codeField.cell?.lineBreakMode = .byTruncatingTail
        topContainer.addSubview(codeField)
        codeField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(padding)
            make.right.equalToSuperview().offset(-padding)
            make.top.equalToSuperview().offset(11)
        }
        
        nameField.setAccessibilityLabel("Currency Name")
        nameField.alphaValue = 0.95
        nameField.backgroundColor = CurrentTheme.defaults.cell.backgroundColor
        nameField.font = CurrentTheme.priceTicker.cell.nameFont
        nameField.textColor = CurrentTheme.priceTicker.cell.nameColor
        nameField.usesSingleLineMode = true
        nameField.alignment = .left
        topContainer.addSubview(nameField)
        nameField.snp.makeConstraints { make in
            make.left.equalTo(codeField)
            make.top.equalToSuperview().offset(31)
        }
        
        rateField.setAccessibilityLabel("Exchange Rate")
        rateField.backgroundColor = CurrentTheme.defaults.cell.backgroundColor
        rateField.font = CurrentTheme.priceTicker.cell.rateFont
        rateField.textColor = CurrentTheme.priceTicker.cell.rateColor
        rateField.usesSingleLineMode = true
        topContainer.addSubview(rateField)
        rateField.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-padding)
            make.top.equalToSuperview().offset(31)
        }
        
        lineView.layerBackgroundColor = NSColor(hexString: "#B0B5BC")
        lineView.alphaValue = 0.08
        topContainer.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(linePadding)
            make.bottom.equalToSuperview().offset(-1)
            make.height.equalTo(1)
            make.right.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    func updateModel(currency: Currency, rate: String) {
        codeField.stringValue = currency.code
        nameField.stringValue = currency.name
        rateField.stringValue = rate
    }
}
