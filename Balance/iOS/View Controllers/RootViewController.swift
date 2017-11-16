//
//  RootViewController.swift
//  BalanceiOS
//
//  Created by Red Davis on 05/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import SnapKit
import SVProgressHUD
import UIKit


internal final class RootViewController: UIViewController
{
    // Internal
    
    // Private
    private let rootTabBarController = UITabBarController()
    private let priceTickerViewController = PriceTickerViewController()
    private let accountsListViewController = AccountsListViewController()
    private let transactionsListViewController = TransactionsListViewController()
    private let settingsViewController = SettingsViewController()
    
    // MARK: Initialization
    
    internal required init()
    {
        super.init(nibName: nil, bundle: nil)
        
        // Tab bar controller
        let priceTickerNavigationController = UINavigationController(rootViewController: self.priceTickerViewController)
        let accountsListNavigationController = UINavigationController(rootViewController: self.accountsListViewController)
        let transactionsListNavigationController = UINavigationController(rootViewController: self.transactionsListViewController)
        let settingsNavigationController = UINavigationController(rootViewController: self.settingsViewController)
        
        var priceTickerDisabled = true
        #if DEBUG
            priceTickerDisabled =  false
        #endif
        
        if priceTickerDisabled {
            self.rootTabBarController.viewControllers = [
                accountsListNavigationController,
                transactionsListNavigationController,
                settingsNavigationController
            ]
        } else {
            self.rootTabBarController.viewControllers = [
                priceTickerNavigationController,
                accountsListNavigationController,
                transactionsListNavigationController,
                settingsNavigationController
            ]
        }
        
        // Add as child view controller
        self.addChildViewController(self.rootTabBarController)
        
        // Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.accountAddedNotification(_:)), name: Notifications.AccountAdded, object: nil)
    }

    internal required init?(coder aDecoder: NSCoder)
    {
        abort()
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self)
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
        
        // Sync
        syncManager.sync()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Presentation
    
    private func presentSplashScreen() {
        let splashScreenViewController = SplashScreenViewController()
        let navigationController = UINavigationController(rootViewController: splashScreenViewController)
        
        self.present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: UI Defaults
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if self.rootTabBarController.selectedIndex == self.rootTabBarController.viewControllers?.index(of: self.accountsListViewController) {
            return .lightContent
        }
        
        return .default
    }
    
    private func setUIDefaults()
    {
        // UITabBar
        UITabBar.appearance().barTintColor = UIColor.black
        UITabBar.appearance().tintColor = UIColor.white
        
        // Tab bar item
        UITabBarItem.appearance().setTitleTextAttributes([
            .font : UIFont.Balance.monoFont(ofSize: 10.0, weight: .regular),
            .foregroundColor : UIColor(white: 1.0, alpha: 0.5)
        ], for: .normal)
        
        UITabBarItem.appearance().setTitleTextAttributes([
            .font : UIFont.Balance.monoFont(ofSize: 10.0, weight: .regular),
            .foregroundColor : UIColor.white
        ], for: .selected)
        
        // SVProgressHUD
        SVProgressHUD.setHapticsEnabled(true)
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setMinimumDismissTimeInterval(1.0)
    }
    
    // MARK: Notifications
    
    @objc private func accountAddedNotification(_ notification: Notification) {
        syncManager.sync()
    }
}
