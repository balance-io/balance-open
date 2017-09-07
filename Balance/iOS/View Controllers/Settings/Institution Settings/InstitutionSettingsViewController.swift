//
//  InstitutionSettingsViewController.swift
//  BalanceiOS
//
//  Created by Red Davis on 07/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


internal final class InstitutionSettingsViewController: UIViewController
{
    // Private
    private let institution: Institution
    private let viewModel: InstitutionSettingsViewModel
    
    private let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    
    // MARK: Initialization
    
    internal required init(institution: Institution)
    {
        self.institution = institution
        self.viewModel = InstitutionSettingsViewModel(institution: institution)
        super.init(nibName: nil, bundle: nil)
    }
    
    internal required init?(coder aDecoder: NSCoder)
    {
        abort()
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = self.institution.displayName
        self.view.backgroundColor = UIColor.white
        
        // Navigation bar
        if #available(iOS 11.0, *)
        {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        // Table view
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(reusableCell: TableViewCell.self)
        self.view.addSubview(self.tableView)
        
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: UITableViewDataSource

extension InstitutionSettingsViewController: UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.viewModel.numberOfAccounts
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let account = self.viewModel.account(at: indexPath.row)
        
        let cell: TableViewCell = tableView.dequeueReusableCell(at: indexPath)
        cell.textLabel?.text = account.displayName
        cell.accessoryType = account.isHidden ? .none : .checkmark
        
        return cell
    }
}

// MARK: UITableViewDelegate

extension InstitutionSettingsViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let account = self.viewModel.account(at: indexPath.row)
        self.viewModel.set(account: account, hidden: !account.isHidden)
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
