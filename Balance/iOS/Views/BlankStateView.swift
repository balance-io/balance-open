//
//  BlankStateView.swift
//  BalanceiOS
//
//  Created by Felipe Rolvar on 1/17/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import UIKit

enum ViewStyle {
    case light
    case dark
}

final class BlankStateView: UIView {

    private let noAccountsLabel = UILabel()
    private let addAccountButton = UIButton(type: .system)
    private var viewStyle: ViewStyle = .dark
    private var itemsColor: UIColor {
        return viewStyle == .dark ? .white : .black
    }
    
    init(with style: ViewStyle, showAddButton: Bool = true) {
        super.init(frame: .zero)
        self.viewStyle = style
        setupView(showAddButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addTarget(_ target: Any?, action: Selector) {
        addAccountButton.addTarget(target, action: action, for: .touchUpInside)
    }
}

private extension BlankStateView {
    
    func setupView(_ showAddButton: Bool) {
        noAccountsLabel.text = "Nothing to see here..."
        noAccountsLabel.textColor = itemsColor
        noAccountsLabel.font = UIFont.systemFont(ofSize: 20.0, weight: .regular)
        
        addSubview(noAccountsLabel)
        
        noAccountsLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.snp.centerY).offset(-10.0)
            make.centerX.equalToSuperview()
        }
        
        if showAddButton {
            addAccountButton.layer.borderColor = itemsColor.cgColor
            addAccountButton.layer.cornerRadius = 4.0
            addAccountButton.layer.borderWidth = 2.0
            addAccountButton.setTitle("Add an account", for: .normal)
            addAccountButton.setTitleColor(itemsColor, for: .normal)
            addAccountButton.contentEdgeInsets = UIEdgeInsets(top: 7.0, left: 10.0, bottom: 7.0, right: 10.0)
            
            addSubview(addAccountButton)
            
            addAccountButton.snp.makeConstraints { (make) in
                make.top.equalTo(self.snp.centerY).offset(10.0)
                make.centerX.equalToSuperview()
            }
        }

    }
    
}
