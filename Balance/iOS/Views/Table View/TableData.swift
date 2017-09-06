//
//  TableRowData.swift
//  Red Davis
//
//  Created by Red Davis on 10/11/2016.
//  Copyright © 2016 Red Davis. All rights reserved.
//

import UIKit


// MARK: TableSection

internal struct TableSection
{
    let title: String?
    let rows: [TableRow]
}


// MARK: TableRow

internal struct TableRow
{
    // Internal
    typealias CellPreparationHandler = (_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell
    typealias ActionHandler = (_ indexPath: IndexPath) -> Void
    
    internal let cellPreparationHandler: CellPreparationHandler
    internal var actionHandler: ActionHandler?
    
    // MARK: Initialization
    
    internal init(cellPreparationHandler: @escaping CellPreparationHandler)
    {
        self.cellPreparationHandler = cellPreparationHandler
    }
}
