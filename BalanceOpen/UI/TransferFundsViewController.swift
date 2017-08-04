//
//  TransferFundsViewController.swift
//  BalanceOpen
//
//  Created by Red Davis on 03/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Cocoa


internal final class TransferFundsViewController: NSViewController
{
    // Private
    private let sourceAccount: Account
    private let recipientAccount: Account
    private var coinPair: ShapeShiftAPIClient.CoinPair?
    
    private var state = State.loading(message: "Fetching Rates...") {
        didSet
        {
            self.updateStateUI()
        }
    }
    
    private let apiClient: ShapeShiftAPIClient = {
        let client = ShapeShiftAPIClient()
//        client.apiKey = ""
        return client
    }()
    
    private let titleLabel = LabelField(frame: NSRect.zero)
    private let rateLabel = LabelField(frame: NSRect.zero)
    private let maximumDepositLimitLabel = LabelField(frame: NSRect.zero)
    private let minimumDepositLimitLabel = LabelField(frame: NSRect.zero)
    private let minerFeeLabel = LabelField(frame: NSRect.zero)
    
    private let depositAmountField = TextField(frame: NSRect.zero)
    
    private let cancelButton: Button = {
        let button = Button(frame: NSRect.zero)
        button.title = "Cancel"
        button.bezelStyle = .rounded
        
        return button
    }()
    
    private let requestQuoteButton: Button = {
        let button = Button(frame: NSRect.zero)
        button.title = "Request Quote"
        button.bezelStyle = .rounded
        
        return button
    }()
    
    private let requestTransferButton: Button = {
        let button = Button(frame: NSRect.zero)
        button.title = "Request Transfer"
        button.bezelStyle = .rounded
        
        return button
    }()
    
    private let statusLabel = LabelField(frame: NSRect.zero)
    private let progressIndicator: NSProgressIndicator = {
        let indicator = NSProgressIndicator()
        indicator.style = .spinning
        indicator.startAnimation(nil)
        
        return indicator
    }()
    
    private let container = NSView()
    private let statusContainer = NSView()
    
    // MARK: Initialization
    
    internal required init(sourceAccount: Account, recipientAccount: Account)
    {
        self.sourceAccount = sourceAccount
        self.recipientAccount = recipientAccount
        
        super.init(nibName: nil, bundle: nil)
        self.title = "Transfer Funds"
    }
    
    internal required init?(coder: NSCoder)
    {
        abort()
    }
    
    // MARK: View lifecycle
    
    override func loadView()
    {
        self.view = NSView(frame: NSRect(origin: CGPoint.zero, size: CGSize(width: 500.0, height: 500.0)))
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Container
        self.view.addSubview(self.container)
        
        self.container.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.5)
            make.center.equalToSuperview()
        }
        
        // Status container
        self.statusContainer.isHidden = true
        self.view.addSubview(self.statusContainer)
        
        self.statusContainer.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        // Progress indicator
        self.statusContainer.addSubview(self.progressIndicator)
        
        self.progressIndicator.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        // Status label
        self.statusContainer.addSubview(self.statusLabel)
        self.statusLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.progressIndicator.snp.bottom).offset(10.0)
            make.bottom.equalToSuperview()
            make.width.lessThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
        }
        
        // Title label
        self.container.addSubview(self.titleLabel)
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        // Rate label
        self.container.addSubview(self.rateLabel)
        
        self.rateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(10.0)
            make.centerX.equalToSuperview()
        }
        
        // Maximum deposit label
        self.container.addSubview(self.maximumDepositLimitLabel)
        
        self.maximumDepositLimitLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.rateLabel.snp.bottom).offset(10.0)
            make.centerX.equalToSuperview()
        }
        
        // Minimum deposit label
        self.container.addSubview(self.minimumDepositLimitLabel)
        
        self.minimumDepositLimitLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.maximumDepositLimitLabel.snp.bottom).offset(10.0)
            make.centerX.equalToSuperview()
        }
        
        // Miner feed label
        self.container.addSubview(self.minerFeeLabel)
        
        self.minerFeeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.minimumDepositLimitLabel.snp.bottom).offset(10.0)
            make.centerX.equalToSuperview()
        }
        
        // Deposit amount text field
        self.depositAmountField.placeholderString = "Amount to transfer"
        self.container.addSubview(self.depositAmountField)
        
        self.depositAmountField.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.top.equalTo(self.minerFeeLabel.snp.bottom).offset(10.0)
            make.centerX.equalToSuperview()
        }
        
        // Request quote button
        self.requestQuoteButton.set(target: self, action: #selector(self.requestQuoteButtonClicked(_:)))
        self.container.addSubview(self.requestQuoteButton)
        
        self.requestQuoteButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.depositAmountField)
            make.top.equalTo(self.depositAmountField.snp.bottom).offset(10.0)
            make.bottom.equalToSuperview()
        }
        
        // Request transfer button
        self.requestTransferButton.set(target: self, action: #selector(self.requestTransferButtonClicked(_:)))
        self.container.addSubview(self.requestTransferButton)
        
        self.requestTransferButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.requestQuoteButton)
            make.right.equalTo(self.requestQuoteButton)
        }
        
        // Cancel button
        self.cancelButton.set(target: self, action: #selector(self.cancelButtonClicked(_:)))
        self.container.addSubview(self.cancelButton)
        
        self.cancelButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.requestTransferButton)
            make.right.equalTo(self.requestTransferButton.snp.left).offset(-10.0)
        }
        
        self.updateStateUI()
        self.checkSupportedCurrencies()
    }
    
    override func viewDidAppear()
    {
        super.viewDidAppear()
    }
    
    // MARK: State
    
    private func updateStateUI()
    {
        switch self.state
        {
        case .loading(let message):
            self.container.isHidden = true
            self.statusContainer.isHidden = false
            self.statusLabel.stringValue = message
        case .awaitingAmountInput(let marketInformation):
            self.container.isHidden = false
            self.statusContainer.isHidden = true
            
            self.titleLabel.stringValue = "\(self.sourceAccount.currency) (\(self.sourceAccount.displayBalance)) 👉 \(self.recipientAccount.currency) (\(self.recipientAccount.displayBalance))"
            self.rateLabel.stringValue = "Rate: \(marketInformation.rate)"
            self.maximumDepositLimitLabel.stringValue = "Maximum Deposit: \(marketInformation.maximumDepositLimit)"
            self.minimumDepositLimitLabel.stringValue = "Minimum Deposit: \(marketInformation.minimumDepositLimit)"
            self.minerFeeLabel.stringValue = "Miner Fee: \(marketInformation.minerFee)"
            
            self.depositAmountField.isHidden = false
            
            self.cancelButton.isHidden = true
            self.requestQuoteButton.isHidden = false
            self.requestTransferButton.isHidden = true
        case .displaying(let quote):
            self.container.isHidden = false
            self.statusContainer.isHidden = true
            
            self.rateLabel.stringValue = "Rate: \(quote.rate)"
            self.maximumDepositLimitLabel.stringValue = "Recipient Amount: \(quote.recipientAmount)"
            self.minimumDepositLimitLabel.stringValue = "Deposit Amount: \(quote.depositAmount)"
            self.minerFeeLabel.stringValue = "Miner Fee: \(quote.minerFee)"
            
            self.depositAmountField.isHidden = true
            
            self.cancelButton.isHidden = false
            self.requestQuoteButton.isHidden = true
            self.requestTransferButton.isHidden = false
        case .transferComplete:
            self.container.isHidden = false
            self.statusContainer.isHidden = true
            
            self.rateLabel.isHidden = true
            self.maximumDepositLimitLabel.isHidden = true
            self.minimumDepositLimitLabel.isHidden = true
            self.minerFeeLabel.isHidden = true
            self.depositAmountField.isHidden = true
            self.cancelButton.isHidden = true
            self.requestQuoteButton.isHidden = true
            self.requestTransferButton.isHidden = false
            
            self.titleLabel.stringValue = "👍 Transfer Complete!"
            self.requestTransferButton.title = "Request a Receipt"
        default:()
        }
    }
    
    // MARK: Market rates
    
    private func checkSupportedCurrencies()
    {
        self.apiClient.fetchSupportedCoins { [unowned self] (coins, error) in
            DispatchQueue.main.async {
                guard let unwrappedCoins = coins else
                {
                    return
                }
                
                let sourceCoin = unwrappedCoins.first(where: { (coin) -> Bool in
                    return coin.symbol == self.sourceAccount.currency
                })
                
                let recipientCoin = unwrappedCoins.first(where: { (coin) -> Bool in
                    return coin.symbol == self.recipientAccount.currency
                })
                
                guard let unwrappedSourceCoin = sourceCoin,
                    let unwrappedRecipientCoin = recipientCoin,
                    unwrappedSourceCoin.isAvailable,
                    unwrappedRecipientCoin.isAvailable else
                {
                    self.state = .error(message: "Currency not currently availble")
                    return
                }
                
                self.coinPair = ShapeShiftAPIClient.CoinPair(input: unwrappedSourceCoin, output: unwrappedRecipientCoin)
                self.fetchMarketRates()
            }
        }
    }
    
    private func fetchMarketRates()
    {
        guard let unwrappedCoinPair = self.coinPair else
        {
            fatalError()
        }
        
        self.state = .loading(message: "Fetching market rates...")
        
        self.apiClient.fetchMarketInformation(for: unwrappedCoinPair) { [unowned self] (marketInformation, error) in
            DispatchQueue.main.async {
                guard let unwrappedMarketInformation = marketInformation else
                {
                    self.state = .error(message: "Error fetching rates")
                    return
                }
                
                self.state = .awaitingAmountInput(marketInformation: unwrappedMarketInformation)
            }
        }
    }
    
    // MARK: Actions
    
    @objc private func requestQuoteButtonClicked(_ sender: Any)
    {
        guard let unwrappedCoinPair = self.coinPair,
              let amount = Double(self.depositAmountField.stringValue) else
        {
            fatalError()
        }
        
        self.state = .loading(message: "Fetching quote...")
        
        self.apiClient.fetchQuote(amount: amount, pairCode: unwrappedCoinPair.code) { [unowned self] (quote, error) in
            DispatchQueue.main.async {
                guard let unwrappedQuote = quote else
                {
                    self.state = .error(message: "Unable to fetch quote")
                    return
                }
                
                self.state = .displaying(quote: unwrappedQuote)
            }
        }
    }
    
    @objc private func requestTransferButtonClicked(_ sender: Any)
    {
        self.state = .loading(message: "Transfer in progress...")
        
        // TODO:
        // 1. Make transfer request
        // 2. Make withdrawel from source account
        // 3. Show success
        
        DispatchQueue.main.async(after: 1.0) {
            self.state = .transferComplete
        }
    }
    
    @objc private func cancelButtonClicked(_ sender: Any)
    {
        self.fetchMarketRates()
    }
}

// MARK: State

fileprivate extension TransferFundsViewController
{
    fileprivate enum State
    {
        case loading(message: String)
        case awaitingAmountInput(marketInformation: ShapeShiftAPIClient.MarketInformation)
        case displaying(quote: ShapeShiftAPIClient.Quote)
        case transferComplete
        case error(message: String)
    }
}
