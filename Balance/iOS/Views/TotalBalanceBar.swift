//
//  TotalBalanceBar.swift
//  BalanceiOS
//
//  Created by Red Davis on 16/11/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit

internal final class TotalBalanceBar: UIView {
    let loadingSpinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Balance"
        label.font = CurrentTheme.accounts.balanceBar.titleFont
        label.textColor = CurrentTheme.accounts.balanceBar.titleColor
        
        return label
    }()
    
    let totalBalanceLabel: UILabel = {
        let label = UILabel()
        label.font = CurrentTheme.accounts.balanceBar.totalBalanceFont
        label.textColor = CurrentTheme.accounts.balanceBar.totalBalanceColor
        
        return label
    }()
    
    // MARK: Initialization
    
    internal required init() {
        super.init(frame: .zero)
        
        self.backgroundColor = CurrentTheme.accounts.balanceBar.backgroundColor
        
        // Container
        let container = UIView()
        self.addSubview(container)
        container.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        // Title label
        container.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(16.0)
        }
        
        // LoadingSpinner
        container.addSubview(loadingSpinner)
        loadingSpinner.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(titleLabel.snp.right).offset(10.0)
        }
        
        // Total balance label
        container.addSubview(totalBalanceLabel)
        totalBalanceLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(16.0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        abort()
    }
    
    // MARK: Autolayout
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: CurrentTheme.accounts.balanceBar.height)
    }
}
