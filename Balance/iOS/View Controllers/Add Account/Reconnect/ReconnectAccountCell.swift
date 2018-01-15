//
//  ReconnectAccountCell.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 1/9/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import UIKit

protocol ReconnectDelegate: class {
    func didTapReconnect(cell: ReconnectAccountCell)
}

class ReconnectAccountCell: UITableViewCell {
    
    weak var nameLabel: UILabel?
    weak var statusContainerView: UIView?
    weak var reconnectButton: UIButton?
    weak var loaderView: UIActivityIndicatorView?
    weak var delegate: ReconnectDelegate?
    
    static var cellIdentifier: String {
        return "ReconnectAccountCell"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with invalidAccount: ReconnectAccount) {
        nameLabel?.text = invalidAccount.name
        updateStatus(invalidAccount.status)
    }
    
}

private extension ReconnectAccountCell {
    
    func updateStatus(_ newStatus: ReconnectStatus) {
        switch newStatus {
        case .reconnect:
            showReconnectStatus(true)
            showValidatingStatus(false)
        case .validating:
            showValidatingStatus(true)
            showReconnectStatus(false)
        }
    }
    
    func showReconnectStatus(_ show: Bool) {
        guard let reconnectButton = self.reconnectButton else {
            return
        }
        
        reconnectButton.isEnabled = show
        reconnectButton.isHidden = !show
        loaderView?.isHidden = show
    }
    
    func showValidatingStatus(_ show: Bool) {
        guard let loaderView = loaderView else {
            return
        }
        
        loaderView.isHidden = !show
        reconnectButton?.isHidden = show
        
        if show {
            loaderView.startAnimating()
        } else {
            loaderView.stopAnimating()
        }
    }
    
}

//mark: Create UI
private extension ReconnectAccountCell {
    
    func createUI() {
        createNameLabel()
        createStatusContainerView()
    }
    
    func createNameLabel() {
        let nameLabel = UILabel.init()
        nameLabel.text = "Example"
        nameLabel.font = UIFont.Balance.monoFont(ofSize: 14, weight: .regular)
        
        contentView.addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalTo(contentView.snp.centerX)
            make.centerY.equalToSuperview()
        }
        
        self.nameLabel = nameLabel
    }
    
    func createStatusContainerView() {
        let statusContainerView = UIView()
        
        contentView.addSubview(statusContainerView)
        
        statusContainerView.snp.makeConstraints { (make) in
            make.leading.equalTo(contentView.snp.centerX).offset(UIView.getHorizontalSize(with: 8))
            make.trailing.equalTo(contentView.snp.trailing).offset(UIView.getHorizontalSize(with: -8))
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        self.loaderView = createLoaderView(on: statusContainerView)
        self.reconnectButton = createReconnectButton(on: statusContainerView)
        self.statusContainerView = statusContainerView
    }
    
    func createReconnectButton(on containerView: UIView) -> UIButton {
        let reconnectButton = UIButton()
        reconnectButton.addTarget(self, action: #selector(ReconnectAccountCell.reconnectAction(with:)), for: .touchUpInside)
        reconnectButton.setTitle("Reconnect", for: .normal)
        reconnectButton.setTitleColor(.black, for: .normal)
        reconnectButton.titleLabel?.font = UIFont.Balance.font(ofSize: 14, weight: .medium)
        reconnectButton.backgroundColor = UIColor.lightGray
        reconnectButton.layer.cornerRadius = 6
        
        containerView.addSubview(reconnectButton)
        
        reconnectButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalToSuperview().multipliedBy(0.6)
        }
        
        return reconnectButton
    }
    
    func createLoaderView(on containerView: UIView) -> UIActivityIndicatorView {
        let loaderView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        loaderView.hidesWhenStopped = true
        loaderView.stopAnimating()
        loaderView.isHidden = true
        
        containerView.addSubview(loaderView)
        
        loaderView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        return loaderView
    }
   
    @objc func reconnectAction(with button: UIButton) {
        delegate?.didTapReconnect(cell: self)
    }
    
}
