//
//  AddCredentialBasedAccountViewController.swift
//  BalanceiOS
//
//  Created by Red Davis on 02/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


internal class AddCredentialBasedAccountViewController: UIViewController
{
    // Fileprivate
    fileprivate let viewModel: NewAccountViewModel
    
    // Private
    private let tableView = UITableView(frame: CGRect.zero, style: .plain)
    
    // MARK: Initialization
    
    internal required init(source: Source)
    {
        self.viewModel = NewAccountViewModel(source: source)
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = source.description
    }
    
    internal required init?(coder aDecoder: NSCoder)
    {
        fatalError()
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        // Navigation bar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonTapped(_:)))
        
        if #available(iOS 11.0, *)
        {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        // Table view
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(reusableCell: TextFieldTableViewCell.self)
        self.tableView.tableFooterView = UIView()
        self.view.addSubview(self.tableView)
        
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: Actions
    
    @objc private func doneButtonTapped(_ sender: Any)
    {
        // Validate
        guard self.viewModel.isValid else
        {
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)

            let alertController = UIAlertController(title: "Error", message: "All fields are required", preferredStyle: .alert)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)

            return
        }
        
        self.viewModel.authenticate { (success, error) in
            DispatchQueue.main.async {
                if success
                {
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}

// MARK: UITableViewDataSource

extension AddCredentialBasedAccountViewController: UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.viewModel.numberOfTextFields
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell: TextFieldTableViewCell = tableView.dequeueReusableCell(at: indexPath)
        cell.textField = self.viewModel.textField(at: indexPath.row)
        cell.textLabel?.text = self.viewModel.title(at: indexPath.row)
        
        return cell
    }
}

// MARK: UITableViewDelegate

extension AddCredentialBasedAccountViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 44.0
    }
}
