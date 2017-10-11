//
//  AccountsListViewController.swift
//  BalanceiOS
//
//  Created by Red Davis on 05/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


internal final class AccountsListViewController: UIViewController
{
    // Fileprivate
    private let viewModel = AccountsTabViewModel()
    
    // Private
    private let collectionView: UICollectionView = {
        let layout = StackedLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        return view
    }()
    
    private let titleView = MultilineTitleView()
    
    // MARK: Initialization
    
    internal required init()
    {
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Accounts"
        self.tabBarItem.image = UIImage(named: "Library")
        
        // Notifications
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(self.syncCompletedNotification(_:)), name: Notifications.SyncCompleted)
    }
    
    internal required init?(coder aDecoder: NSCoder)
    {
        abort()
    }
    
    deinit
    {
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.SyncCompleted)
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Navigation bar
        self.setupTitleView()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addAccountButtonTapped(_:)))
        
        // Collection view
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = UIColor.black
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.register(reusableCell: InstitutionCollectionViewCell.self)
        self.view.addSubview(self.collectionView)
        
        self.collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.reloadData()
    }
    
    // MARK: Data
    
    private func reloadData()
    {
        self.viewModel.reloadData()
        self.collectionView.reloadData()
        
        // Total balance
        self.titleView.detailLabel.attributedText = centsToStringFormatted(self.viewModel.totalBalance(), showNegative: true)
    }
    
    // MARK: UI
    
    private func setupTitleView()
    {
        if let navigationBar = self.navigationController?.navigationBar
        {
            let navigationBarBounds = navigationBar.bounds
            
            let containerView = UIView()
            containerView.frame = navigationBarBounds
            containerView.autoresizingMask = UIViewAutoresizing.flexibleWidth
            self.navigationItem.titleView = containerView
            
            // Add the title view
            self.titleView.titleLabel.text = "Total Balance"
            navigationBar.addSubview(self.titleView)
            
            self.titleView.snp.makeConstraints({ (make) in
                make.width.lessThanOrEqualToSuperview().multipliedBy(0.6)
                make.height.equalToSuperview()
                make.center.equalTo(navigationBar)
            })
        }
    }
    
    // MARK: Actions
    
    @objc private func addAccountButtonTapped(_ sender: Any)
    {
        let addAccountViewController = AddAccountViewController()
        let navigationController = UINavigationController(rootViewController: addAccountViewController)
        
        self.present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: Notifications
    
    @objc private func syncCompletedNotification(_ notification: Notification)
    {
        self.reloadData()
    }
}

// MARK: UICollectionViewDataSource

extension AccountsListViewController: UICollectionViewDataSource
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: InstitutionCollectionViewCell = collectionView.dequeueReusableCell(at: indexPath)
        
        let institution = self.viewModel.institution(forSection: indexPath.row)!
        let viewModel = InstitutionAccountsListViewModel(institution: institution)
        cell.viewModel = viewModel
        
        return cell
    }
}

// MARK: UICollectionViewDelegate

extension AccountsListViewController: UICollectionViewDelegate
{

}
