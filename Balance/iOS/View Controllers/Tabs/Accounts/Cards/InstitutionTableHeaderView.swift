//
//  InstitutionTableHeaderView.swift
//  BalanceiOS
//
//  Created by Red Davis on 05/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit

fileprivate extension Source {
    var accountsLogo: UIImage? {
        switch self {
        case .coinbase: return #imageLiteral(resourceName: "coinbaseAccounts")
        case .poloniex: return #imageLiteral(resourceName: "poloniexAccounts")
        case .gdax:     return #imageLiteral(resourceName: "gdaxAccounts")
        case .bitfinex: return #imageLiteral(resourceName: "bitfinexAccounts")
        case .kraken:   return #imageLiteral(resourceName: "krakenAccounts")
        case .bittrex:  return #imageLiteral(resourceName: "bittrexAccounts")
        default:        return nil
        }
    }
}

final class InstitutionTableHeaderView: UITableViewHeaderFooterView, Reusable {
    var institution: Institution? {
        didSet {
            reloadData()
        }
    }

    private let logoView = UIImageView()
    private let nameLabel = UILabel()
    private let totalBalanceLabel = UILabel()
    private let bottomBorder = UIView()
    
    // MARK: Initialization
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        // Name label
        nameLabel.font = CurrentTheme.accounts.headerCell.nameFont
        nameLabel.textColor = CurrentTheme.accounts.headerCell.nameColor
        self.contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15.0)
            make.centerY.equalToSuperview()
        }
        
        // Total balance label
        totalBalanceLabel.font = CurrentTheme.accounts.headerCell.totalBalanceFont
        totalBalanceLabel.textColor = CurrentTheme.accounts.headerCell.totalBalanceColor
        self.contentView.addSubview(totalBalanceLabel)
        totalBalanceLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(15.0)
            make.centerY.equalToSuperview()
        }
        
        // Logo view
        logoView.backgroundColor = UIColor.clear
        logoView.isHidden = true
        self.contentView.addSubview(logoView)
        logoView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.width.equalTo(0)
            make.height.equalTo(0)
            make.centerY.equalToSuperview()
        }
        
        // Bottom border
        bottomBorder.backgroundColor = CurrentTheme.accounts.headerCell.bottomBorderColor
        self.contentView.addSubview(bottomBorder)
        bottomBorder.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
            make.left.equalToSuperview().offset(18)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("unsupported")
    }
    
    // MARK: Data
    
    private func reloadData() {
        guard let unwrappedInstitution = self.institution else {
            return
        }
        
        nameLabel.text = unwrappedInstitution.displayName

        if let logo = unwrappedInstitution.source.accountsLogo {
            logoView.image = logo
            logoView.snp.updateConstraints { make in
                make.width.equalTo(logo.size.width)
                make.height.equalTo(logo.size.height)
            }
            
            nameLabel.isHidden = true
            logoView.isHidden = false
        } else {
            nameLabel.isHidden = false
            logoView.isHidden = true
        }
        
        // Total balance
        let accounts = AccountRepository.si.accounts(institutionId: unwrappedInstitution.institutionId, includeHidden: false)
        let totalAmount = accounts.reduce(0) { (total, account) -> Int in
            return total + (account.displayAltBalance ?? 0)
        }
        totalBalanceLabel.text = amountToString(amount: totalAmount, currency: defaults.masterCurrency, showNegative: true, showCodeAfterValue: true)
    }
}
