//
//  AccountTableViewCell.swift
//  BalanceiOS
//
//  Created by Red Davis on 05/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


final class AccountTableViewCell: TableViewCell {
    // Internal
    var account: Account? {
        didSet {
            self.reloadData()
        }
    }
    
    // Private
    private let currencyNameLabel: UILabel = {
        let label = UILabel()
        label.font = CurrentTheme.accounts.cell.currencyNameFont
        label.textColor = CurrentTheme.accounts.cell.currencyNameColor
        
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.textColor = CurrentTheme.accounts.cell.amountColor
        label.font = CurrentTheme.accounts.cell.amountFont
        
        return label
    }()
    
    private let bottomBorder: UIView = {
        let view = UIView()
        view.backgroundColor = CurrentTheme.accounts.cell.bottomBorderColor
        
        return view
    }()
    
    // MARK: Initialization
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        
        self.backgroundView = nil
        self.backgroundColor = UIColor.clear
        
        // Currency name
        self.contentView.addSubview(self.currencyNameLabel)
        
        self.currencyNameLabel.snp.makeConstraints { make in
            make.bottom.equalTo(self.contentView.snp.centerY).offset(-2.0)
            make.left.equalTo(self.contentView.layoutMarginsGuide.snp.left)
        }
        
        // Amount label
        self.contentView.addSubview(self.amountLabel)
        
        self.amountLabel.snp.makeConstraints { make in
            make.top.equalTo(self.contentView.snp.centerY).offset(2.0)
            make.left.equalTo(self.contentView.layoutMarginsGuide.snp.left)
        }
        
        // Detail label
        self.detailTextLabel?.font = CurrentTheme.accounts.cell.detailLabelFont
        self.detailTextLabel?.textColor = CurrentTheme.accounts.cell.detailLabelColor
        
        // Bottom border
        self.contentView.addSubview(self.bottomBorder)
        
        self.bottomBorder.snp.makeConstraints { make in
            make.height.equalTo(1.0)
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
            make.left.equalToSuperview().inset(18.0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
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
        self.amountLabel.text = amountToString(amount: unwrappedAccount.displayBalance, currency: currency, showNegative: true, showCodeAfterValue: true)
        
        // Detail label
        if let displayAltBalance = unwrappedAccount.displayAltBalance {
            self.detailTextLabel?.text = amountToString(amount: displayAltBalance, currency: defaults.masterCurrency, showNegative: true, showCodeAfterValue: defaults.masterCurrency.isCrypto)
            self.detailTextLabel?.isHidden = false
        } else {
            self.detailTextLabel?.isHidden = true
        }
    }
}
