//
//  AddPoloniexAccountViewController.swift
//  BalanceiOS
//
//  Created by Red Davis on 06/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


internal final class AddPoloniexAccountViewController: UIViewController
{
    // Fileprivate
    fileprivate var tableData = [TableRow]()
    
    // Private
    private let apiClient = PoloniexApi()
    private let tableView = UITableView(frame: CGRect.zero, style: .plain)
    
    private let apiKeyTextField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.textAlignment = .right
        textField.placeholder = "00m70v500d..."
        
        return textField
    }()
    
    private let secretKeyKeyTextField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.textAlignment = .right
        textField.placeholder = "4WEijVgdII..."
        
        return textField
    }()
    
    // MARK: View lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "Poloniex"
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
        
        self.buildTableData()
    }
    
    // MARK: Data
    
    private func buildTableData()
    {
        var tableRows = [TableRow]()
        
        // API Key
        let apiKeyRow = TableRow { [unowned self] (tableView, indexPath) -> UITableViewCell in
            let cell: TextFieldTableViewCell = tableView.dequeueReusableCell(at: indexPath)
            cell.textLabel?.text = "API Key"
            cell.textField = self.apiKeyTextField
            
            return cell
        }
        tableRows.append(apiKeyRow)
        
        // Secret key phrase
        let secretKeyRow = TableRow { [unowned self] (tableView, indexPath) -> UITableViewCell in
            let cell: TextFieldTableViewCell = tableView.dequeueReusableCell(at: indexPath)
            cell.textLabel?.text = "Secret Key"
            cell.textField = self.secretKeyKeyTextField
            
            return cell
        }
        tableRows.append(secretKeyRow)
        
        // Reload
        self.tableData = tableRows
        self.tableView.reloadData()
    }
    
    // MARK: Actions
    
    @objc private func doneButtonTapped(_ sender: Any)
    {
        // Validate
        guard let apiKey = self.apiKeyTextField.text,
            apiKey.length > 0,
            let secret = self.secretKeyKeyTextField.text,
            secret.length > 0 else
        {
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            
            let alertController = UIAlertController(title: "Error", message: "All fields are required", preferredStyle: .alert)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        let fields = [
            Field(name: "Key", label: "Key", type: "key", value: apiKey),
            Field(name: "Secret", label: "Secret", type: "secret", value: secret)
        ]
        
        self.apiClient.authenticationChallenge(loginStrings: fields, closeBlock: { (success, error, institution) in
            DispatchQueue.main.async {
                if success
                {
                    syncManager.sync()
                    self.dismiss(animated: true, completion: nil)
                }
                else
                {
                    // TODO: show error
                }
            }
        })
    }
}

// MARK: UITableViewDataSource

extension AddPoloniexAccountViewController: UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let rowData = self.tableData[indexPath.row]
        return rowData.cellPreparationHandler(tableView, indexPath)
    }
}

// MARK: UITableViewDelegate

extension AddPoloniexAccountViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 44.0
    }
}

