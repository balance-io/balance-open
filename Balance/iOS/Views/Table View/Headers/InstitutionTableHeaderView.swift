//
//  InstitutionTableHeaderView.swift
//  BalanceiOS
//
//  Created by Red Davis on 05/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import BalanceVectorGraphics_iOS
import UIKit


internal final class InstitutionTableHeaderView: UITableViewHeaderFooterView, Reusable {
    // Static
    internal static let height: CGFloat = 60.0
    
    // Internal
    internal var institution: Institution? {
        didSet {
            self.reloadData()
        }
    }

    // Private
    private let logoView = PaintCodeView()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
        
        return label
    }()
    
    private let totalBalanceLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
        
        return label
    }()
    
    // MARK: Initialization
    
    internal override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        // Name label
        self.contentView.addSubview(self.nameLabel)
        
        self.nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(15.0)
            make.centerY.equalToSuperview()
        }
        
        // Total balance label
        self.contentView.addSubview(self.totalBalanceLabel)
        
        self.totalBalanceLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(15.0)
            make.centerY.equalToSuperview()
        }
        
        // Logo view
        self.logoView.backgroundColor = UIColor.clear
        self.logoView.isHidden = true
        self.contentView.addSubview(self.logoView)
        
        self.logoView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.equalTo(140.0)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: Data
    
    private func reloadData() {
        guard let unwrappedInstitution = self.institution else {
            return
        }
        
        self.nameLabel.text = unwrappedInstitution.displayName
        self.totalBalanceLabel.text = "TODO: $1,000,000"

        let institutionID = unwrappedInstitution.source.description
        if let logoDrawFunction = InstitutionLogos.drawingFunctionForId(sourceInstitutionId: institutionID) {
            self.logoView.drawingBlock = logoDrawFunction
            
            self.nameLabel.isHidden = true
            self.logoView.isHidden = false
        } else {
            self.nameLabel.isHidden = false
            self.logoView.isHidden = true
        }
        
        // Total balance
        let accounts = AccountRepository.si.accounts(institutionId: unwrappedInstitution.institutionId, includeHidden: false)
        let totalAmount = accounts.reduce(0) { (total, account) -> Int in
            return total + (account.displayAltBalance ?? 0)
        }
        
        self.totalBalanceLabel.text = amountToString(amount: totalAmount, currency: defaults.masterCurrency, showNegative: true, showCodeAfterValue: true)
    }
}
