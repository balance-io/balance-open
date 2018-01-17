//
//  TotalBalanceBar.swift
//  BalanceiOS
//
//  Created by Red Davis on 16/11/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit

internal final class TotalBalanceBar: UIView {
    // Internal
    internal let totalBalanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.Balance.monoFont(ofSize: 16.0, weight: .bold)
        label.textColor = UIColor.white
        
        return label
    }()
    
    // Private
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Balance"
        label.font = UIFont.Balance.font(ofSize: 16.0, weight: .semibold)
        label.textColor = UIColor.white
        
        return label
    }()
    
    // MARK: Initialization
    
    internal required init() {
        super.init(frame: .zero)
        
        self.backgroundColor = UIColor(red: 39.0/255.0, green: 45.0/255.0, blue: 54.0/255.0, alpha: 0.6)
        
        // Container
        let container = UIView()
        self.addSubview(container)
        
        container.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        // Title label
        container.addSubview(self.titleLabel)
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(16.0)
        }
        
        // Total balance label
        container.addSubview(self.totalBalanceLabel)
        
        self.totalBalanceLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(16.0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        abort()
    }
    
    // MARK: Autolayout
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 60.0)
    }
}
