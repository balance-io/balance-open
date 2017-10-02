//
//  TextFieldTableViewCell.swift
//  Red Davis
//
//  Created by Red Davis on 09/05/2017.
//  Copyright © 2017 Red Davis. All rights reserved.
//

import UIKit


internal final class TextFieldTableViewCell: TableViewCell
{
    // Internal
    internal var textField: UITextField? {
        willSet
        {
            self.textField?.removeFromSuperview()
        }
        
        didSet
        {
            guard let unwrappedTextField = self.textField else
            {
                return
            }
            
            self.contentView.addSubview(unwrappedTextField)
            
            unwrappedTextField.snp.makeConstraints { (make) in
                make.right.equalToSuperview().inset(10.0)
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
                
                if let textLabel = self.textLabel
                {
                    make.left.equalTo(textLabel.snp.right).offset(15.0)
                }
                else
                {
                    make.left.equalToSuperview().inset(15.0)
                }
            }
        }
    }
    
    // MARK: Initialization
    
    internal override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        // Text label
        self.textLabel?.snp.makeConstraints({ (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().inset(15.0)
        })
    }
    
    internal required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}
