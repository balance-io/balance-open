//
//  Value1TableViewCell.swift
//  ToolKit
//
//  Created by Red Davis on 25/05/2017.
//  Copyright © 2017 Red Davis. All rights reserved.
//

import UIKit


internal class Value1TableViewCell: UITableViewCell, Reusable
{
    // MARK: Initialization
    
    internal override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    
    internal required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}
