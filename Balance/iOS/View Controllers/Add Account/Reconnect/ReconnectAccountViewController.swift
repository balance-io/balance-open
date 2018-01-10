//
//  ReconnectAccountViewController.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 1/9/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import UIKit
import SVProgressHUD
import RxSwift
import RxCocoa
import SnapKit

class ReconnectAccountViewController: UIViewController {

    private weak var dismissButton: UIButton?
    private weak var invalidAccountsView: UIView?
    private weak var invalidAccountsTableView: UITableView?
    
    private let viewModel: ReconnectAccountViewModel
    private let disposeBag = DisposeBag()
    
    required init(viewModel: ReconnectAccountViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        createUI()
        registerCells()
        bindViewStates()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}

//mark: Create UI
private extension ReconnectAccountViewController {
    
    func createUI() {
        addDismissButton()
        createInvalidAccountsView()
        createInvalidAccountsTableView()
    }
    
    func addDismissButton() {
        let dismissButton = UIButton()
        dismissButton.addTarget(self,
                                action: #selector(dismiss),
                                for: .touchUpInside)
        
        view.addSubview(dismissButton)
        dismissButton.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        self.dismissButton = dismissButton
    }
    
    func createInvalidAccountsView() {
        let invalidAccountsView = UIView(frame: .zero)
        view.addSubview(invalidAccountsView)
        
        invalidAccountsView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.centerY)
            make.leading.equalToSuperview().offset(UIView.getHorizontalSize(with: 10))
            make.trailing.equalToSuperview().offset(-UIView.getHorizontalSize(with: 10))
            make.bottom.equalToSuperview().offset(-UIView.getHorizontalSize(with: 10))
        }
        
        invalidAccountsView.backgroundColor = UIColor.yellow
        
        self.invalidAccountsView = invalidAccountsView
    }
    
    func createInvalidAccountsTableView() {
        guard let invalidAccountsView = invalidAccountsView else {
            return
        }
        
        let invalidAccountsTableView = UITableView(frame: .zero)
        invalidAccountsView.addSubview(invalidAccountsTableView)
        
        invalidAccountsTableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        invalidAccountsTableView.tableFooterView = UIView(frame: .zero)
        invalidAccountsTableView.backgroundColor = UIColor.cyan
        invalidAccountsTableView.delegate = self
        invalidAccountsTableView.dataSource = self
        
        self.invalidAccountsTableView = invalidAccountsTableView
    }
    
}

//mark: Utils methods
private extension ReconnectAccountViewController {
    
    func registerCells() {
        invalidAccountsTableView?.register(ReconnectAccountCell.self,
                                           forCellReuseIdentifier: ReconnectAccountCell.cellIdentifier)
    }
    
    func bindViewStates() {
        viewModel
            .reconnectAccountViewModelState.drive(onNext: { [weak self] state in
                guard let `self` = self else {
                    return
                }
                
                switch state {
                case .validationWasFailed(let index, let message):
                    self.finishValidation(succeeded: false, at: index, with: message)
                case .validationWasSucceeded(let index, let message):
                    self.finishValidation(succeeded: true, at: index, with: message)
                case .validating(let index):
                    self.startValidation(at: index)
                default:
                    return
                }
            }).disposed(by: disposeBag)
    }
    
    func startValidation(at index: Int, with message: String? = nil) {
        let indexPaths = [IndexPath(row: index, section: 0)]

        invalidAccountsTableView?.reloadRows(at: indexPaths, with: .automatic)
    }
    
    func finishValidation(succeeded: Bool, at index: Int, with message: String? = nil) {
        let indexPaths = [IndexPath(row: index, section: 0)]
        
        if succeeded {
            guard viewModel.totalReconnectAccounts > 0 else {
                dismiss(animated: true)
                return
            }
            
            invalidAccountsTableView?.deleteRows(at: indexPaths, with: .automatic)
            return
        }
        
        invalidAccountsTableView?.reloadRows(at: indexPaths, with: .automatic)
    }
    
    @objc func dismiss(sender: UIButton) {
        dismiss(animated: true)
    }
    
}

extension ReconnectAccountViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.totalReconnectAccounts
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReconnectAccountCell.cellIdentifier) as? ReconnectAccountCell else {
            return UITableViewCell()
        }
        
        if let reconnectAccount = viewModel.reconnectAccount(at: indexPath.row) {
            cell.update(with: reconnectAccount)
            cell.delegate = self
        }
        
        return cell
    }
    
}

extension ReconnectAccountViewController: ReconnectDelegate {
    
    func didTapReconnect(cell: ReconnectAccountCell) {
        guard let index = invalidAccountsTableView?.indexPath(for: cell) else {
            print("Can't trigger reconnect action on cell")
            return
        }
        
        viewModel.reconnect(at: index.row)
    }
    
}
