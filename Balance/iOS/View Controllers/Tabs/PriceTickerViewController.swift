//
//  PriceTickerViewController.swift
//  BalanceiOS
//
//  Created by Red Davis on 07/11/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit

internal final class PriceTickerViewController: UIViewController {
    
    // Private
    
    private let viewModel = PriceTickerTabViewModel()
    private let refreshControl = UIRefreshControl()
    private let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionHeadersPinToVisibleBounds = true
        flowLayout.headerReferenceSize = CurrentTheme.priceTicker.collectionView.headerReferenceSize
        flowLayout.sectionInset = CurrentTheme.priceTicker.collectionView.sectionInset
        flowLayout.minimumLineSpacing = CurrentTheme.priceTicker.collectionView.minimumLineSpacing
        return UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    }()
    
    // MARK: Initialization
    
    internal required init() {
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Ticker"
        self.tabBarItem.image = UIImage(named: "Activity")
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        abort()
    }
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
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
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadData), name: CurrentExchangeRates.Notifications.exchangeRatesUpdated)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadData), name: Notifications.MasterCurrencyChanged)
    }
    
    func unregisterForNotifications() {
        NotificationCenter.removeObserverOnMainThread(self, name: CurrentExchangeRates.Notifications.exchangeRatesUpdated)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.MasterCurrencyChanged)
    }

}

// MARK: Private Methods
private extension PriceTickerViewController {
    
    func setupView() {
        // Navigation bar
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        // Refresh control
        refreshControl.addTarget(self, action: #selector(refreshControlValueChanged), for: .valueChanged)
        
        collectionView.backgroundColor = CurrentTheme.priceTicker.collectionView.backgroundColor
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(reusableCell: CurrencyCollectionViewCell.self)
        collectionView.register(reusableSupplementaryView: CustomHeaderReusableView.self,
                                kind: UICollectionElementKindSectionHeader)
        collectionView.refreshControl = self.refreshControl
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    
    // MARK: Data
    @objc func reloadData() {
        viewModel.reloadData()
        collectionView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // MARK: Actions
    @objc func refreshControlValueChanged(_ sender: Any) {
        currentExchangeRates.updateExchangeRates()
    }
}

// MARK: UICollectionViewDataSource

extension PriceTickerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfRows(inSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(at: indexPath) as CurrencyCollectionViewCell
    }
}

// MARK: UICollectionViewDelegate

extension PriceTickerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let currencyCell = cell as? CurrencyCollectionViewCell else {
            return
        }
        
        if let currency = viewModel.currency(forRow: indexPath.row, inSection: indexPath.section) {
            let rate = viewModel.ratesString(forRow: indexPath.row, inSection: indexPath.section)
            currencyCell.update(currency: currency, rate: rate)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(at: indexPath, kind: kind) as CustomHeaderReusableView
        header.textLabel.text = viewModel.name(forSection: indexPath.section)
        
        return header
    }
    
}

// MARK: UICollectionViewFlowLayout

extension PriceTickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: CurrentTheme.priceTicker.cell.height)
    }
}
