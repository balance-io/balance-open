//
//  SettingsViewController.swift
//  BalanceiOS
//
//  Created by Red Davis on 06/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


internal final class SettingsViewController: UIViewController
{
    // Fileprivate
    fileprivate var tableData = [TableSection]()
    
    // Private
    private let viewModel = AccountsTabViewModel()
    private let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    
    // MARK: Initialization
    
    internal required init()
    {
        super.init(nibName: nil, bundle: nil)
        self.title = "Settings"
        self.tabBarItem.image = UIImage(named: "Gear")
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
        
        if #available(iOS 11.0, *)
        {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        // Table view
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(reusableCell: TableViewCell.self)
        self.tableView.register(reusableCell: SegmentedControlTableViewCell.self)
        self.view.addSubview(self.tableView)
        
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.buildTableData()
        self.tableView.reloadData()
    }
    
    // MARK: Data
    
    private func buildTableData()
    {
        self.viewModel.reloadData()
        
        // Table sections
        var tableSections = [TableSection]()
        
        // Theme
        let themeRow = TableRow { (tableView, indexPath) -> UITableViewCell in
            // Segmented control
            let themeSegmentedControl = UISegmentedControl()
            themeSegmentedControl.addTarget(self, action: #selector(self.themeSegmentedControlChanged(_:)), for: .valueChanged)
            
            for theme in UserPreferences.Theme.available
            {
                let index = themeSegmentedControl.numberOfSegments
                themeSegmentedControl.insertSegment(withTitle: theme.title(), at: index, animated: false)
                
                if theme == ApplicationConfiguration.userPreferences.theme
                {
                    themeSegmentedControl.selectedSegmentIndex = index
                }
            }
            
            // Cell
            let cell: SegmentedControlTableViewCell = tableView.dequeueReusableCell(at: indexPath)
            cell.textLabel?.text = "Theme"
            cell.segmentedControl = themeSegmentedControl
            
            return cell
        }
        
        let themeSection = TableSection(title: "Theme", rows: [themeRow])
        tableSections.append(themeSection)
        
        // Insitutions
        var institutionRows = [TableRow]()
        let numberOfInstitutions = self.viewModel.numberOfSections()
        for index in 0..<numberOfInstitutions
        {
            guard let institution = self.viewModel.institution(forSection: index) else
            {
                continue
            }
            
            var row = TableRow(cellPreparationHandler: { (tableView, indexPath) -> UITableViewCell in
                let cell: TableViewCell = tableView.dequeueReusableCell(at: indexPath)
                cell.textLabel?.text = institution.displayName
                cell.accessoryType = .disclosureIndicator
                
                return cell
            })
            
            row.actionHandler = { [unowned self] (indexPath) in
                let institutionSettingsViewController = InstitutionSettingsViewController(institution: institution)
                self.navigationController?.pushViewController(institutionSettingsViewController, animated: true)
            }
            
            row.deletionHandler = { [unowned self] (indexPath) in
                if institution.delete()
                {
                    self.buildTableData()
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
            
            institutionRows.append(row)
        }
        
        let accountsSection = TableSection(title: "Accounts", rows: institutionRows)
        tableSections.append(accountsSection)
        
        self.tableData = tableSections
    }
    
    // MARK: Actions

    @objc private func themeSegmentedControlChanged(_ sender: Any)
    {
        guard let control = sender as? UISegmentedControl,
              control.selectedSegmentIndex < UserPreferences.Theme.available.count else
        {
            return
        }
        
        ApplicationConfiguration.userPreferences.theme = UserPreferences.Theme.available[control.selectedSegmentIndex]
    }
}

// MARK: UITableViewDataSource

extension SettingsViewController: UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return self.tableData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let sectionData = self.tableData[section]
        return sectionData.rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let sectionData = self.tableData[indexPath.section]
        let rowData = sectionData.rows[indexPath.row]
        
        return rowData.cellPreparationHandler(tableView, indexPath)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        let sectionData = self.tableData[section]
        return sectionData.title
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        let sectionData = self.tableData[indexPath.section]
        let rowData = sectionData.rows[indexPath.row]
        
        return rowData.isDeletable
    }
}

// MARK: UITableViewDelegate

extension SettingsViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let sectionData = self.tableData[indexPath.section]
        let rowData = sectionData.rows[indexPath.row]
        rowData.actionHandler?(indexPath)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        guard editingStyle == .delete else { return }
        
        let sectionData = self.tableData[indexPath.section]
        let rowData = sectionData.rows[indexPath.row]
        rowData.deletionHandler?(indexPath)
    }
}
