//
//  AccountsListViewController.swift
//  BalanceiOS
//
//  Created by Red Davis on 05/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit

final class AccountsListViewController: UIViewController {
    fileprivate let viewModel = AccountsTabViewModel()
    
    private let refreshControl = UIRefreshControl()
    private let collectionView = StackedCardCollectionView()
    private let totalBalanceBar = TotalBalanceBar()
    
    private let blankStateView = BlankStateView(with: .dark)
    private let titleLabel = UILabel()
    private let headerAddAcountButton = UIButton()
    
    // MARK: Initialization
    
    required init() {
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Accounts"
        self.tabBarItem.image = UIImage(named: "Library")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("unsupported")
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        
        // View header
        titleLabel.text = title ?? ""
        titleLabel.font = CurrentTheme.accounts.header.titleLabelFont
        titleLabel.textColor = CurrentTheme.accounts.header.titleLabelColor
        titleLabel.backgroundColor = .clear
        self.view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            if #available(iOS 11, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin)
            } else {
                make.top.equalTo(20)
            }
            make.left.equalTo(20)
            make.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        headerAddAcountButton.setImage(UIImage(named: "iconAdd")?.withRenderingMode(.alwaysTemplate), for: .normal)
        headerAddAcountButton.tintColor = CurrentTheme.accounts.header.addAccountButtonColor
        headerAddAcountButton.addTarget(self, action: #selector(addAccountButtonTapped), for: .touchUpInside)
        self.view.addSubview(headerAddAcountButton)
        headerAddAcountButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(10)
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.centerYWithinMargins.equalTo(titleLabel)
        }
        
        // Refresh controler
        refreshControl.tintColor = CurrentTheme.accounts.header.refreshControlColor
        refreshControl.addTarget(self, action: #selector(self.refreshControlValueChanged(_:)), for: .valueChanged)
        
        // Collection view
        collectionView.refreshControl = refreshControl
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.stackedLayout.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.register(reusableCell: InstitutionCollectionViewCell.self)
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom)
            make.bottom.equalTo(self.bottomLayoutGuide.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
  
        // Blank state view
        blankStateView.isHidden = true
        blankStateView.addTarget(self, action: #selector(addAccountButtonTapped))
        self.view.addSubview(blankStateView)
        blankStateView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
         
        // Total balance bar
        self.view.addSubview(totalBalanceBar)
        totalBalanceBar.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalTo(self.bottomLayoutGuide.snp.top)
            }
        }
        
        self.view.bringSubview(toFront: titleLabel)
        self.view.bringSubview(toFront: headerAddAcountButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
        UIApplication.shared.statusBarStyle = .lightContent
        
        reloadData()
        
        registerForNotifications()
        
        if syncManager.syncing {
            showLoadingSpinner()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
        unregisterForNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var collectionViewContentInset = collectionView.contentInset
        collectionViewContentInset.bottom = totalBalanceBar.bounds.height
        collectionView.contentInset = collectionViewContentInset
    }
    
    //
    // MARK: - Notifications -
    //
    
    func registerForNotifications() {
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadData), name: Notifications.InstitutionAdded)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadData), name: Notifications.InstitutionRemoved)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadData), name: Notifications.InstitutionPatched)
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadData), name: Notifications.AccountRemoved)
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadData), name: Notifications.AccountExcludedFromTotal)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadData), name: Notifications.AccountIncludedInTotal)
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadData), name: Notifications.AccountHidden)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadData), name: Notifications.AccountUnhidden)
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(showLoadingSpinner), name: Notifications.SyncStarted)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadData), name: Notifications.SyncCompleted)
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadData), name: Notifications.MasterCurrencyChanged)
    }
    
    func unregisterForNotifications() {
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.InstitutionAdded)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.InstitutionRemoved)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.InstitutionPatched)
        
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.AccountRemoved)
        
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.AccountExcludedFromTotal)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.AccountIncludedInTotal)
        
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.AccountHidden)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.AccountUnhidden)
        
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.SyncStarted)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.SyncCompleted)
        
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.MasterCurrencyChanged)
    }
    
    // MARK: Reload Data
    
    @objc func showLoadingSpinner() {
        guard !totalBalanceBar.loadingSpinner.isAnimating && !refreshControl.isRefreshing && InstitutionRepository.si.hasInstitutions else {
            return
        }
        
        totalBalanceBar.loadingSpinner.startAnimating()
    }
    
    @objc func reloadData() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(reloadDataDelayed), object: nil)
        self.perform(#selector(reloadDataDelayed), with: nil, afterDelay: 0.5)
    }
    
    @objc private func reloadDataDelayed() {
        DispatchQueue.userInteractive.async {
            self.viewModel.reloadData()
 
            async {
                self.reloadDataFinished()
            }
        }
    }
    
    func reloadDataFinished() {
        collectionView.reloadData(shouldPersistSelection: true, with: viewModel.selectedCardIndexes)
        
        blankStateView.isHidden = viewModel.numberOfSections() > 0
        totalBalanceBar.isHidden = !blankStateView.isHidden
        
        totalBalanceBar.totalBalanceLabel.text = viewModel.formattedMasterCurrencyTotalBalance
        
        if !syncManager.syncing {
            refreshControl.endRefreshing()
            totalBalanceBar.loadingSpinner.stopAnimating()
        }
        
        async(after: 0.1) {
            self.presentReconnectViewIfNeeded()
        }
    }
    
    func presentReconnectViewIfNeeded() {
        guard !InstitutionRepository.si.institutionsWithInvalidPasswords().isEmpty else {
            return
        }
        
        let reconnectServices = AccountServiceProvider()
        let reconnectVM = ReconnectAccountViewModel(services: reconnectServices)
        let reconnectVC = ReconnectAccountViewController(viewModel: reconnectVM)
        let reconnectNavVC = UINavigationController(rootViewController: reconnectVC)
        reconnectNavVC.modalPresentationStyle = .overFullScreen
        
        present(reconnectNavVC, animated: true)
    }
    
    // MARK: Actions
    
    @objc private func addAccountButtonTapped(_ sender: Any) {
        let addAccountViewController = AddAccountViewController()
        let navigationController = UINavigationController(rootViewController: addAccountViewController)
        
        present(navigationController, animated: true, completion: nil)
    }
    
    @objc private func refreshControlValueChanged(_ sender: Any) {
        syncManager.sync(userInitiated: true, validateReceipt: true)
    }
}

// MARK: UICollectionViewDataSource

extension AccountsListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: InstitutionCollectionViewCell = collectionView.dequeueReusableCell(at: indexPath)
        
        guard let institution = viewModel.institution(forSection: indexPath.row) else {
            return cell
        }
        cell.viewModel = AccountsListViewModel(institution: institution)
        return cell
    }
}

// MARK: UICollectionViewDelegate

extension AccountsListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.updateSelectedCards(with: collectionView.indexPathsForSelectedItems ?? [])
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        viewModel.updateSelectedCards(with: collectionView.indexPathsForSelectedItems ?? [])
    }
}

// MARK: StackedLayoutDelegate

extension AccountsListViewController: StackedLayoutDelegate {
    func closedHeightForItem(at indexPath: IndexPath, in collectionView: UICollectionView) -> CGFloat {
        guard let institution = viewModel.institution(forSection: indexPath.row) else {
            return 0
        }
        
        let measurementCell = InstitutionCollectionViewCell.measurementCell
        measurementCell.viewModel = AccountsListViewModel(institution: institution)
        
        // NOTE: It's unintuitive but in the iOS implementation, the table has only one actual section with tables inside the cards,
        // so in this case, the row of the indexPath in the collection view is the section
        return viewModel.isLastSection(indexPath.row) ? measurementCell.closedContentHeight - 40 : measurementCell.closedContentHeight
    }
    
    func expandedHeightForItem(at indexPath: IndexPath, in collectionView: UICollectionView) -> CGFloat {
        guard let institution = viewModel.institution(forSection: indexPath.row) else {
            return 0
        }
        
        let measurementCell = InstitutionCollectionViewCell.measurementCell
        measurementCell.viewModel = AccountsListViewModel(institution: institution)
        return measurementCell.expandedContentHeight
    }
}
