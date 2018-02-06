//
//  AccountTableViewCell.swift
//  BalanceiOS
//
//  Created by Red Davis on 05/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit

final class AccountTableViewCell: TableViewCell {
    var account: Account? {
        didSet {
            reloadData()
        }
    }
    
    private let currencyNameLabel = UILabel()
    private let amountLabel = UILabel()
    private let bottomBorder = UIView()
    
    // MARK: Initialization
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        
        self.backgroundView = nil
        self.backgroundColor = UIColor.clear
        
        // Currency name
        currencyNameLabel.font = CurrentTheme.accounts.cell.currencyNameFont
        currencyNameLabel.textColor = CurrentTheme.accounts.cell.currencyNameColor
        self.contentView.addSubview(currencyNameLabel)
        currencyNameLabel.snp.makeConstraints { make in
            make.bottom.equalTo(self.contentView.snp.centerY).offset(-2.0)
            make.left.equalTo(self.contentView.layoutMarginsGuide.snp.left)
        }
        
        // Amount label
        amountLabel.textColor = CurrentTheme.accounts.cell.amountColor
        amountLabel.font = CurrentTheme.accounts.cell.amountFont
        self.contentView.addSubview(amountLabel)
        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(self.contentView.snp.centerY).offset(2.0)
            make.left.equalTo(self.contentView.layoutMarginsGuide.snp.left)
        }
        
        // Detail label
        self.detailTextLabel?.font = CurrentTheme.accounts.cell.detailLabelFont
        self.detailTextLabel?.textColor = CurrentTheme.accounts.cell.detailLabelColor
        
        // Bottom border
        bottomBorder.backgroundColor = CurrentTheme.accounts.cell.bottomBorderColor
        self.contentView.addSubview(bottomBorder)
        bottomBorder.snp.makeConstraints { make in
            make.height.equalTo(1.0)
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
            make.left.equalToSuperview().inset(18.0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("unsupported")
    }
    
    // MARK: Data
    
    private func reloadData() {
        guard let account = account else {
            return
        }
        
        // Currency name label
        let currency = Currency.rawValue(account.currency)
        currencyNameLabel.text = currency.name
        
        // Amount label
        amountLabel.text = amountToString(amount: account.displayBalance, currency: currency, showNegative: true, showCodeAfterValue: true)
        
        // Detail label
        if let displayAltBalance = account.displayAltBalance {
            self.detailTextLabel?.text = amountToString(amount: displayAltBalance, currency: defaults.masterCurrency, showNegative: true, showCodeAfterValue: defaults.masterCurrency.isCrypto)
            self.detailTextLabel?.isHidden = false
        } else {
            self.detailTextLabel?.isHidden = true
        }
    }
}
