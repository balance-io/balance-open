//
//  InstitutionTableHeaderView.swift
//  BalanceiOS
//
//  Created by Red Davis on 05/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

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
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: Data
    
    private func reloadData() {
        guard let unwrappedInstitution = self.institution else {
            return
        }
        
        self.contentView.backgroundColor = unwrappedInstitution.displayColor
        self.nameLabel.text = unwrappedInstitution.displayName
        self.totalBalanceLabel.text = "TODO: $1,000,000"
        
        
    }
}
