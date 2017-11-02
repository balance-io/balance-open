//
//  PriceTickerTabTableCells.swift
//  BalancemacOS
//
//  Created by Benjamin Baron on 11/2/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

class PriceTickerRateCell: View {
    let rateField = LabelField()
    
    init() {
        super.init(frame: NSZeroRect)
        
        self.layerBackgroundColor = CurrentTheme.defaults.backgroundColor
        
        rateField.textColor = .black
        rateField.font = NSFont.systemFont(ofSize: 14)
        rateField.backgroundColor = CurrentTheme.defaults.backgroundColor
        rateField.layerBackgroundColor = CurrentTheme.defaults.backgroundColor
        self.addSubview(rateField)
        rateField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalTo(self)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    func updateModel(_ model: String) {
        rateField.stringValue = model
    }
}
