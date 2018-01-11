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
        flowLayout.sectionInset = UIEdgeInsetsMake(20, 0, 20, 0);
        flowLayout.headerReferenceSize = CGSize(width: 30, height: 30)
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
        self.reloadData()
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadData), name: CurrentExchangeRates.Notifications.exchangeRatesUpdated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.removeObserverOnMainThread(self, name: CurrentExchangeRates.Notifications.exchangeRatesUpdated, object: nil)
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
        
        collectionView.backgroundColor = UIColor(red: 237.0/255.0, green: 238.0/255.0, blue: 240.0/255.0, alpha: 1.0)
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
    }
    
    // MARK: Actions
    @objc func refreshControlValueChanged(_ sender: Any) {
        viewModel.reloadData()
        refreshControl.endRefreshing()
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
        return CGSize(width: collectionView.bounds.width, height: 50.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
}
