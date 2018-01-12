//
//  AddNewAccountView.swift
//  BalancemacOS
//
//  Created by Felipe Rolvar on 1/12/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Cocoa

class AddNewAccountView: View {
    
    private let nothingToSeeLabel = LabelField()
    private let addAccountButton = Button()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
        addSubViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hideView(_ hide: Bool) {
        nothingToSeeLabel.isHidden = hide
        addAccountButton.isHidden = hide
    }
    
}

private extension AddNewAccountView {
    
    func setupView() {
        nothingToSeeLabel.alignment = .center
        nothingToSeeLabel.font = CurrentTheme.transactions.noResultsFont
        nothingToSeeLabel.textColor = CurrentTheme.defaults.foregroundColor
        nothingToSeeLabel.usesSingleLineMode = false
        nothingToSeeLabel.stringValue = "Nothing to see here..."
        
        addAccountButton.bezelStyle = .rounded
        addAccountButton.font = CurrentTheme.addAccounts.buttonFont
        addAccountButton.title = "Add an account"
        addAccountButton.sizeToFit()
        addAccountButton.target = self
        addAccountButton.action = #selector(addNewAccount)
    }
    
    func addSubViews() {
         addSubview(nothingToSeeLabel)
         addSubview(addAccountButton)
    }
    
    func setupConstraints() {
        nothingToSeeLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        addAccountButton.snp.makeConstraints { make in
            make.top.equalTo(nothingToSeeLabel.snp.bottom).inset(-8)
            make.centerX.equalToSuperview()
        }
    }
    
    @objc func addNewAccount() {
        NotificationCenter.postOnMainThread(name: Notifications.ShowAddAccount)
    }
    
}
