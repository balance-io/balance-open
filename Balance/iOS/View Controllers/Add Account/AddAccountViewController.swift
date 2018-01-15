//
//  AddAccountViewController.swift
//  BalanceiOS
//
//  Created by Red Davis on 05/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


internal final class AddAccountViewController: UIViewController
{
    // Fileprivate
    fileprivate let viewModel = NewAccountListViewModel()
    
    // Private
    private let tableView = UITableView(frame: CGRect.zero, style: .plain)
    
    // MARK: View lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "Add an Account"
        self.view.backgroundColor = UIColor.white
        
        // Navigation bar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonTapped(_:)))
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        // Table view
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(reusableCell: TableViewCell.self)
        self.tableView.tableFooterView = UIView()
        self.view.addSubview(self.tableView)
        
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Actions
    
    @objc private func doneButtonTapped(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: UITableViewDataSource

extension AddAccountViewController: UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.viewModel.numberOfSources
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let source = self.viewModel.source(at: indexPath.row)
        
        let cell: TableViewCell = tableView.dequeueReusableCell(at: indexPath)
        cell.textLabel?.text = source.description
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
}

//MARK: AddAccountDelegate
extension AddAccountViewController: AddAccountDelegate {
    
    func didAddAccount(succeeded: Bool, institutionId: Int?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.dismiss(animated: true, completion: nil)
        }
    }

}

// MARK: UITableViewDelegate

extension AddAccountViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let source = self.viewModel.source(at: indexPath.row)
        switch source
        {
        case .coinbase:
            self.dismiss(animated: true, completion: nil)
            CoinbaseApi.authenticate()
        default:
            let addCredentialVM = NewAccountViewModel(source: source, existingInstitution: nil)
            let newCredentialBasedAccountViewController = AddCredentialBasedAccountViewController(viewModel: addCredentialVM)
            newCredentialBasedAccountViewController.delegate = self
            self.navigationController?.pushViewController(newCredentialBasedAccountViewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 44.0
    }
}
