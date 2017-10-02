//
//  SegmentedControlTableViewCell.swift
//  BalanceiOS
//
//  Created by Red Davis on 07/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


internal final class SegmentedControlTableViewCell: TableViewCell
{
    // Internal
    internal var segmentedControl: UISegmentedControl? {
        willSet
        {
            self.segmentedControl?.removeFromSuperview()
        }
        
        didSet
        {
            guard let unwrappedSegmentedControl = self.segmentedControl else
            {
                return
            }
            
            self.contentView.addSubview(unwrappedSegmentedControl)
            
            unwrappedSegmentedControl.snp.makeConstraints { (make) in
                make.right.equalToSuperview().inset(10.0)
                make.centerY.equalToSuperview()
            }
        }
    }
    
    // MARK: Initialization
    
    internal override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    internal required init?(coder aDecoder: NSCoder)
    {
        fatalError()
    }
}
