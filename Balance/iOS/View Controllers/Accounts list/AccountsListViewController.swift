//
//  AccountsListViewController.swift
//  BalanceiOS
//
//  Created by Red Davis on 05/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit


internal final class AccountsListViewController: UIViewController {
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
       
        
        // Notifications
        NotificationCenter.addObserverOnMainThread(self,
                                                   selector: #selector(syncCompletedNotification),
                                                   name: Notifications.SyncCompleted)
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        abort()
    }
    
    deinit {
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.SyncCompleted)
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
        refreshControl.tintColor = UIColor.white
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
        UIApplication.shared.statusBarStyle = .lightContent
        
        reloadData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.presentReconnectViewIfNeeded()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var collectionViewContentInset = collectionView.contentInset
        collectionViewContentInset.bottom = totalBalanceBar.bounds.height
        collectionView.contentInset = collectionViewContentInset

    }
    
    // MARK: Data
    
    private func reloadData() {
        self.viewModel.reloadData()
        self.collectionView.reloadData(shouldPersistSelection: true, with: viewModel.selectedCardIndexes)
        
        self.blankStateView.isHidden = viewModel.numberOfSections() > 0
        self.totalBalanceBar.isHidden = !blankStateView.isHidden
        
        self.totalBalanceBar.totalBalanceLabel.text = viewModel.formattedMasterCurrencyTotalBalance
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
        syncManager.sync(userInitiated: true, validateReceipt: true) { (success, _) in
            self.refreshControl.endRefreshing()
        }
    }
    
    // MARK: Notifications
    
    @objc private func syncCompletedNotification(_ notification: Notification) {
        reloadData()
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
        
        return measurementCell.closedContentHeight
    }
    
    func expandedHeightForItem(at indexPath: IndexPath, in collectionView: UICollectionView) -> CGFloat {
        let institution = viewModel.institution(forSection: indexPath.row)!
        
        let measurementCell = InstitutionCollectionViewCell.measurementCell
        measurementCell.viewModel = InstitutionAccountsListViewModel(institution: institution)
        
        return measurementCell.expandedContentHeight
    }
    
}
