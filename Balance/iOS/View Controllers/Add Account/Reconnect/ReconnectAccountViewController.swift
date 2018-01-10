//
//  ReconnectAccountViewController.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 1/9/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import UIKit
import SnapKit

class ReconnectAccountViewController: UIViewController {

    private weak var dismissButton: UIButton?
    private weak var invalidAccountsView: UIView?
    private weak var invalidAccountsTableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpView()
        registerCells()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}

//mark: Setup UI
private extension ReconnectAccountViewController {
    
    func setUpView() {
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
    
    @objc func dismiss(sender: UIButton) {
        dismiss(animated: true)
    }
    
}

private extension UIView {
    
    static var deviceWidth: CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    static var deviceHeight: CGFloat {
        return UIScreen.main.bounds.size.height
    }
    
    static func getHorizontalSize(with percentage: Float) -> CGFloat {
        guard percentage > 0, percentage < 100 else {
            return 0
        }
        
        return (deviceWidth / 100.0) * CGFloat(percentage)
    }
    
    static func getVerticalSize(with percentage: Float) -> CGFloat {
        guard percentage > 0, percentage < 100 else {
            return 0
        }
        
        return (deviceHeight / 100.0) * CGFloat(percentage)
    }
    
}

extension ReconnectAccountViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReconnectAccountCell.cellIdentifier) else {
            return UITableViewCell()
        }
        
        cell.backgroundColor = UIColor.red
        
        return cell
    }
    
}
