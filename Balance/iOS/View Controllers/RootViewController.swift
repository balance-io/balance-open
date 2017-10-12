//
//  RootViewController.swift
//  BalanceiOS
//
//  Created by Red Davis on 05/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import SnapKit
import UIKit


internal final class RootViewController: UIViewController
{
    // Internal
    
    // Private
    private let rootTabBarController = UITabBarController()
    private let accountsListViewController = AccountsListViewController()
    private let transactionsListViewController = TransactionsListViewController()
    private let settingsViewController = SettingsViewController()
    
    // MARK: Initialization
    
    internal required init()
    {
        super.init(nibName: nil, bundle: nil)
        
        // Tab bar controller
        let accountsListNavigationController = UINavigationController(rootViewController: self.accountsListViewController)
        let transactionsListNavigationController = UINavigationController(rootViewController: self.transactionsListViewController)
        let settingsNavigationController = UINavigationController(rootViewController: self.settingsViewController)
        
        self.rootTabBarController.viewControllers = [
            accountsListNavigationController,
            transactionsListNavigationController,
            settingsNavigationController
        ]
        
        // Add as child view controller
        self.addChildViewController(self.rootTabBarController)
    }

    internal required init?(coder aDecoder: NSCoder)
    {
        abort()
    }
    
    deinit
    {
        
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.setUIDefaults()
        
        // Root tab bar controller
        self.view.addSubview(self.rootTabBarController.view)

        self.rootTabBarController.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UI Defaults
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if self.rootTabBarController.selectedIndex == 0 {
            return .lightContent
        }
        
        return .default
    }
    private func setUIDefaults()
    {
        UITableView.appearance().backgroundColor = UIColor(red: 237.0/255.0, green: 238.0/255.0, blue: 240.0/255.0, alpha: 1.0)
    }
}
