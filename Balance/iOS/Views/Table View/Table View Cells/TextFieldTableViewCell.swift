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
    internal let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
        
        return label
    }()
    
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
            
            unwrappedTextField.textAlignment = .right
            self.container.addSubview(unwrappedTextField)
            
            unwrappedTextField.snp.makeConstraints { (make) in
                make.right.equalTo(self.contentView.layoutMarginsGuide.snp.right)
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
                make.left.equalTo(self.titleLabel.snp.right).offset(10.0)
            }
        }
    }
    
    // Private
    private let container = UIView()
    
    // MARK: Initialization
    
    internal override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        // Container
        self.contentView.addSubview(self.container)
        
        self.container.snp.makeConstraints { (make) in
            make.height.equalTo(44.0).priority(999)
            make.edges.equalToSuperview()
        }
        
        // Title label
        self.titleLabel.setContentCompressionResistancePriority(UILayoutPriority(1000.0), for: .horizontal)
        self.titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        self.container.addSubview(self.titleLabel)
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().inset(15.0)
        }
        
        // Tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureEngaged(_:)))
        self.contentView.addGestureRecognizer(tapGesture)
    }
    
    internal required init?(coder aDecoder: NSCoder)
    {
        fatalError()
    }
    
    // MARK: Gestures
    
    @objc private func tapGestureEngaged(_ gesture: Any)
    {
        self.textField?.becomeFirstResponder()
    }
}
