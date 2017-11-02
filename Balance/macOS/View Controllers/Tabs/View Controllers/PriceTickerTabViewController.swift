//
//  PriceTickerTabViewController.swift
//  BalancemacOS
//
//  Created by Benjamin Baron on 11/2/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

class PriceTickerTabViewController: NSViewController, SectionedTableViewDelegate, SectionedTableViewDataSource {
    
    //
    // MARK: - Properties -
    //
    
    let viewModel = PriceTickerTabViewModel()
    
    // MARK: Body
    let scrollView = ScrollView()
    let tableView = SectionedTableView()
    
    //
    // MARK: - Lifecycle -
    //
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    deinit {
        unregisterForNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadData()
        
        registerForNotifications()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        reloadData()
    }
    
    //
    // MARK: - View Creation -
    //
    
    override func loadView() {
        self.view = View()
        
        createTable()
    }
    
    func createTable() {
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.verticalScrollElasticity = .none
        scrollView.documentView = tableView
        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        tableView.setAccessibilityLabel("Price Tracker Table")
        tableView.customDelegate = self
        tableView.customDataSource = self
        tableView.displayEmptySectionRows = true
        tableView.intercellSpacing = NSZeroSize
        tableView.selectionHighlightStyle = .none
        
        tableView.reloadData()
    }
    
    //
    // MARK: - Data Reloading -
    //
    
    func reloadData() {
        viewModel.reloadData()
        tableView.reloadData()
    }
    
    //
    // MARK: - Notifications -
    //
    
    func registerForNotifications() {
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(exchangeRatesUpdated), name: CurrentExchangeRates.Notifications.exchangeRatesUpdated)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(masterCurrencyChanged), name: Notifications.MasterCurrencyChanged)
    }
    
    func unregisterForNotifications() {
        NotificationCenter.removeObserverOnMainThread(self, name: CurrentExchangeRates.Notifications.exchangeRatesUpdated)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.MasterCurrencyChanged)
    }
    
    @objc private func exchangeRatesUpdated() {
        reloadData()
    }
    
    @objc private func masterCurrencyChanged() {
        reloadData()
    }
    
    //
    // MARK: - Table View -
    //
    
    func numberOfSectionsInTableView(_ tableView: SectionedTableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: SectionedTableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(inSection: section)
    }
    
    func tableView(_ tableView: SectionedTableView, heightOfRow row: Int, inSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: SectionedTableView, rowViewForRow row: Int, inSection section: Int) -> NSTableRowView? {
        var rowView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Exchange Rate Row"), owner: self) as? HoverTableRowView
        if rowView == nil {
            rowView = HoverTableRowView()
            rowView?.identifier = NSUserInterfaceItemIdentifier(rawValue: "Exchange Rate Row")
        }
        
        return rowView
    }
    
    func tableView(_ tableView: SectionedTableView, viewForRow row: Int, inSection section: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Exchange Rate Cell"), owner: self) as? PriceTickerRateCell ?? PriceTickerRateCell()
        cell.identifier = NSUserInterfaceItemIdentifier(rawValue: "Exchange Rate Cell")
        
        if let currency = viewModel.currency(forRow: row, inSection: section) {
            let convertedAmount = currentExchangeRates.convert(amount: 1.0, from: currency, to: defaults.masterCurrency, source: .poloniex)?.integerValueWith(decimals: defaults.masterCurrency.decimals) ?? 0
            let convertedAmountString = amountToString(amount: convertedAmount, currency: defaults.masterCurrency, showNegative: true)
            cell.updateModel("\(currency.longName): \(convertedAmountString)")
        }
        return cell
    }
}
