//
//  CurrencyCollectionViewCell.swift
//  BalanceiOS
//
//  Created by Red Davis on 08/11/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


internal final class CurrencyCollectionViewCell: UICollectionViewCell, Reusable {
    // Private
    private let currencyNameLabel: UILabel = {
        let label = UILabel()
        label.font = CurrentTheme.priceTicker.cell.currencyNameFont
        
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = CurrentTheme.priceTicker.cell.amountFont
        
        return label
    }()
    
    // MARK: Initialization
    
    internal override init(frame: CGRect) {
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
        
        // Institution name label
        self.contentView.addSubview(self.currencyNameLabel)
        
        self.currencyNameLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(15.0)
        }
        
        // Amount label
        self.contentView.addSubview(self.amountLabel)
        
        self.amountLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(15.0)
        }
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        abort()
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    }
    
    // MARK: Data
    
    func update(currency: Currency, rate: String) {
        self.currencyNameLabel.text = currency.longName
        self.amountLabel.text = rate
    }
}
