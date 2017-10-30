//
//  TransactionsHeaderReusableView.swift
//  BalanceiOS
//
//  Created by Red Davis on 19/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


internal final class TransactionsHeaderReusableView: UICollectionReusableView, Reusable {
    // Intenral
    internal let textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11.0, weight: .medium)
        label.textColor = UIColor(red: 60.0/255.0, green: 68.0/255.0, blue: 79.0/255.0, alpha: 0.4)
        
        return label
    }()
    
    // MARK: Initialization
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Text label
        self.addSubview(self.textLabel)
        
        self.textLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(14.0)
            make.bottom.equalToSuperview().inset(9.0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
