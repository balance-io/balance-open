//
//  AddCredentialBasedAccountViewController.swift
//  BalanceiOS
//
//  Created by Red Davis on 02/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import SVProgressHUD
import UIKit

internal class AddCredentialBasedAccountViewController: UIViewController
{
    // Private
    private let source: Source
    private let viewModel: NewAccountViewModel
    private let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    weak var delegate: AddAccountDelegate?
    
    private var tableSections = [TableSection]()
    
    // MARK: Initialization
    
    internal required init(source: Source)
    {
        self.source = source
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
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        // Table view
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(reusableCell: TextFieldTableViewCell.self)
        self.tableView.register(reusableCell: TableViewCell.self)
        self.tableView.tableFooterView = UIView()
        self.view.addSubview(self.tableView)
        
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        // Reload data
        self.reloadData()
    }
    
    // MARK: Data
    
    private func reloadData() {
        // Sections
        var sections = [TableSection]()
        
        // Text field rows
        var textFieldRows = [TableRow]()
        for index in 0..<self.viewModel.numberOfTextFields {
            let row = TableRow(cellPreparationHandler: { [unowned self] (tableView, indexPath) -> UITableViewCell in
                let cell: TextFieldTableViewCell = tableView.dequeueReusableCell(at: indexPath)
                cell.textField = self.viewModel.textField(at: index)
                cell.titleLabel.text = self.viewModel.title(at: index)
                
                cell.textField?.text = self.viewModel.testValue(at: index)
                
                return cell
            })
            
            textFieldRows.append(row)
        }
        
        let textFieldSection = TableSection(title: nil, rows: textFieldRows)
        sections.append(textFieldSection)
        
        // QR reader
        if self.viewModel.loginWithQRCodeSupported {
            var row = TableRow(cellPreparationHandler: { (tableView, indexPath) -> UITableViewCell in
                let cell: TableViewCell = tableView.dequeueReusableCell(at: indexPath)
                cell.textLabel?.text = "Login with QR Code"
                cell.imageView?.image = UIImage(named: "QRCodeScan")
                
                return cell
            })
            
            row.actionHandler = { [unowned self] (indexPath) in
                let qrCodeScannerViewController = QRCodeScannerViewController()
                qrCodeScannerViewController.delegate = self
                
                self.present(qrCodeScannerViewController, animated: true, completion: nil)
            }
            
            let qrCodeSection = TableSection(title: nil, rows: [row])
            sections.append(qrCodeSection)
        }
        
        self.tableSections = sections
        self.tableView.reloadData()
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
        
        SVProgressHUD.show()
        
        // Auth
        self.viewModel.authenticate { (success, error) in
            async {
                if success
                {
                    SVProgressHUD.showSuccess(withStatus: "\(self.source.description) account added!")
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                
                SVProgressHUD.dismiss()
                
                // Show error message
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
        return self.tableSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let section = self.tableSections[section]
        return section.rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let section = self.tableSections[indexPath.section]
        let row = section.rows[indexPath.row]
        
        return row.cellPreparationHandler(tableView, indexPath)
    }
}

// MARK: UITableViewDelegate

extension AddCredentialBasedAccountViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = self.tableSections[indexPath.section]
        let row = section.rows[indexPath.row]
        
        row.actionHandler?(indexPath)
    }
}

// MARK: QRCodeScannerViewControllerDelegate

extension AddCredentialBasedAccountViewController: QRCodeScannerViewControllerDelegate {
    func didFind(value: String, in controller: QRCodeScannerViewController)
    {
        do {
            let parser = QRLoginCredentialsParser()
            let fields = try parser.parse(value: value, for: self.source)

            DispatchQueue.main.async {
                SVProgressHUD.show()

                controller.dismiss(animated: true, completion: {
                    self.viewModel.authenticate(with: fields, completionHandler: { (success, error) in
                        async {
                            if success && error == nil
                            {
                                SVProgressHUD.showSuccess(withStatus: "\(self.source.description) account added!")
                                self.navigationController?.popViewController(animated: true)
                                self.delegate?.didAddAccount()
                                
                                return
                            }

                            SVProgressHUD.dismiss()

                            // Show error message
                            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                            let errorMessage = (error as? LocalizedError)?.recoverySuggestion ?? error?.localizedDescription
                            let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    })
                })
            }
        }
        catch { }
    }
}
