//
//  TableView.swift
//  Bal
//
//  Created by Benjamin Baron on 6/7/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import AppKit

class TableView: NSTableView {
    
    //
    // MARK: - Lifecycle -
    //
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        self.wantsLayer = true
        self.addTableColumn(NSTableColumn(identifier: "main"))
        
        self.backgroundColor = NSColor.clear
        self.headerView = nil
        self.allowsEmptySelection = true
        self.allowsColumnReordering = false
        self.allowsColumnResizing = false
        self.allowsColumnSelection = false
        self.allowsMultipleSelection = false
        self.focusRingType = .none
    }
    
    //
    // MARK: - Animate Update Rows -
    //
    
    // Note: Using NSArrays here because Swift array's indexOf method is extremely slow when optimizations are
    // turned off, aka in Debug builds
    func updateRows(oldObjects: NSArray, newObjects: NSArray, animationOptions: NSTableViewAnimationOptions, referenceEquality: Bool = true) {
        do {
            self.beginUpdates()
            
            let oldSortedArray = oldObjects.mutableCopy() as! NSMutableArray
            
            // Remove any removed objects
            var oldIndex = oldObjects.count - 1
            for object in oldObjects.reversed() {
                let newIndex = referenceEquality ? newObjects.indexOfObjectIdentical(to: object) : newObjects.index(of: object)
                if newIndex == NSNotFound {
                    oldSortedArray.removeObject(at: oldIndex)
                    try ObjC.catchException {
                        self.removeRows(at: IndexSet(integer: oldIndex), withAnimation: animationOptions)
                    }
                }
                
                oldIndex -= 1
            }
            
            // Add any new objects to the end
            var endIndex = oldSortedArray.count
            for object in newObjects {
                let oldIndex = referenceEquality ? oldSortedArray.indexOfObjectIdentical(to: object) : oldSortedArray.index(of: object)
                if oldIndex == NSNotFound {
                    oldSortedArray.add(object)
                    try ObjC.catchException {
                        self.insertRows(at: IndexSet(integer: endIndex), withAnimation: animationOptions)
                    }
                    
                    endIndex += 1
                }
            }
            
            assert(oldSortedArray.count == newObjects.count, "Array counts do not match!")
            
            // Now that the arrays are equal in length, finally move any rows as needed
            var newIndex = 0
            for object in newObjects {
                let oldIndex = referenceEquality ? oldSortedArray.indexOfObjectIdentical(to: object) : oldSortedArray.index(of: object)
                if oldIndex != newIndex {
                    oldSortedArray.removeObject(at: oldIndex)
                    oldSortedArray.insert(object, at: newIndex)
                    
                    try ObjC.catchException {
                        self.moveRow(at: oldIndex, to: newIndex)
                    }
                }
                newIndex += 1
            }
            
            self.endUpdates()
        } catch {
            log.severe("Failed to update rows: \(error)")
            self.endUpdates()
            self.reloadData()
        }
    }
}
