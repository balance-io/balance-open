//
//  TransactionTableViewCell.swift
//  BalanceiOS
//
//  Created by Red Davis on 03/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit

fileprivate extension Source {
    var transactionsLogo: UIImage? {
        switch self {
        case .coinbase: return #imageLiteral(resourceName: "coinbaseTransactions")
        case .poloniex: return #imageLiteral(resourceName: "poloniexTransactions")
        case .gdax:     return #imageLiteral(resourceName: "gdaxTransactions")
        case .bitfinex: return #imageLiteral(resourceName: "bitfinexTransactions")
        case .kraken:   return #imageLiteral(resourceName: "krakenTransactions")
        case .bittrex:  return #imageLiteral(resourceName: "bittrexTransactions")
        default:        return nil
        }
    }
}

fileprivate let hideConvertedAmounts = true
final class TransactionCollectionViewCell: UICollectionViewCell, Reusable
{
    // Internal
    var transaction: Transaction? {
        didSet
        {
            self.reloadData()
        }
    }
    
    // Private
    private let logoView = UIImageView()
    
    private let institutionNameLabel: UILabel = {
        let label = UILabel()
        label.font = CurrentTheme.transactions.cell.institutionNameFont
        
        return label
    }()
    
    private let transactionTypeImageView = UIImageView()
    
    private let transactionTypeLabel: UILabel = {
        let label = UILabel()
        label.font = CurrentTheme.transactions.cell.transactionTypeFont
        
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = CurrentTheme.transactions.cell.amountFont
        
        return label
    }()
    
    private let userCurrencyAmountLabel: UILabel = {
        let label = UILabel()
        label.font = CurrentTheme.transactions.cell.userCurrencyAmountFont
        
        return label
    }()
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        
        self.layer.shadowColor = CurrentTheme.transactions.cell.shadowColor.cgColor
        self.layer.shadowOffset = CurrentTheme.transactions.cell.shadowOffset
        self.layer.shadowRadius = CurrentTheme.transactions.cell.shadowRadius
        self.layer.shadowOpacity = CurrentTheme.transactions.cell.shadowOpacity
        self.layer.masksToBounds = false
        
        self.contentView.backgroundColor = CurrentTheme.transactions.cell.backgroundColor
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = CurrentTheme.transactions.cell.cornerRadius
        
        // Transaction type image view
        self.contentView.addSubview(self.transactionTypeImageView)
        self.transactionTypeImageView.snp.makeConstraints { make in
            make.bottom.equalTo(self.contentView.snp.centerY).offset(-5.0)
            make.left.equalToSuperview().inset(15.0)
        }
        
        // Transaction type
        self.contentView.addSubview(self.transactionTypeLabel)
        self.transactionTypeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.transactionTypeImageView)
            make.left.equalTo(self.transactionTypeImageView.snp.right).offset(5.0)
        }
        
        // Institution name label
        self.contentView.addSubview(self.institutionNameLabel)
        self.institutionNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.transactionTypeImageView)
            make.right.equalToSuperview().inset(15.0)
        }
        
        // Logo view
        self.logoView.isHidden = true
        self.contentView.addSubview(self.logoView)
        self.logoView.snp.makeConstraints { make in
            make.centerY.equalTo(self.transactionTypeImageView)
            make.right.equalToSuperview().offset(-10)
            make.width.equalTo(0)
            make.height.equalTo(0)
        }
        
        // Amount label
        self.contentView.addSubview(self.amountLabel)
        self.amountLabel.snp.makeConstraints { make in
            make.top.equalTo(self.contentView.snp.centerY).offset(2.0)
            make.left.equalToSuperview().inset(15.0)
        }
        
        // User currency amount label
        self.contentView.addSubview(self.userCurrencyAmountLabel)
        self.userCurrencyAmountLabel.snp.makeConstraints { make in
            make.top.equalTo(self.contentView.snp.centerY).offset(2.0)
            make.right.equalToSuperview().inset(15.0)
        }
        self.userCurrencyAmountLabel.isHidden = hideConvertedAmounts
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError()
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    }
    
    // MARK: Data
    
    private func reloadData() {
        guard let transaction = transaction, let institution = transaction.institution else {
            return
        }
        
        // Amount
        let currency = Currency.rawValue(transaction.currency)
        amountLabel.text = amountToString(amount: transaction.amount, currency: currency)
        
        // User currency amount
        if !hideConvertedAmounts, let masterCurrency = defaults.masterCurrency {
            if let masterAmount = transaction.masterAltAmount {
                userCurrencyAmountLabel.text = amountToString(amount: masterAmount, currency: masterCurrency, showNegative: true)
                userCurrencyAmountLabel.isHidden = false
            } else {
                userCurrencyAmountLabel.isHidden = true
            }
        }
        
        // Transaction type
        transactionTypeLabel.textColor = transaction.source.color
        transactionTypeImageView.tintColor = transaction.source.color
        let transactionType = transaction.amount > 0 ? "Received" : "Sent"
        transactionTypeLabel.text = transactionType
        transactionTypeImageView.image = UIImage(named: transactionType)
        
        // Institution
        institutionNameLabel.text = institution.displayName
        institutionNameLabel.textColor = transaction.source.color
        
        if let logo = institution.source.transactionsLogo {
            logoView.image = logo
            logoView.snp.updateConstraints { make in
                make.width.equalTo(logo.size.width)
                make.height.equalTo(logo.size.height)
            }

            institutionNameLabel.isHidden = true
            logoView.isHidden = false
        } else {
            institutionNameLabel.isHidden = false
            logoView.isHidden = true
        }
    }
}
