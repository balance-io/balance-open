//
//  TransactionTableViewCell.swift
//  BalanceiOS
//
//  Created by Red Davis on 03/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import BalanceVectorGraphics_iOS
import UIKit


internal final class TransactionCollectionViewCell: UICollectionViewCell, Reusable
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
    private let logoView = PaintCodeView()
    
    private let institutionNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12.0, weight: .medium)
        
        return label
    }()
    
    private let transactionTypeImageView = UIImageView()
    
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
        
        // Transaction type image view
        self.contentView.addSubview(self.transactionTypeImageView)
        
        self.transactionTypeImageView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.contentView.snp.centerY).offset(-5.0)
            make.left.equalToSuperview().inset(15.0)
        }
        
        // Transaction type
        self.contentView.addSubview(self.transactionTypeLabel)
        
        self.transactionTypeLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.transactionTypeImageView)
            make.left.equalTo(self.transactionTypeImageView.snp.right).offset(5.0)
        }
        
        // Institution name label
        self.contentView.addSubview(self.institutionNameLabel)
        
        self.institutionNameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.transactionTypeImageView)
            make.right.equalToSuperview().inset(15.0)
        }
        
        // Logo view
        self.logoView.isHidden = true
        self.contentView.addSubview(self.logoView)
        
        self.logoView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.transactionTypeImageView)
            make.right.equalToSuperview()
            make.width.equalTo(75.0)
            make.height.equalTo(25.0)
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
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    }
    
    // MARK: Data
    
    private func reloadData()
    {
        guard let unwrappedTransaction = self.transaction,
              let institution = unwrappedTransaction.institution else
        {
            return
        }
        
        // Amount
        let currency = Currency.rawValue(unwrappedTransaction.currency)
        self.amountLabel.text = amountToString(amount: unwrappedTransaction.amount, currency: currency)
        
        // User currency amount
        let masterCurrency = defaults.masterCurrency!
        if let masterAmount = unwrappedTransaction.masterAltAmount {
            self.userCurrencyAmountLabel.text = amountToString(amount: masterAmount, currency: masterCurrency, showNegative: true)
            self.userCurrencyAmountLabel.isHidden = false
        } else {
            self.userCurrencyAmountLabel.isHidden = true
        }
        
        // Transaction type
        self.transactionTypeLabel.textColor = unwrappedTransaction.source.color
        self.transactionTypeImageView.tintColor = unwrappedTransaction.source.color
        if unwrappedTransaction.amount > 0
        {
            self.transactionTypeLabel.text = "Received"
            self.transactionTypeImageView.image = UIImage(named: "Received")
        }
        else
        {
            self.transactionTypeLabel.text = "Sent"
            self.transactionTypeImageView.image = UIImage(named: "Sent")
        }
        
        // Institution
        self.institutionNameLabel.text = institution.displayName
        self.institutionNameLabel.textColor = unwrappedTransaction.source.color
        
        // TODO:
        // Currently the coinbase logo is white, which won't be visible
        // on this view.
        
//        let institutionID = institution.source.description
//        if let logoDrawFunction = InstitutionLogos.drawingFunctionForId(sourceInstitutionId: institutionID) {
//            self.logoView.drawingBlock = logoDrawFunction
//
//            self.institutionNameLabel.isHidden = true
//            self.logoView.isHidden = false
//        } else {
//            self.institutionNameLabel.isHidden = false
//            self.logoView.isHidden = true
//        }
    }
}
