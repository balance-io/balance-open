//
//  TotalBalanceBar.swift
//  BalanceiOS
//
//  Created by Red Davis on 16/11/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit

final class TotalBalanceBar: UIView {
    let loadingSpinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    let titleLabel = UILabel()
    let totalBalanceLabel = UILabel()
    
    // MARK: Initialization
    
    required init() {
        super.init(frame: .zero)
        
        self.backgroundColor = CurrentTheme.accounts.balanceBar.backgroundColor
        
        // Container
        let container = UIView()
        self.addSubview(container)
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Title label
        titleLabel.text = "Balance"
        titleLabel.font = CurrentTheme.accounts.balanceBar.titleFont
        titleLabel.textColor = CurrentTheme.accounts.balanceBar.titleColor
        container.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16.0)
        }
        
        // LoadingSpinner
        container.addSubview(loadingSpinner)
        loadingSpinner.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(titleLabel.snp.right).offset(10.0)
        }
        
        // Total balance label
        totalBalanceLabel.font = CurrentTheme.accounts.balanceBar.totalBalanceFont
        totalBalanceLabel.textColor = CurrentTheme.accounts.balanceBar.totalBalanceColor
        container.addSubview(totalBalanceLabel)
        totalBalanceLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16.0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("unsupported")
    }
    
    // MARK: Autolayout
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: CurrentTheme.accounts.balanceBar.height)
    }
}
