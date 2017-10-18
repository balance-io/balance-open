//
//  TransactionTableViewCell.swift
//  BalanceiOS
//
//  Created by Red Davis on 03/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


internal final class TransactionTableViewCell: TableViewCell
{
    // Static
    static let height: CGFloat = 60.0
    
    // Internal
    internal var transaction: Transaction? {
        didSet
        {
            self.reloadData()
        }
    }
    
    // Private
    private let institutionNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12.0, weight: .medium)
        
        return label
    }()
    
    private let transactionTypeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12.0, weight: .medium)
        
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)
        
        return label
    }()
    
    private let userCurrencyAmountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)
        
        return label
    }()
    
    // MARK: Initialization
    
    internal override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        // Institution name label
        self.contentView.addSubview(self.institutionNameLabel)
        
        self.institutionNameLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.contentView.snp.centerY).offset(-2.0)
            make.right.equalToSuperview().inset(15.0)
        }
        
        // Transaction type
        self.contentView.addSubview(self.transactionTypeLabel)
        
        self.transactionTypeLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.contentView.snp.centerY).offset(-2.0)
            make.left.equalToSuperview().inset(15.0)
        }
        
        // Amount label
        self.contentView.addSubview(self.amountLabel)
        
        self.amountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView.snp.centerY).offset(2.0)
            make.left.equalToSuperview().inset(15.0)
        }
        
        // User currency amount label
        self.contentView.addSubview(self.userCurrencyAmountLabel)
        
        self.userCurrencyAmountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView.snp.centerY).offset(2.0)
            make.right.equalToSuperview().inset(15.0)
        }
    }
    
    internal required init?(coder aDecoder: NSCoder)
    {
        fatalError()
    }
    
    // MARK: Data
    
    private func reloadData()
    {
        guard let unwrappedTransaction = self.transaction else
        {
            return
        }
        
        self.institutionNameLabel.text = unwrappedTransaction.institution?.displayName
        self.institutionNameLabel.textColor = unwrappedTransaction.source.color
        
        // Amount
        let currency = Currency.rawValue(unwrappedTransaction.currency)
        self.amountLabel.text = amountToString(amount: unwrappedTransaction.amount, currency: currency)
        
        // User currency amount
        let masterCurrency = defaults.masterCurrency
        if let masterAmount = unwrappedTransaction.masterAltAmount {
            self.userCurrencyAmountLabel.text = amountToString(amount: masterAmount, currency: masterCurrency, showNegative: true)
            self.userCurrencyAmountLabel.isHidden = false
        } else {
            self.userCurrencyAmountLabel.isHidden = true
        }
        
        // Transaction type
        self.transactionTypeLabel.textColor = unwrappedTransaction.source.color
        if unwrappedTransaction.amount > 0
        {
            self.transactionTypeLabel.text = "Received"
        }
        else
        {
            self.transactionTypeLabel.text = "Sent"
        }
    }
}
