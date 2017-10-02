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
    private let accountsListViewController = AccountsListViewController()
    private let rootNavigationController: UINavigationController
    
    // MARK: Initialization
    
    internal required init()
    {
        // Root navigation controller
        self.rootNavigationController = UINavigationController(rootViewController: self.accountsListViewController)
        
        super.init(nibName: nil, bundle: nil)
        
        self.addChildViewController(self.rootNavigationController)
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
        
        // Root navigation controller
        self.view.addSubview(self.rootNavigationController.view)

        self.rootNavigationController.view.snp.makeConstraints { (make) in
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
    
    private func setUIDefaults()
    {
        // TODO:
    }
}
