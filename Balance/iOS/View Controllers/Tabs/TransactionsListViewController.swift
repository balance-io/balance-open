//
//  TransactionsListViewController.swift
//  BalanceiOS
//
//  Created by Red Davis on 03/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


internal final class TransactionsListViewController: UIViewController, TransactionsTabViewModelDelegate {
    // Private
    private let viewModel = TransactionsTabViewModel()
    private let refreshControl = UIRefreshControl()
    
    private let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
        return collectionView
    }()
    
    // MARK: Initialization
    
    internal required init() {
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Transactions"
        self.tabBarItem.image = UIImage(named: "Cash")
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        abort()
    }

    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation bar
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        // Refresh control
        self.collectionView.refreshControl = self.refreshControl
        self.refreshControl.addTarget(self, action: #selector(self.refreshControlValueChanged(_:)), for: .valueChanged)
        
        // Collection view
        self.collectionView.refreshControl = self.refreshControl
        self.collectionView.backgroundColor = UIColor(red: 237.0/255.0, green: 238.0/255.0, blue: 240.0/255.0, alpha: 1.0)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(reusableCell: TransactionCollectionViewCell.self)
        self.collectionView.register(reusableSupplementaryView: CustomHeaderReusableView.self, kind: UICollectionElementKindSectionHeader)
        self.view.addSubview(self.collectionView)
        
        self.collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        viewModel.delegate = self
        viewModel.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.reloadData()
        
        registerForNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unregisterForNotifications()
    }
    
    //
    // MARK: - Notifications -
    //
    
    func registerForNotifications() {
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadData), name: Notifications.InstitutionAdded)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadData), name: Notifications.InstitutionRemoved)
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadData), name: Notifications.AccountHidden)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadData), name: Notifications.AccountUnhidden)
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadData), name: Notifications.SyncCompleted)
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadData), name: Notifications.MasterCurrencyChanged)
    }
    
    func unregisterForNotifications() {
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.InstitutionAdded)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.InstitutionRemoved)
        
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.AccountHidden)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.AccountUnhidden)
        
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.SyncCompleted)
        
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.MasterCurrencyChanged)
    }
    
    // MARK: Actions
    
    @objc private func refreshControlValueChanged(_ sender: Any) {
        syncManager.sync(userInitiated: true, validateReceipt: true)
    }
    
    // MARK: Reload Data
    
    @objc func reloadData() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(reloadDataDelayed), object: nil)
        self.perform(#selector(reloadDataDelayed), with: nil, afterDelay: 0.5)
    }
    
    @objc private func reloadDataDelayed() {
        viewModel.reloadData()
    }
    
    func reloadDataFinished() {
        collectionView.reloadData()
        refreshControl.endRefreshing()
    }
}

// MARK: UITableViewDataSource

extension TransactionsListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfRows(inSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(at: indexPath) as TransactionCollectionViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(at: indexPath, kind: kind) as CustomHeaderReusableView
        header.textLabel.text = self.viewModel.sectionTitle(for: indexPath.section)
        
        return header
    }
}

// MARK: UICollectionViewDelegate

extension TransactionsListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? TransactionCollectionViewCell else {
            return
        }
        
        cell.transaction = viewModel.transaction(forRow: indexPath.row, inSection: indexPath.section)
    }
}

// MARK: UICollectionViewFlowLayout

extension TransactionsListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: TransactionCollectionViewCell.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 45.0)
    }
}
