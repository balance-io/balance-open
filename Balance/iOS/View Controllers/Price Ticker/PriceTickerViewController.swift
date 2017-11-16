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
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
        return collectionView
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
        
        // Navigation bar
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        // Refresh control
        self.collectionView.refreshControl = self.refreshControl
        self.refreshControl.addTarget(self, action: #selector(self.refreshControlValueChanged(_:)), for: .valueChanged)
        
        // Collection view
        self.collectionView.backgroundColor = UIColor(red: 237.0/255.0, green: 238.0/255.0, blue: 240.0/255.0, alpha: 1.0)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(reusableCell: CurrencyCollectionViewCell.self)
        self.view.addSubview(self.collectionView)
        
        self.collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Data
    
    @objc private func reloadData() {
        self.viewModel.reloadData()
        self.collectionView.reloadData()
    }
    
    // MARK: Actions
    
    @objc private func refreshControlValueChanged(_ sender: Any) {
        self.viewModel.reloadData()
        self.refreshControl.endRefreshing()
    }
}

// MARK: UICollectionViewDataSource

extension PriceTickerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.viewModel.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.numberOfRows(inSection: section)
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
        
        currencyCell.currency = self.viewModel.currency(forRow: indexPath.row, inSection: indexPath.section)
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
