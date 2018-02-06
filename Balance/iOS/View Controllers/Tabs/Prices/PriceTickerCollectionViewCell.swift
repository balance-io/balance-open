//
//  PriceTickerCollectionViewCell.swift
//  BalanceiOS
//
//  Created by Red Davis on 08/11/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit

final class PriceTickerCollectionViewCell: UICollectionViewCell, Reusable {
    private let currencyNameLabel = UILabel()
    private let amountLabel = UILabel()
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        
        self.layer.shadowColor = CurrentTheme.priceTicker.cell.shadowColor.cgColor
        self.layer.shadowOffset = CurrentTheme.priceTicker.cell.shadowOffset
        self.layer.shadowRadius = CurrentTheme.priceTicker.cell.shadowRadius
        self.layer.shadowOpacity = CurrentTheme.priceTicker.cell.shadowOpacity
        self.layer.masksToBounds = false
        
        self.contentView.backgroundColor = CurrentTheme.priceTicker.cell.backgroundColor
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = CurrentTheme.priceTicker.cell.cornerRadius
        
        // Currency name label
        currencyNameLabel.font = CurrentTheme.priceTicker.cell.currencyNameFont
        self.contentView.addSubview(currencyNameLabel)
        currencyNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(15.0)
        }
        
        // Amount label
        amountLabel.font = CurrentTheme.priceTicker.cell.amountFont
        self.contentView.addSubview(amountLabel)
        amountLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(15.0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("unsupported")
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    }
    
    // MARK: Data
    
    func update(currency: Currency, rate: String) {
        currencyNameLabel.text = currency.longName
        amountLabel.text = rate
    }
}
