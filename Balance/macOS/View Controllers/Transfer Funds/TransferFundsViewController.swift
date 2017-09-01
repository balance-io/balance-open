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
    // Fileprivate
    fileprivate var state = State.default {
        didSet
        {
            self.updateStateUI()
        }
    }
    
    // Private
    private let viewModel = TransferFundsViewModel()
    private var transferController: TransferController?
    
    private let container = View()
    
    private let sourceAccountPopupButton = NSPopUpButton()
    private let sourceAccountBalanceLabel = LabelField(frame: NSRect.zero)
    
    private let recipientAccountPopupButton = NSPopUpButton()
    private let recipientAccountBalanceLabel = LabelField(frame: NSRect.zero)
    
    private let exchangeArrowImageView: NSImageView = {
        let imageView = NSImageView()
        imageView.image = NSImage(named: NSImage.Name(rawValue: "transfer-arrow"))
        
        return imageView
    }()
    
    private let exchangeAmountTextField = TextField(frame: NSRect.zero)
    private let exchangeAmountCurrencyPopupButton = NSPopUpButton()
    
    private let recipientAmountLabel = LabelField(frame: NSRect.zero)
    
    private let minerFeeLabel = LabelField(frame: NSRect.zero)
    private let minerFeeHelpButton: Button = {
        let button = Button(frame: NSRect.zero)
        button.bezelStyle = .helpButton
        button.title = ""
        
        return button
    }()
    
    private let errorLabel: LabelField = {
        let label = LabelField(frame: NSRect.zero)
        label.textColor = NSColor(hexString: "AB0000")
        label.alignment = .center
        
        return label
    }()
    
    private let cancelButton: Button = {
        let button = Button(frame: NSRect.zero)
        button.title = "Cancel"
        button.bezelStyle = .rounded
        
        return button
    }()
    
    private let exchangeButton: Button = {
        let button = Button(frame: NSRect.zero)
        button.title = "Exchange"
        button.bezelStyle = .rounded
        
        return button
    }()
    
    // MARK: Initialization
    
    internal required init(source: Account?, recipient: Account?)
    {
        super.init(nibName: nil, bundle: nil)
        self.title = "Transfer Funds"
        
        self.viewModel.sourceAccount = source
        self.viewModel.recipientAccount = recipient
    }
    
    internal required init?(coder: NSCoder)
    {
        abort()
    }
    
    // MARK: View lifecycle
    
    override func loadView()
    {
        self.view = View()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Container
        self.view.addSubview(self.container)
        
        self.container.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        // Source account combo box
        self.sourceAccountPopupButton.target = self
        self.sourceAccountPopupButton.action = #selector(self.accountSelectionChanged(_:))
        self.sourceAccountPopupButton.addItems(withTitles: self.viewModel.accountNames)
        self.container.addSubview(self.sourceAccountPopupButton)
        
        self.sourceAccountPopupButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(10.0)
            make.top.equalToSuperview().inset(10.0)
            make.width.equalTo(170.0)
        }
        
        // Select predefined recipient account
        if let sourceAccount = self.viewModel.sourceAccount,
           let index = self.viewModel.index(of: sourceAccount)
        {
            self.sourceAccountPopupButton.selectItem(at: index)
        }
        
        // Source account balance label
        self.container.addSubview(self.sourceAccountBalanceLabel)
        
        self.sourceAccountBalanceLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self.sourceAccountPopupButton)
            make.top.equalTo(self.sourceAccountPopupButton.snp.bottom).offset(5.0)
        }
        
        // Recipient account combo box
        self.recipientAccountPopupButton.target = self
        self.recipientAccountPopupButton.action = #selector(self.accountSelectionChanged(_:))
        self.recipientAccountPopupButton.addItems(withTitles: self.viewModel.accountNames)
        self.container.addSubview(self.recipientAccountPopupButton)
        
        self.recipientAccountPopupButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(10.0)
            make.top.equalToSuperview().inset(10.0)
            make.width.equalTo(170.0)
        }
        
        // Select predefined recipient account
        if let recipientAccount = self.viewModel.recipientAccount,
           let index = self.viewModel.index(of: recipientAccount)
        {
            self.recipientAccountPopupButton.selectItem(at: index)
        }
        
        // Recipient account balance label
        self.container.addSubview(self.recipientAccountBalanceLabel)
        
        self.recipientAccountBalanceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.recipientAccountPopupButton)
            make.top.equalTo(self.recipientAccountPopupButton.snp.bottom).offset(5.0)
        }
        
        // Exchange arrow
        self.container.addSubview(self.exchangeArrowImageView)
        
        self.exchangeArrowImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.sourceAccountBalanceLabel.snp.bottom).offset(20.0)
        }
        
        // Exchange amount currency popup button
        // TODO: Unhide once we support main currency to X
        self.exchangeAmountCurrencyPopupButton.isHidden = true
        self.container.addSubview(self.exchangeAmountCurrencyPopupButton)
        
        self.exchangeAmountCurrencyPopupButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.sourceAccountPopupButton)
            make.width.equalTo(60.0)
            make.centerY.equalTo(self.exchangeArrowImageView)
        }
        
        // Exchange amount text field
        self.exchangeAmountTextField.delegate = self
        self.exchangeAmountTextField.stringValue = "1.00"
        self.exchangeAmountTextField.formatter = CurrencyTextFieldFormatter()
        self.exchangeAmountTextField.alignment = .right
        self.container.addSubview(self.exchangeAmountTextField)
        
        self.exchangeAmountTextField.snp.makeConstraints { (make) in
            make.width.equalTo(104.0)
            make.height.equalTo(self.exchangeAmountCurrencyPopupButton)
            make.right.equalTo(self.sourceAccountPopupButton)
            make.centerY.equalTo(self.exchangeArrowImageView)
        }
        
        // Recipient amount label
        self.container.addSubview(self.recipientAmountLabel)
        
        self.recipientAmountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.recipientAccountPopupButton)
            make.centerY.equalTo(self.exchangeArrowImageView)
        }
        
        // Miner fee label
        self.container.addSubview(self.minerFeeLabel)

        self.minerFeeLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.exchangeAmountTextField.snp.bottom).offset(20.0)
        }

        // Miner fee help button
        self.minerFeeHelpButton.set(target: self, action: #selector(self.minerFeeHelpButtonClicked(_:)))
        self.container.addSubview(self.minerFeeHelpButton)

        self.minerFeeHelpButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.minerFeeLabel)
            make.left.equalTo(self.minerFeeLabel.snp.right).offset(5.0)
        }

        // Cancel button
        self.cancelButton.set(target: self, action: #selector(self.cancelButtonClicked(_:)))
        self.container.addSubview(self.cancelButton)

        self.cancelButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(10.0)
            make.top.equalTo(self.minerFeeLabel.snp.bottom).offset(20.0)
            make.bottom.equalToSuperview().inset(10.0)
        }

        // Exchange button
        self.exchangeButton.set(target: self, action: #selector(self.exchangeButtonClicked(_:)))
        self.container.addSubview(self.exchangeButton)

        self.exchangeButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(10.0)
            make.bottom.equalToSuperview().inset(10.0)
        }

        // Error label
        self.errorLabel.isHidden = true
        self.container.addSubview(self.errorLabel)

        self.errorLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(self.cancelButton)
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
    }
    
    override func viewDidAppear()
    {
        super.viewDidAppear()
        
        let height = self.container.bounds.height
        AppDelegate.sharedInstance.resizeWindowHeight(height, animated: true)
        
        self.updateUI()
    }
    // MARK: State
    
    private func updateStateUI()
    {
        switch self.state
        {
        case .error(let message):
            self.errorLabel.isHidden = false
            self.errorLabel.stringValue = message
            
            self.exchangeButton.isEnabled = false
            
            self.minerFeeLabel.isHidden = true
            self.recipientAmountLabel.isHidden = true
            self.minerFeeHelpButton.isHidden = true
        default:
            self.errorLabel.isHidden = true
            
            self.exchangeButton.isEnabled = true
            
            self.minerFeeLabel.isHidden = false
            self.recipientAmountLabel.isHidden = false
            self.minerFeeHelpButton.isHidden = false
        }
    }
    
    private func updateUI()
    {
        let sourceAccount = self.viewModel.account(at: self.sourceAccountPopupButton.indexOfSelectedItem)
        let recipientAccount = self.viewModel.account(at: self.recipientAccountPopupButton.indexOfSelectedItem)
        
        // Update view model
        self.viewModel.sourceAccount = sourceAccount
        self.viewModel.recipientAccount = recipientAccount
        
        // Update UI
        
        
        self.sourceAccountBalanceLabel.stringValue = amountToString(amount: sourceAccount.currentBalance, currency: sourceAccount.currencyType)
        self.recipientAccountBalanceLabel.stringValue = amountToString(amount: recipientAccount.currentBalance, currency: recipientAccount.currencyType)
        
        // Exchange currencies
        let currencyTitles = self.viewModel.sourceCurrencies.map { (currency) -> String in
            return currency.rawValue.uppercased()
        }
        
        self.exchangeAmountCurrencyPopupButton.removeAllItems()
        self.exchangeAmountCurrencyPopupButton.addItems(withTitles: currencyTitles)
        
        // Hide error message
        self.errorLabel.isHidden = true
        
        self.fetchQuote()
    }
    
    private func updateUI(with quote: TransferQuote, transferRequest: TransferRequest)
    {
        // Check that user is trying to transfer between min and max amounts
        if quote.sourceAmount < quote.minimumAmount
        {
            self.state = .error(message: "Minimum amount: \(quote.minimumAmount)")
            return
        }
        else if quote.sourceAmount > quote.maximumAmount
        {
            self.state = .error(message: "Maximum amount: \(quote.maximumAmount)")
            return
        }
        
        // Default state
        self.state = .default
        self.recipientAmountLabel.stringValue = "\(quote.recipientAmount) \(transferRequest.recipientCurrency.rawValue)"
        self.minerFeeLabel.stringValue = "Miner fee: \(quote.minerFee) \(quote.minerFeeCurrency.rawValue.uppercased())"
    }
    
    fileprivate func fetchQuote()
    {
        // Note:
        // Calling self.exchangeAmountTextField.doubleValue/stringValue etc
        // causes the text field to use the formatter to format the text and then
        // replace(!) the text fields content with the value.
        // This makes it impossible to type "1.23", because as soon as the "." is typed
        // the value is reformatted to "1"
        let amountString = self.exchangeAmountTextField.currentEditor()?.string ?? self.exchangeAmountTextField.stringValue
        
        guard let sourceAccount = self.viewModel.sourceAccount,
              let recipientAccount = self.viewModel.recipientAccount,
              let amount = Double(amountString) else
        {
            return
        }

        do
        {
            let transferRequest = try TransferRequest(source: sourceAccount, recipient: recipientAccount, amount: amount)
            self.transferController = TransferController(request: transferRequest)
            self.transferController?.fetchQuote({ [weak self] (quote, error) in
                DispatchQueue.main.async {
                    guard let unwrappedQuote = quote else
                    {
                        if let unwrappedError = error
                        {
                            switch unwrappedError
                            {
                            case TransferOperatorError.unsupportedCurrency(let currency):
                                self?.state = .error(message: "\(currency.rawValue.uppercased()) is not supported")
                            default:()
                            }
                        }
                        
                        return
                    }
                    
                    self?.updateUI(with: unwrappedQuote, transferRequest: transferRequest)
                }
            })
        }
        catch let error as TransferRequest.InitializationError where error == .directTransferUnsupported || error == .exchangeTransferUnsupported
        {
            self.state = .error(message: "Sorry! Transfer not supported")
        }
        catch let error as TransferRequest.InitializationError where error == .sourceAccountDoesNotSupportWithdrawing
        {
            self.state = .error(message: "Source does not support withdrawing")
        }
        catch let error as TransferRequest.InitializationError where error == .recipientAccountDoesNotSupportAccessingCryptoAddress
        {
            self.state = .error(message: "Recipient does not support fetching address")
        }
        catch let error
        {
            // TODO: Handle error
            print(error)
        }
    }
    
    // MARK: Actions

    @objc private func accountSelectionChanged(_ sender: Any)
    {
        self.updateUI()
    }
    
    @objc private func minerFeeHelpButtonClicked(_ sender: Any)
    {
        
    }
    
    @objc private func exchangeButtonClicked(_ sender: Any)
    {
        guard let unwrappedTransferController = self.transferController else
        {
            return
        }
        
        unwrappedTransferController.performTransferRequest { (success, transactionID, error) in
            print(success)
            print(error)
            print(transactionID)
            
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = success ? "Success!" : "Error!"
                alert.informativeText = success ? "\(String(describing: transactionID))" : error.debugDescription
                alert.addButton(withTitle: "Cool!")
                alert.runModal()
            }
        }
    }
    
    @objc private func cancelButtonClicked(_ sender: Any)
    {
        NotificationCenter.postOnMainThread(name: Notifications.ShowTabIndex, object: nil, userInfo: [Notifications.Keys.TabIndex: Tab.accounts.rawValue])
        NotificationCenter.postOnMainThread(name: Notifications.ShowTabs)
    }
}

// MARK: State

fileprivate extension TransferFundsViewController
{
    fileprivate enum State
    {
        case `default`
        case loading(message: String)
        case error(message: String)
        case transferComplete
    }
}

// MARK: NSTextFieldDelegate

extension TransferFundsViewController: NSTextFieldDelegate
{
    override func controlTextDidChange(_ obj: Notification)
    {
        self.fetchQuote()
    }
}
