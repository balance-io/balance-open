//
//  SectionedTableView.swift
//  Bal
//
//  Created by Benjamin Baron on 8/9/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import AppKit

@objc protocol SectionedTableViewDelegate {
    @objc optional func tableView(_ tableView: SectionedTableView, hoveredIndex: TableIndex, lastHoveredIndex: TableIndex)
    @objc optional func tableView(_ tableView: SectionedTableView, clickedRow row: Int, inSection section: Int)
    @objc optional func tableView(_ tableView: SectionedTableView, selectionWillChange selectedIndex: TableIndex)
    @objc optional func tableView(_ tableView: SectionedTableView, selectionDidChange selectedIndex: TableIndex)
    
    // Section support
    @objc optional func tableView(_ tableView: SectionedTableView, clickedSection section: Int)
    
    // Drag and drop support
    @objc optional func tableView(_ tableView: SectionedTableView, canDragIndex index: TableIndex) -> Bool
    @objc optional func tableView(_ tableView: SectionedTableView, dragImageForProposedDragImage dragImage: NSImage, index: TableIndex) -> NSImage
    @objc optional func tableView(_ tableView: SectionedTableView, validateDropFromIndex fromIndex: TableIndex, toIndex: TableIndex) -> NSDragOperation
    @objc optional func tableView(_ tableView: SectionedTableView, acceptDropFromIndex fromIndex: TableIndex, toIndex: TableIndex, dropOperation: NSTableViewDropOperation) -> Bool
}

@objc protocol SectionedTableViewDataSource {
    func numberOfSectionsInTableView(_ tableView: SectionedTableView) -> Int
    func tableView(_ tableView: SectionedTableView, numberOfRowsInSection section: Int) -> Int
    func tableView(_ tableView: SectionedTableView, heightOfRow row: Int, inSection section: Int) -> CGFloat
    func tableView(_ tableView: SectionedTableView, rowViewForRow row: Int, inSection section: Int) -> NSTableRowView?
    func tableView(_ tableView: SectionedTableView, viewForRow row: Int, inSection section: Int) -> NSView?
    
    // Section support is optional
    @objc optional func tableView(_ tableView: SectionedTableView, heightOfSection section: Int) -> CGFloat
    @objc optional func tableView(_ tableView: SectionedTableView, rowViewForSection section: Int) -> NSTableRowView?
    @objc optional func tableView(_ tableView: SectionedTableView, viewForSection section: Int) -> NSView?
}

// Single column table view that behaves similar to UITableView with sections and rows, optionally supports drag and drop
// NOTE: Do not set the delegate or dataSource, only the custom ones
class SectionedTableView: TableView, NSTableViewDelegate, NSTableViewDataSource {
    weak var customDelegate: SectionedTableViewDelegate?
    weak var customDataSource: SectionedTableViewDataSource?
    
    var displaySectionRows = true
    var displayEmptySectionRows = false
    var isHoveringEnabled = true {
        didSet {
            if !isHoveringEnabled {
                lastHoverRow?.hovering = false
                lastHoverRow = nil
            }
        }
    }
    
    var allowSelectingSections = true
    var allowSelectingRows = true
    var treatSectionsAsGroupRows = true
    
    fileprivate var trackingArea: NSTrackingArea?
    fileprivate var lastHoverRow: HoverTableRowView?
    
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
        self.delegate = self
        self.dataSource = self
        self.register(forDraggedTypes: ["balance.row"])
    }
    
    //
    // MARK: - Helper -
    //
    
    fileprivate func convertRowToIndex(_ row: Int) -> TableIndex {
        guard let customDataSource = customDataSource else {
            return TableIndex.none
        }
        
        if row < 0 {
            return TableIndex.none
        }
        
        if row == 0 {
            if displaySectionRows {
                let rows = customDataSource.tableView(self, numberOfRowsInSection: 0)
                if row == 0 && (displayEmptySectionRows || rows > 0) {
                    return TableIndex(section: 0, row: -1)
                } else if row < 0 {
                    return TableIndex.none
                }
                //return row == 0 ? TableIndex(section: 0, row: -1) : TableIndex.none
            } else {
                return row == 0 ? TableIndex(section: 0, row: 0) : TableIndex.none
            }
        }
        
        let sectionCount = customDataSource.numberOfSectionsInTableView(self)
        if sectionCount > 0 {
            var counter = 0
            for section in 0...sectionCount-1 {
                let rows = customDataSource.tableView(self, numberOfRowsInSection: section)

                if displaySectionRows && (displayEmptySectionRows || rows > 0) {
                    // Add one row for the section
                    counter += 1
                }
                
                // Calculate the row value or iterate the loop
                if counter == row && rows > 0 {
                    return TableIndex(section: section, row: 0)
                } else if row < counter + rows {
                    return TableIndex(section: section, row: (row - counter))
                } else {
                    counter += rows
                }
            }
        }
        
        return TableIndex.none
    }
    
    fileprivate func convertIndexToRow(_ index: TableIndex) -> Int {
        guard let customDataSource = customDataSource else {
            return -1
        }
        
        guard index.section >= 0 && index.section < customDataSource.numberOfSectionsInTableView(self) else {
            // Section doesn't exist
            return -1
        }
        
        guard index.row < customDataSource.tableView(self, numberOfRowsInSection: index.section) else {
            // Row doesn't exist
            return -1
        }
        
        // First section
        if index.section == 0 {
            if displaySectionRows {
                return index.row >= 0 ? index.row + 1 : 0
            } else {
                return index.row >= 0 ? index.row : -1
            }
        }
        
        var counter = 0
        for section in 0...index.section {
            if section < index.section {
                if displaySectionRows {
                    // Add the section row
                    counter += 1
                }
                
                // Add the rows
                let rows = customDataSource.tableView(self, numberOfRowsInSection: section)
                counter += rows
            } else {
                // This is the last section
                if index.row >= 0 {
                    if displaySectionRows {
                        // Add the section row
                        counter += 1
                    }
                    
                    // Add the rows
                    counter += index.row
                }
            }
        }
        
        return counter
    }
    
    //
    // MARK: - Public interface -
    //
    
    var selectedIndex: TableIndex {
        let selectedRow = self.selectedRow
        return convertRowToIndex(selectedRow)
    }
    
    var visibleIndexes: [TableIndex] {
        let rows = self.rows(in: self.visibleRect)
        var visibleIndexes = [TableIndex]()
        if rows.length > 0 {
            for row in rows.location...rows.location+rows.length-1 {
                visibleIndexes.append(convertRowToIndex(row))
            }
        }
        
        return visibleIndexes
    }
    
    func indexAtPoint(_ point: NSPoint) -> TableIndex? {
        let clickedRow = self.row(at: point)
        return convertRowToIndex(clickedRow)
    }
    
    func selectIndex(_ index: TableIndex) {
        let row = convertIndexToRow(index)
        if row >= 0 {
            var indexSet = IndexSet()
            indexSet.insert(row)
            self.selectRowIndexes(indexSet, byExtendingSelection: false)
        }
    }
    
    func deselectIndex(_ index: TableIndex) {
        let row = convertIndexToRow(index)
        if row >= 0 {
            self.deselectRow(row)
        }
    }
    
    func noteHeightOfIndexes(_ indexes: [TableIndex]) {
        let indexSet = NSMutableIndexSet()
        for index in indexes {
            let row = convertIndexToRow(index)
            if row >= 0 {
                indexSet.add(row)
            }
        }
        
        if indexSet.count > 0 {
            self.noteHeightOfRows(withIndexesChanged: indexSet as IndexSet)
        }
    }
    
    func noteHeightOfIndex(_ index: TableIndex) {
        let row = convertIndexToRow(index)
        if row >= 0 {
            self.noteHeightOfRows(withIndexesChanged: IndexSet(integer: row))
        }
    }
    
    func rowViewAtIndex(_ index: TableIndex, makeIfNecessary: Bool) -> NSTableRowView? {
        let row = convertIndexToRow(index)
        if row >= 0 {
            return rowView(atRow: row, makeIfNecessary: makeIfNecessary)
        }
        return nil
    }
    
    func viewAtIndex(_ index: TableIndex, makeIfNecessary: Bool) -> NSView? {
        let row = convertIndexToRow(index)
        if row >= 0 {
            return self.view(atColumn: 0, row: row, makeIfNecessary: makeIfNecessary)
        }
        return nil
    }
    
    func scrollIndexToVisible(_ index: TableIndex) {
        let row = convertIndexToRow(index)
        if row >= 0 {
            return self.scrollRowToVisible(row)
        }
    }
    
    // NOTE: Make sure to use beginUpdates/endUpdates so that the table row count cache gets updated
    func moveRowAtTableIndex(_ fromIndex: TableIndex, toIndex: TableIndex) {
        let fromRow = convertIndexToRow(fromIndex)
        let toRow = convertIndexToRow(toIndex)
        if fromRow >= 0 && toRow >= 0 {
            self.moveRow(at: fromRow, to: toRow)
        }
    }
    
    //
    // MARK: - Click support -
    //
    
    override func mouseDown(with theEvent: NSEvent) {
        let globalLocation = theEvent.locationInWindow
        let localLocation = self.convert(globalLocation, from: nil)
        
        super.mouseDown(with: theEvent)
        
        if let clickedIndex = self.indexAtPoint(localLocation) {
            if clickedIndex.row >= 0 {
                customDelegate?.tableView?(self, clickedRow: clickedIndex.row, inSection: clickedIndex.section)
            } else {
                customDelegate?.tableView?(self, clickedSection: clickedIndex.section)
            }
        }
    }
    
    //
    // MARK: - Hover support -
    //
    
    fileprivate func changeHoverRow(_ hoverRow: HoverTableRowView?) {
        guard isHoveringEnabled else {
            return
        }
        
        if hoverRow != lastHoverRow {
            hoverRow?.hovering = true
            lastHoverRow?.hovering = false
            
            // Inform delegate
            if let hoverRowFunc = customDelegate?.tableView(_:hoveredIndex:lastHoveredIndex:) {
                let hoveredRow = (hoverRow == nil ? -1 : self.row(for: hoverRow!))
                let hoveredIndex = convertRowToIndex(hoveredRow)
                
                let lastHoveredRow = (lastHoverRow == nil ? -1 : self.row(for: lastHoverRow!))
                let lastHoveredIndex = convertRowToIndex(lastHoveredRow)
                
                hoverRowFunc(self, hoveredIndex, lastHoveredIndex)
            }
        }
        
        lastHoverRow = hoverRow
    }
    
    fileprivate func hoverRowForPoint(_ point: NSPoint) -> HoverTableRowView? {
        let row = self.row(at: point)
        let index = convertRowToIndex(row)
        if index.row >= 0 {
            return self.rowView(atRow: row, makeIfNecessary: false) as? HoverTableRowView
        } else {
            return nil
        }
    }
    
    // MARK: Scrollview did scroll notification
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        // We need to add the notification here because the super implemenation appears to remove all notifications
        if let clipView = self.superview as? NSClipView {
            registerForScrollingNotification(clipView: clipView)
        }
    }
    
    override func viewWillMove(toSuperview newSuperview: NSView?) {
        super.viewWillMove(toSuperview: newSuperview)
        
        if let oldClipView = self.superview as? NSClipView {
            unregisterForScrollingNotification(clipView: oldClipView)
        }
    }
    
    fileprivate func registerForScrollingNotification(clipView: NSClipView) {
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(boundsDidChange(_:)), name: Notification.Name.NSViewBoundsDidChange, object: clipView)
    }
    
    fileprivate func unregisterForScrollingNotification(clipView: NSClipView) {
        NotificationCenter.removeObserverOnMainThread(self, name: Notification.Name.NSViewBoundsDidChange, object: clipView)
    }
    
    @objc fileprivate func boundsDidChange(_ notification: Notification) {
        let locationInScreen = NSEvent.mouseLocation()
        if let locationInWindow = self.window?.convertFromScreen(NSRect(origin: locationInScreen, size: CGSize(width: 1, height: 1))) {
            let locationInSelf = self.convert(locationInWindow.origin, from: nil)
            let hoverRow = hoverRowForPoint(locationInSelf)
            changeHoverRow(hoverRow)
        }
    }
    
    // MARK: Mouse tracking
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if trackingArea == nil {
            trackingArea = NSTrackingArea(rect: NSZeroRect,
                                          options: [.inVisibleRect, .activeAlways, .mouseEnteredAndExited, .mouseMoved],
                                          owner: self,
                                          userInfo: nil)
        }
        if let trackingArea = trackingArea, !self.trackingAreas.contains(trackingArea) {
            self.addTrackingArea(trackingArea)
        }
    }
    
    override func mouseEntered(with theEvent: NSEvent) {
        handleMouseEvent(theEvent)
    }
    
    override func mouseMoved(with theEvent: NSEvent) {
        handleMouseEvent(theEvent)
    }
    
    override func mouseExited(with theEvent: NSEvent) {
        handleMouseEvent(theEvent)
    }
    
    fileprivate func handleMouseEvent(_ event: NSEvent) {
        let locationInSelf = self.convert(event.locationInWindow, from: nil)
        let hoverRow = hoverRowForPoint(locationInSelf)
        changeHoverRow(hoverRow)
    }
    
    // MARK: - Original Delegate and Datasource passthrough -
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if let customDataSource = customDataSource {
            let numberOfSections = customDataSource.numberOfSectionsInTableView(self)
            if numberOfSections > 0 {
                var totalRows = displaySectionRows ? numberOfSections : 0
                for i in 0...numberOfSections-1 {
                    let numberOfRows = customDataSource.tableView(self, numberOfRowsInSection: i)
                    totalRows += numberOfRows
                    
                    if displaySectionRows && !displayEmptySectionRows {
                        // Subtract empty section rows
                        if numberOfRows == 0 {
                            totalRows -= 1
                        }
                    }
                }
                return totalRows
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if let customDataSource = customDataSource {
            let index = convertRowToIndex(row)
            if index.row >= 0 {
                return customDataSource.tableView(self, heightOfRow: index.row, inSection: index.section)
            } else {
                if let height = customDataSource.tableView?(self, heightOfSection: index.section) {
                    return height
                }
            }
        }
        
        return 0.01
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        if let customDataSource = customDataSource {
            let index = convertRowToIndex(row)
            if index.row >= 0 {
                return customDataSource.tableView(self, rowViewForRow: index.row, inSection: index.section)
            } else {
                if let rowView = customDataSource.tableView?(self, rowViewForSection: index.section) {
                    return rowView
                }
            }
        }
        
        return nil
    }
    
    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        guard treatSectionsAsGroupRows else {
            return false
        }
        
        let index = convertRowToIndex(row)
        return index.isSection
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let customDataSource = customDataSource {
            let index = convertRowToIndex(row)
            if index.row >= 0 {
                return customDataSource.tableView(self, viewForRow: index.row, inSection: index.section)
            } else if index.section >= 0 {
                if let view = customDataSource.tableView?(self, viewForSection: index.section) {
                    return view
                }
            }
        }
        
        return nil
    }
    
    func tableView(_ tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet) -> IndexSet {
        var selectionIndexes = proposedSelectionIndexes
        for index in proposedSelectionIndexes {
            let sectionIndex = convertRowToIndex(index)
            if (sectionIndex.isSection && !allowSelectingSections) || (sectionIndex.isRow && !allowSelectingRows) {
                selectionIndexes.remove(index)
            }
        }
        
        var index = TableIndex.none
        if let firstRow = selectionIndexes.first {
            index = convertRowToIndex(firstRow)
        }
        customDelegate?.tableView?(self, selectionWillChange: index)
        
        return selectionIndexes
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        customDelegate?.tableView?(self, selectionDidChange: self.selectedIndex)
    }
    
    // MARK: Rearranging
    
    override func canDragRows(with rowIndexes: IndexSet, at mouseDownPoint: NSPoint) -> Bool {
        if let customDelegate = customDelegate {
            // Only support one row dragging right now
            let row = rowIndexes.first
            let index = convertRowToIndex(row!)
            if index != TableIndex.none {
                if let canDrag = customDelegate.tableView?(self, canDragIndex: index) {
                    return canDrag
                }
            }
        }
        
        return false
    }
    
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let item = NSPasteboardItem()
        item.setString(String(row), forType: "balance.row")
        return item
    }
    
    fileprivate func indexFromDraggingInfo(_ info: NSDraggingInfo) -> TableIndex? {
        var returnRow: Int?
        info.enumerateDraggingItems(options: [], for: self, classes: [NSPasteboardItem.self], searchOptions: [:]) {
            if let item = $0.0.item as? NSPasteboardItem, let rowString = item.string(forType: "balance.row"), let row = Int(rowString) {
                returnRow = row
            }
        }
        
        if let returnRow = returnRow {
            let returnIndex = convertRowToIndex(returnRow)
            if returnIndex.section >= 0 {
                return returnIndex
            }
        }
        
        return nil
    }
    
    // Currently only supporting one drag item
    func tableView(_ tableView: NSTableView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forRowIndexes rowIndexes: IndexSet) {
        session.enumerateDraggingItems(options: [], for: self, classes: [NSPasteboardItem.self], searchOptions: [:]) { draggingItem, idx, stop in
            if let imageComponent = draggingItem.imageComponents?.first, let image = imageComponent.contents as? NSImage {
                draggingItem.imageComponentsProvider = {
                    if let imageFunc = self.customDelegate?.tableView(_:dragImageForProposedDragImage:index:) {
                        let index = self.convertRowToIndex(rowIndexes.first!)
                        let finalImage = imageFunc(self, image, index)
                        
                        var origin = CGPoint.zero
                        origin.y = image.size.height - finalImage.size.height
                        imageComponent.frame = NSRect(origin: origin, size: finalImage.size)
                        imageComponent.contents = finalImage
                        return [imageComponent]
                    } else {
                        imageComponent.contents = image.alphaImage(0.35)
                        return [imageComponent]
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        if dropOperation == .above, let customDelegate = customDelegate {
            if let fromIndex = indexFromDraggingInfo(info) {
                // Because we need to allow dragging to the end of the table (i.e. one row past the end),
                // we need to specifically check for that, otherwise we'll return TableIndex.none
                let totalRows = self.numberOfRows
                var toIndex = TableIndex.none
                if row == totalRows {
                    // This is at the end of the table, so get the last index and use the next section index
                    toIndex = convertRowToIndex(row - 1)
                    if toIndex != TableIndex.none {
                        toIndex.section += 1
                        toIndex.row = -1
                    }
                } else {
                    // Inside the table, so just return the index
                    toIndex = convertRowToIndex(row)
                }
                
                if toIndex.section >= 0 {
                    if let dragOperation = customDelegate.tableView?(self, validateDropFromIndex: fromIndex, toIndex: toIndex) {
                        return dragOperation
                    }
                }
            }
        }
        
        return NSDragOperation()
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        if let customDelegate = customDelegate {
            if let fromIndex = indexFromDraggingInfo(info) {
                // Because we need to allow dragging to the end of the table (i.e. one row past the end),
                // we need to specifically check for that, otherwise we'll return TableIndex.none
                let totalRows = self.numberOfRows
                var toIndex = TableIndex.none
                if row == totalRows {
                    // This is at the end of the table, so get the last index and use the next section index
                    toIndex = convertRowToIndex(row - 1)
                    if toIndex != TableIndex.none {
                        toIndex.section += 1
                        toIndex.row = -1
                    }
                } else {
                    // Inside the table, so just return the index
                    toIndex = convertRowToIndex(row)
                }
                
                if toIndex.section >= 0 {
                    if let accepted = customDelegate.tableView?(self, acceptDropFromIndex: fromIndex, toIndex: toIndex, dropOperation: dropOperation) {
                        return accepted
                    }
                }
            }
        }
        
        return false
    }
}

// MARK: - TableIndex -

@objc class TableIndex: NSObject {
    static let none = TableIndex(section: -1, row: -1)
    
    var section: Int
    var row: Int
    
    var isSection: Bool {
        return section >= 0 && row == -1
    }
    
    var isRow: Bool {
        return section >= 0 && row >= 0
    }
    
    init(section: Int, row: Int) {
        self.section = section
        self.row = row
    }
    
    override var description: String {
        return "(section: \(section), row: \(row))"
    }
}

func ==(lhs: TableIndex, rhs: TableIndex) -> Bool {
    return lhs.section == rhs.section && lhs.row == rhs.row
}

func !=(lhs: TableIndex, rhs: TableIndex) -> Bool {
    return !(lhs == rhs)
}

func <(lhs: TableIndex, rhs: TableIndex) -> Bool {
    if lhs.section < rhs.section {
        return true
    } else if lhs.section == rhs.section {
        return lhs.row < rhs.row
    }
    return false
}

func >(lhs: TableIndex, rhs: TableIndex) -> Bool {
    if lhs.section > rhs.section {
        return true
    } else if lhs.section == rhs.section {
        return lhs.row > rhs.row
    }
    return false
}

func <=(lhs: TableIndex, rhs: TableIndex) -> Bool {
    return lhs < rhs || lhs == rhs
}

func >=(lhs: TableIndex, rhs: TableIndex) -> Bool {
    return lhs > rhs || lhs == rhs
}
