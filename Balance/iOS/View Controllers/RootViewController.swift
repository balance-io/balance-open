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

final class RootViewController: UIViewController {
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
    
    required init() {
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
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(self.applicationWillEnterForegroundNotification(_:)), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("unsupported")
    }
    
    deinit {
        NotificationCenter.removeObserverOnMainThread(self, name: Notification.Name.UIApplicationWillEnterForeground)
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUIDefaults()
        
        // Root tab bar controller
        self.view.addSubview(rootTabBarController.view)

        rootTabBarController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !viewHasAppeared {
            // Show the price ticker if there are no institutions
            rootTabBarController.selectedIndex = InstitutionRepository.si.hasInstitutions ? TabIndex.accounts.rawValue : TabIndex.priceTicker.rawValue
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Present unlock screen
        if shouldPresentUnlockViewController && !viewHasAppeared {
            presentUnlockApplicationViewController()
            viewHasAppeared = true
        }
    }
    
    // MARK: Presentation
    
    private func presentSplashScreen() {
        let splashScreenViewController = SplashScreenViewController()
        let navigationController = UINavigationController(rootViewController: splashScreenViewController)
        
        self.present(navigationController, animated: true, completion: nil)
    }
    
    private func presentUnlockApplicationViewController() {
        if unlockApplicationViewController != nil {
            return
        }
        
        unlockApplicationViewController = UnlockApplicationViewController()
        unlockApplicationViewController!.delegate = self
        self.present(unlockApplicationViewController!, animated: false, completion: nil)
    }
    
    private func dismissUnlockApplicationViewController() {
        unlockApplicationViewController?.dismiss(animated: true, completion: nil)
        unlockApplicationViewController = nil
    }
    
    // MARK: UI Defaults
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if rootTabBarController.selectedIndex == rootTabBarController.viewControllers?.index(of: accountsListViewController) {
            return .lightContent
        }
        
        return .default
    }
    
    private func setupUIDefaults() {
        // UITabBar
        UITabBar.appearance().barTintColor = .black
        UITabBar.appearance().tintColor = .white
        
        // SVProgressHUD
        SVProgressHUD.setHapticsEnabled(true)
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setMinimumDismissTimeInterval(1.0)
    }
    
    // MARK: Notifications
    
    @objc private func applicationWillEnterForegroundNotification(_ notification: Notification) {
        if shouldPresentUnlockViewController {
            presentUnlockApplicationViewController()
        }
    }
}

// MARK: UnlockApplicationViewControllerDelegate

extension RootViewController: UnlockApplicationViewControllerDelegate {
    func didAuthenticateUser(in controller: UnlockApplicationViewController) {
        self.dismissUnlockApplicationViewController()
    }
}
