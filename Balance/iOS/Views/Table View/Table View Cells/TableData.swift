//
//  TableRowData.swift
//  Red Davis
//
//  Created by Red Davis on 10/11/2016.
//  Copyright © 2016 Red Davis. All rights reserved.
//

import UIKit


// MARK: TableSection

struct TableSection
{
    let title: String?
    var rows: [TableRow]
}


// MARK: TableRow

struct TableRow
{
    // Internal
    typealias CellPreparationHandler = (_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell
    typealias ActionHandler = (_ indexPath: IndexPath) -> Void
    typealias DeletionHandler = (_ indexPath: IndexPath) -> Void
    
    let cellPreparationHandler: CellPreparationHandler
    var actionHandler: ActionHandler?
    var deletionHandler: DeletionHandler?
    
    var isDeletable: Bool {
        return self.deletionHandler != nil
    }
    
    // MARK: Initialization
    
    init(cellPreparationHandler: @escaping CellPreparationHandler)
    {
        self.cellPreparationHandler = cellPreparationHandler
    }
}
