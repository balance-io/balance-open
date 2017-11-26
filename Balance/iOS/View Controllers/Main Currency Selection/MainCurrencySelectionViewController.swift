//
//  MainCurrencySelectionViewController.swift
//  BalanceiOS
//
//  Created by Red Davis on 05/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


internal final class MainCurrencySelectionViewController: UIViewController {
    // Fileprivate
    fileprivate let viewModel = CurrencySelectionViewModel()
    
    // Private
    private let tableView = UITableView(frame: CGRect.zero, style: .plain)
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Main Currency"
        
        // Navigation bar
        if #available(iOS 11.0, *) {
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: UITableViewDataSource

extension MainCurrencySelectionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfCurrencies(at: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(at: indexPath) as TableViewCell
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.viewModel.sectionIndexTitles[section]
    }
}

// MARK: UITableViewDelegate

extension MainCurrencySelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? TableViewCell else {
            return
        }
        
        cell.textLabel?.text = self.viewModel.currencyDisplay(at: indexPath)
        cell.accessoryType = self.viewModel.isCurrencySelected(at: indexPath) ? .checkmark : .none
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.selectCurrency(at: indexPath)
        self.navigationController?.popViewController(animated: true)
    }
}
