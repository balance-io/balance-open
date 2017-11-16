//
//  AccountTableViewCell.swift
//  BalanceiOS
//
//  Created by Red Davis on 05/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


internal final class AccountTableViewCell: TableViewCell {
    // Static
    static let height: CGFloat = 60.0
    
    // Internal
    internal var account: Account? {
        didSet {
            self.reloadData()
        }
    }
    
    // Private
    private let currencyNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(white: 1.0, alpha: 0.8)
        label.font = UIFont.Balance.monoFont(ofSize: 12.5, weight: .regular)
        
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(white: 1.0, alpha: 0.95)
        label.font = UIFont.Balance.monoFont(ofSize: 12.5, weight: .regular)
        
        return label
    }()
    
    private let bottomBorder: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.06)
        
        return view
    }()
    
    // MARK: Initialization
    
    internal override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        
        self.backgroundView = nil
        self.backgroundColor = UIColor.clear
        
        // Currency name
        self.contentView.addSubview(self.currencyNameLabel)
        
        self.currencyNameLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.contentView.snp.centerY).offset(-2.0)
            make.left.equalTo(self.contentView.layoutMarginsGuide.snp.left)
        }
        
        // Amount label
        self.contentView.addSubview(self.amountLabel)
        
        self.amountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView.snp.centerY).offset(2.0)
            make.left.equalTo(self.contentView.layoutMarginsGuide.snp.left)
        }
        
        // Detail label
        self.detailTextLabel?.textColor = UIColor.white
        self.detailTextLabel?.font = UIFont.Balance.monoFont(ofSize: 14.0, weight: .medium)
        
        // Bottom border
        self.contentView.addSubview(self.bottomBorder)
        
        self.bottomBorder.snp.makeConstraints { (make) in
            make.height.equalTo(1.0)
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
            make.left.equalToSuperview().inset(18.0)
        }
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: Data
    
    private func reloadData() {
        guard let unwrappedAccount = self.account else {
            return
        }
        
        // Currency name label
        let currency = Currency.rawValue(unwrappedAccount.currency)
        self.currencyNameLabel.text = currency.name
        
        // Amount label
        self.amountLabel.text = amountToString(amount: unwrappedAccount.displayBalance, currency: currency)
        
        // Detail label
        let masterCurrency = defaults.masterCurrency!
        if let displayAltBalance = unwrappedAccount.displayAltBalance {
            self.detailTextLabel?.text = amountToString(amount: displayAltBalance, currency: masterCurrency, showNegative: true)
            self.detailTextLabel?.isHidden = false
        } else {
            self.detailTextLabel?.isHidden = true
        }
    }
}
