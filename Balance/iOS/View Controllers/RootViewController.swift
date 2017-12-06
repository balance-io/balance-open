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

private enum TabIndex: Int {
    case accounts = 0
    case transactions = 1
    case priceTicker = 2
    case settings = 3
}

internal final class RootViewController: UIViewController
{
    // Internal
    
    // Private
    private let rootTabBarController = UITabBarController()
    private let priceTickerViewController = PriceTickerViewController()
    private let accountsListViewController = AccountsListViewController()
    private let transactionsListViewController = TransactionsListViewController()
    private let settingsViewController = SettingsViewController()
    
    private var unlockApplicationViewController: UnlockApplicationViewController?
    
    private var viewHasAppeared = false
    
    private var shouldPresentUnlockViewController: Bool {
        return appLock.lockEnabled // TODO: && check if logged in
    }
    
    // MARK: Initialization
    
    internal required init()
    {
        super.init(nibName: nil, bundle: nil)
        
        // Tab bar controller
        let accountsListNavigationController = UINavigationController(rootViewController: self.accountsListViewController)
        let transactionsListNavigationController = UINavigationController(rootViewController: self.transactionsListViewController)
        let priceTickerNavigationController = UINavigationController(rootViewController: self.priceTickerViewController)
        let settingsNavigationController = UINavigationController(rootViewController: self.settingsViewController)
        
        self.rootTabBarController.viewControllers = [
            accountsListNavigationController,
            transactionsListNavigationController,
            priceTickerNavigationController,
            settingsNavigationController
        ]
        
        // Add as child view controller
        self.addChildViewController(self.rootTabBarController)
        
        // Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationWillEnterForegroundNotification(_:)), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
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
        
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        if !viewHasAppeared {
            // Show the price ticker if there are no institutions
            rootTabBarController.selectedIndex = InstitutionRepository.si.hasInstitutions ? TabIndex.accounts.rawValue : TabIndex.priceTicker.rawValue
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Present unlock screen
        if self.shouldPresentUnlockViewController && !self.viewHasAppeared {
            self.presentUnlockApplicationViewController()
            self.viewHasAppeared = true
        }
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
    
    private func presentUnlockApplicationViewController() {
        if self.unlockApplicationViewController != nil {
            return
        }
        
        let unlockApplicationViewController = UnlockApplicationViewController()
        unlockApplicationViewController.delegate = self
        self.present(unlockApplicationViewController, animated: false, completion: nil)
        
        self.unlockApplicationViewController = unlockApplicationViewController
    }
    
    private func dismissUnlockApplicationViewController() {
        self.unlockApplicationViewController?.dismiss(animated: true, completion: nil)
        self.unlockApplicationViewController = nil
    }
    
    // MARK: UI Defaults
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if self.rootTabBarController.selectedIndex == self.rootTabBarController.viewControllers?.index(of: self.accountsListViewController) {
            return .lightContent
        }
        
        return .default
    }
    
    private func setUIDefaults() {
        // UITabBar
        UITabBar.appearance().barTintColor = UIColor.black
        UITabBar.appearance().tintColor = UIColor.white
        
        // SVProgressHUD
        SVProgressHUD.setHapticsEnabled(true)
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setMinimumDismissTimeInterval(1.0)
    }
    
    // MARK: Notifications
    
    @objc private func applicationWillEnterForegroundNotification(_ notification: Notification) {
        if self.shouldPresentUnlockViewController {
            self.presentUnlockApplicationViewController()
        }
    }
}

// MARK: UnlockApplicationViewControllerDelegate

extension RootViewController: UnlockApplicationViewControllerDelegate {
    func didAuthenticateUser(in controller: UnlockApplicationViewController) {
        self.dismissUnlockApplicationViewController()
    }
}
