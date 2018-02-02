//
//  AccountsListViewController.swift
//  BalanceiOS
//
//  Created by Red Davis on 05/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit

final class AccountsListViewController: UIViewController {
    // Fileprivate
    fileprivate let viewModel = AccountsTabViewModel()
    
    // Private
    private let refreshControl = UIRefreshControl()
    private let collectionView = StackedCardCollectionView()
    private let totalBalanceBar = TotalBalanceBar()
    
    private let blankStateView = BlankStateView(with: .dark)
    private let titleLabel = UILabel()
    private let headerAddAcountButton = UIButton()
    
    // MARK: Initialization
    
    internal required init() {
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Accounts"
        self.tabBarItem.image = UIImage(named: "Library")
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        abort()
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        // View header
        titleLabel.text = title ?? ""
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        titleLabel.textColor = .white
        titleLabel.backgroundColor = .clear
        
        view.addSubview(titleLabel)

        titleLabel.snp.makeConstraints{
            if #available(iOS 11, *) {
                $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin)
            } else {
                $0.top.equalTo(20)
            }
            $0.left.equalTo(20)
            $0.right.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        headerAddAcountButton.setImage(UIImage(named: "iconAdd")?.withRenderingMode(.alwaysTemplate), for: .normal)
        headerAddAcountButton.tintColor = .white
        headerAddAcountButton.addTarget(self, action: #selector(addAccountButtonTapped), for: .touchUpInside)
        
        view.addSubview(headerAddAcountButton)
        
        headerAddAcountButton.snp.makeConstraints {
            $0.right.equalToSuperview().inset(10)
            $0.size.width.equalTo(50)
            $0.size.height.equalTo(50)
            $0.centerYWithinMargins.equalTo(titleLabel)
        }
        
        // Refresh controler
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(self.refreshControlValueChanged(_:)), for: .valueChanged)
        
        // Collection view
        collectionView.refreshControl = self.refreshControl
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.stackedLayout.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.register(reusableCell: InstitutionCollectionViewCell.self)
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom)
            make.bottom.equalTo(self.bottomLayoutGuide.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
  
        // Blank state view
        blankStateView.isHidden = true
        blankStateView.addTarget(self, action: #selector(addAccountButtonTapped))
        view.addSubview(blankStateView)
        
        blankStateView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
         
        // Total balance bar
        view.addSubview(totalBalanceBar)
        
        totalBalanceBar.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalTo(self.bottomLayoutGuide.snp.top)
            }
        }
        
        view.bringSubview(toFront: titleLabel)
        view.bringSubview(toFront: headerAddAcountButton)
        
        // NOTE: Due to a bug in UIRefreshControl (since iOS 7...yeah), if we don't call this here the
        // tintColor will not be used on the first refresh unless the user manually drags the table down a bit
        showLoadingSpinner()
        refreshControl.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
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
        guard !refreshControl.isRefreshing && InstitutionRepository.si.hasInstitutions else {
            return
        }
        
        // If we're at the top of the view, like on first launch, then slide the view down to show the spinner
        // otherwise, don't so it doesn't interrupt the user if they've scrolled down but they can still see it
        // if they scroll up
        if collectionView.contentOffset == CGPoint.zero {
            collectionView.setContentOffset(CGPoint(x: 0, y: -1), animated: false)
            collectionView.setContentOffset(CGPoint(x: 0, y: -refreshControl.frame.size.height), animated: true)
        }
        
        refreshControl.beginRefreshing()
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
        
        let institution = self.viewModel.institution(forSection: indexPath.row)!
        let viewModel = InstitutionAccountsListViewModel(institution: institution)
        cell.viewModel = viewModel
        
        return cell
    }
    
}

// MARK: UICollectionViewDelegate

extension AccountsListViewController: UICollectionViewDelegate
{
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
        let institution = viewModel.institution(forSection: indexPath.row)!
        
        let measurementCell = InstitutionCollectionViewCell.measurementCell
        measurementCell.viewModel = InstitutionAccountsListViewModel(institution: institution)
        
        // NOTE: It's unintuitive but in the iOS implementation, the table has only one actual section with tables inside the cards,
        // so in this case, the row of the indexPath in the collection view is the section
        return viewModel.isLastSection(indexPath.row) ? measurementCell.closedContentHeight - 40 : measurementCell.closedContentHeight
    }
    
    func expandedHeightForItem(at indexPath: IndexPath, in collectionView: UICollectionView) -> CGFloat {
        let institution = viewModel.institution(forSection: indexPath.row)!
        
        let measurementCell = InstitutionCollectionViewCell.measurementCell
        measurementCell.viewModel = InstitutionAccountsListViewModel(institution: institution)
        
        return measurementCell.expandedContentHeight
    }
    
}
