//
//  InstitutionCollectionViewCell.swift
//  BalanceiOS
//
//  Created by Red Davis on 11/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit

final class InstitutionCollectionViewCell: UICollectionViewCell, Reusable {
    static let measurementCell = InstitutionCollectionViewCell()
    
    var viewModel: AccountsListViewModel? {
        didSet {
            reloadData()
        }
    }
    
    override var isSelected: Bool {
        set { }
        get { return false }
    }
    
    override var isHighlighted: Bool {
        set { }
        get { return false }
    }
    
    // Internal
    private(set) var expandedContentHeight: CGFloat = 0.0
    
    var closedContentHeight: CGFloat {
        return 99.0
    }
    
    // Private
    private let container = UIView()
    private let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.selectedBackgroundView = nil
        
        // Container
        self.container.layer.cornerRadius = CurrentTheme.accounts.card.cornerRadius
        self.container.layer.masksToBounds = true
       
        self.contentView.addSubview(self.container)
        
        self.container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Table view
        self.tableView.separatorStyle = .none
        self.tableView.isUserInteractionEnabled = false
        self.tableView.backgroundView = nil
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(reusableCell: AccountTableViewCell.self)
        self.tableView.register(reusableView: InstitutionTableHeaderView.self)
        self.container.addSubview(self.tableView)
        
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    
        self.contentView.dropShadow()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("unsupported")
    }
    
    // MARK: Data
    
    private func reloadData() {
        container.backgroundColor = viewModel?.institution.source.color
        tableView.reloadData()
        
        guard let viewModel = viewModel else {
            return
        }
        
        expandedContentHeight = CGFloat(viewModel.numberOfAccounts) * CurrentTheme.accounts.cell.height + CurrentTheme.accounts.headerCell.height
    }
}

// MARK: UITableViewDataSource

extension InstitutionCollectionViewCell: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfAccounts ?? 0
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(at: indexPath) as AccountTableViewCell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableView() as InstitutionTableHeaderView
        header.institution = self.viewModel?.institution
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CurrentTheme.accounts.headerCell.height
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
        return CurrentTheme.accounts.cell.height
    }
}

