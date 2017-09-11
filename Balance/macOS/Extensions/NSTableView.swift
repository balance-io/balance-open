//
//  NSTableView.swift
//  Bal
//
//  Created by Benjamin Baron on 5/23/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import AppKit

extension NSTableView {
    var visibleRows: Range<Int>? {
        return Range(rows(in: visibleRect))
    }
}
