//
//  InstitutionCollectionViewCell.swift
//  BalanceiOS
//
//  Created by Red Davis on 11/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


internal final class InstitutionCollectionViewCell: UICollectionViewCell, Reusable {
    // Internal
    internal var viewModel: InstitutionAccountsListViewModel? {
        didSet {
            self.reloadData()
        }
    }
    
    // Private
    private let container = UIView()
    private let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    
    // MARK: Initialization
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.selectedBackgroundView = nil
        
        // Container
        self.container.layer.cornerRadius = 20.0
        self.container.layer.borderColor = UIColor.black.cgColor
        self.container.layer.borderWidth = 0.5
        self.contentView.addSubview(self.container)
        
        self.container.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        // Table view
        self.tableView.isUserInteractionEnabled = false
        self.tableView.separatorStyle = .none
        self.tableView.backgroundView = nil
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(reusableCell: AccountTableViewCell.self)
        self.tableView.register(reusableView: InstitutionTableHeaderView.self)
        self.container.addSubview(self.tableView)
        
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: Data
    
    private func reloadData() {
        self.container.backgroundColor = self.viewModel?.institution.displayColor
        self.tableView.reloadData()
    }
    
    // MARK: Autolayout
    
    override var intrinsicContentSize: CGSize {
        return self.tableView.contentSize
    }
}

// MARK: UITableViewDataSource

extension InstitutionCollectionViewCell: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.viewModel?.numberOfAccounts ?? 0
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        return tableView.dequeueReusableCell(at: indexPath) as AccountTableViewCell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableView() as InstitutionTableHeaderView
        header.institution = self.viewModel?.institution
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return InstitutionTableHeaderView.height
    }
}

// MARK: UITableViewDelegate

extension InstitutionCollectionViewCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let account = self.viewModel?.account(at: indexPath.row),
              let cell = cell as? AccountTableViewCell else {
            return
        }
        
        cell.account = account
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AccountTableViewCell.height
    }
}
