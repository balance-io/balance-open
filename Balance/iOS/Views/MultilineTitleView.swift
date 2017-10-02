//
//  MultilineTitleView.swift
//  Red Davis
//
//  Created by Red Davis on 23/05/2017.
//  Copyright © 2017 Red Davis. All rights reserved.
//

import UIKit


internal final class MultilineTitleView: UIView
{
    // Internal
    internal let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .center
        
        return label
    }()
    
    internal let detailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.light)
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .center
        
        return label
    }()
    
    // MARK: Initialization
    
    internal required init()
    {
        super.init(frame: CGRect.zero)
        
        // Container view
        let container = UIView()
        self.addSubview(container)
        
        container.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        // Title label
        container.addSubview(self.titleLabel)
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(container.snp.centerY)
            make.width.lessThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
        }
        
        // Detail label
        container.addSubview(self.detailLabel)
       
        self.detailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(container.snp.centerY)
            make.width.lessThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    
    internal required init?(coder aDecoder: NSCoder)
    {
        fatalError("Unused")
    }
}
