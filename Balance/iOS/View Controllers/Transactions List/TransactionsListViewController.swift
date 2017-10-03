//
//  TransactionsListViewController.swift
//  BalanceiOS
//
//  Created by Red Davis on 03/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


internal final class TransactionsListViewController: UIViewController {
    // Fileprivate
    private let viewModel = TransactionsListViewModel()
    
    // Private
    private let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    
    // MARK: Initialization
    
    internal required init() {
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Transactions"
        self.tabBarItem.image = UIImage(named: "Cash")
        
        self.viewModel.delegate = self
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        abort()
    }

    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation bar
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        // Table view
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(reusableCell: TransactionTableViewCell.self)
        self.view.addSubview(self.tableView)
        
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: UITableViewDataSource

extension TransactionsListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRows(at: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(at: indexPath) as TransactionTableViewCell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.viewModel.title(for: section)
    }
}

// MARK: UITableViewDelegate

extension TransactionsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? TransactionTableViewCell else
        {
            return
        }
        
        cell.transaction = self.viewModel.transaction(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TransactionTableViewCell.height
    }
}

// MARK: TransactionsListViewModelDelegate

extension TransactionsListViewController: TransactionsListViewModelDelegate {
    func didReloadData(in viewModel: TransactionsListViewModel) {
        self.tableView.reloadData()
    }
}
