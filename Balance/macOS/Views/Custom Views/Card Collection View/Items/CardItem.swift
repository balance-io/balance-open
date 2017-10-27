//
//  CardItem.swift
//  CardCollectionViewLayout
//
//  Created by Red Davis on 26/10/2017.
//  Copyright © 2017 Red Davis LTD. All rights reserved.
//

import Cocoa


final class CardItem: NSCollectionViewItem, Reusable {
    var expandedContentHeight: CGFloat {
        return 500.0
    }
    
    var closedContentHeight: CGFloat {
        return 150.0
    }
    
    // MARK: View lifecycle

    override func loadView() {
        self.view = NSView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.wantsLayer = true
        self.view.layer?.masksToBounds = true
        self.view.layer?.cornerRadius = 10.0
    }
}
