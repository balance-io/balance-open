//
//  CurrencyCollectionViewCell.swift
//  BalanceiOS
//
//  Created by Red Davis on 08/11/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


internal final class CurrencyCollectionViewCell: UICollectionViewCell, Reusable {
    // Static
    static let height: CGFloat = 60.0
    
    // Private
    private let currencyNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.Balance.monoFont(ofSize: 12.5, weight: .regular)
        
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.Balance.monoFont(ofSize: 12.5, weight: .regular)
        
        return label
    }()
    
    // MARK: Initialization
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.04
        self.layer.masksToBounds = false
        
        self.contentView.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = 20.0
        
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
