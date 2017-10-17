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
    static let height: CGFloat = 50.0
    
    // Internal
    internal var account: Account? {
        didSet {
            self.reloadData()
        }
    }
    
    // Private
    
    // MARK: Initialization
    
    internal override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        
        self.backgroundView = nil
        self.backgroundColor = UIColor.clear
        
        // Text label
        self.textLabel?.textColor = UIColor.white
        self.textLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
        
        // Detail label
        self.detailTextLabel?.textColor = UIColor.white
        self.detailTextLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: .light)
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: Data
    
    private func reloadData() {
        guard let unwrappedAccount = self.account else {
            return
        }
        
        // Text label
        let currency = Currency.rawValue(unwrappedAccount.currency)
        self.textLabel?.text = amountToString(amount: unwrappedAccount.displayBalance, currency: currency)
        
        // Detail label
        let masterCurrency = defaults.masterCurrency
        if let displayAltBalance = unwrappedAccount.displayAltBalance {
            self.detailTextLabel?.text = amountToString(amount: displayAltBalance, currency: masterCurrency, showNegative: true)
            self.detailTextLabel?.isHidden = false
        } else {
            self.detailTextLabel?.isHidden = true
        }
    }
}
