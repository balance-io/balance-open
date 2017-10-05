//
//  AccountsListViewController.swift
//  BalanceiOS
//
//  Created by Red Davis on 05/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


internal final class AccountsListViewController: UIViewController
{
    // Fileprivate
    private let viewModel = AccountsTabViewModel()
    
    // Private
    private let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    private let titleView = MultilineTitleView()
    
    // MARK: Initialization
    
    internal required init()
    {
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Accounts"
        self.tabBarItem.image = UIImage(named: "Library")
        
        // Notifications
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(self.syncCompletedNotification(_:)), name: Notifications.SyncCompleted)
    }
    
    internal required init?(coder aDecoder: NSCoder)
    {
        abort()
    }
    
    deinit
    {
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.SyncCompleted)
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Navigation bar
        self.setupTitleView()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addAccountButtonTapped(_:)))
        
        // Table view
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(reusableCell: AccountTableViewCell.self)
        self.tableView.register(reusableView: InstitutionTableHeaderView.self)
        self.view.addSubview(self.tableView)
        
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.reloadData()
    }
    
    // MARK: Data
    
    private func reloadData()
    {
        self.viewModel.reloadData()
        self.tableView.reloadData()
        
        // Total balance
        self.titleView.detailLabel.attributedText = centsToStringFormatted(self.viewModel.totalBalance(), showNegative: true)
    }
    
    // MARK: UI
    
    private func setupTitleView()
    {
        if let navigationBar = self.navigationController?.navigationBar
        {
            let navigationBarBounds = navigationBar.bounds
            
            let containerView = UIView()
            containerView.frame = navigationBarBounds
            containerView.autoresizingMask = UIViewAutoresizing.flexibleWidth
            self.navigationItem.titleView = containerView
            
            // Add the title view
            self.titleView.titleLabel.text = "Total Balance"
            navigationBar.addSubview(self.titleView)
            
            self.titleView.snp.makeConstraints({ (make) in
                make.width.lessThanOrEqualToSuperview().multipliedBy(0.6)
                make.height.equalToSuperview()
                make.center.equalTo(navigationBar)
            })
        }
    }
    
    // MARK: Actions
    
    @objc private func addAccountButtonTapped(_ sender: Any)
    {
        let addAccountViewController = AddAccountViewController()
        let navigationController = UINavigationController(rootViewController: addAccountViewController)
        
        self.present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: Notifications
    
    @objc private func syncCompletedNotification(_ notification: Notification)
    {
        self.reloadData()
    }
}

// MARK: UITableViewDataSource

extension AccountsListViewController: UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return self.viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.viewModel.numberOfRows(inSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        return tableView.dequeueReusableCell(at: indexPath) as AccountTableViewCell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableView() as InstitutionTableHeaderView
        header.institution = self.viewModel.institution(forSection: section)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return InstitutionTableHeaderView.height
    }
}

// MARK: UITableViewDelegate

extension AccountsListViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let account = self.viewModel.account(forRow: indexPath.row, inSection: indexPath.section),
              let cell = cell as? AccountTableViewCell else {
            return
        }
        
        cell.account = account
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AccountTableViewCell.height
    }
}
