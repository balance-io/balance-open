//
//  InsightsTabTouchBar.swift
//  Bal
//
//  Created by Benjamin Baron on 5/22/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

@available(OSX 10.12.2, *)
fileprivate extension NSTouchBarItem.Identifier {
    static let displayMode = NSTouchBarItem.Identifier("software.balanced.balancemac.displayMode")
    static let rangeMode = NSTouchBarItem.Identifier("software.balanced.balancemac.rangeMode")
}

@available(OSX 10.12.2, *)
extension InsightsTabViewController: NSTouchBarDelegate, NSScrubberDelegate, NSScrubberDataSource, NSScrubberFlowLayoutDelegate {
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.defaultItemIdentifiers = [.displayMode, .rangeMode]
        return touchBar
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        let item = NSCustomTouchBarItem(identifier: identifier)
        
        if identifier == .displayMode {
            let displayModeStrings = InsightsTabViewModel.DisplayMode.displayModeStrings()
            
            let segmentControl = NSSegmentedControl()
            segmentControl.font = CurrentTheme.defaults.touchBarFont
            segmentControl.segmentCount = displayModeStrings.count
            segmentControl.segmentStyle = .rounded
            segmentControl.target = self
            segmentControl.action = #selector(touchBarChangeDisplayMode(_:))
            item.view = segmentControl
            
            for (index, name) in displayModeStrings.enumerated() {
                segmentControl.setLabel(name, forSegment: index)
            }
            segmentControl.setSelected(true, forSegment: viewModel.displayMode.rawValue)
        } else if identifier == .rangeMode {
            //            let rangeModeStrings = displayMode == .topMerchants ? TopMerchantsRange.strings() : NewMerchantsRange.strings()
            //
            //            let segmentControl = NSSegmentedControl()
            //            segmentControl.segmentCount = rangeModeStrings.count
            //            segmentControl.segmentStyle = .rounded
            //            segmentControl.target = self
            //            segmentControl.action = #selector(touchBarChangeRangeMode(_:))
            //            item.view = segmentControl
            //
            //            for (index, name) in rangeModeStrings.enumerated() {
            //                segmentControl.setLabel(name, forSegment: index)
            //            }
            //
            //            let segmentIndex = displayMode == .topMerchants ? topMerchantsRange.rawValue : newMerchantsRange.rawValue
            //            segmentControl.setSelected(true, forSegment: segmentIndex)
            
            let scrubber = NSScrubber()
            scrubber.register(NSScrubberTextItemView.self, forItemIdentifier: NSUserInterfaceItemIdentifier(rawValue: "range"))
            scrubber.scrubberLayout = NSScrubberFlowLayout()
            scrubber.mode = .free
            scrubber.selectionBackgroundStyle = .roundedBackground
            scrubber.showsAdditionalContentIndicators = true
            scrubber.delegate = self
            scrubber.dataSource = self
            
            let scrubberItem = NSCustomTouchBarItem(identifier: identifier)
            scrubberItem.view = scrubber
            
            return scrubberItem
        }
        
        return item
    }
    
    @objc fileprivate func touchBarChangeDisplayMode(_ sender: NSSegmentedControl) {
        modeSegmentedControl.selectedSegment = sender.selectedSegment
        displayModeChanged(modeSegmentedControl)
    }
    
    @objc fileprivate func touchBarChangeRangeMode(_ sender: NSSegmentedControl) {
        rangePopUpButton.selectItem(at: sender.selectedSegment)
        rangeChanged(rangePopUpButton)
    }
    
    // MARK: Scrubber
    
    func numberOfItems(for scrubber: NSScrubber) -> Int {
        return viewModel.displayMode == .topMerchants ? InsightsTabViewModel.TopMerchantsRange.strings().count : InsightsTabViewModel.NewMerchantsRange.strings().count
    }
    
    func scrubber(_ scrubber: NSScrubber, viewForItemAt index: Int) -> NSScrubberItemView {
        let strings = viewModel.displayMode == .topMerchants ? InsightsTabViewModel.TopMerchantsRange.strings() : InsightsTabViewModel.NewMerchantsRange.strings()
        if let itemView = scrubber.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "range"), owner: nil) as? NSScrubberTextItemView {
            itemView.textField.stringValue = strings[index]
            return itemView
        }
        return NSScrubberItemView()
    }
    
    func scrubber(_ scrubber: NSScrubber, layout: NSScrubberFlowLayout, sizeForItemAt itemIndex: Int) -> NSSize {
        let strings = viewModel.displayMode == .topMerchants ? InsightsTabViewModel.TopMerchantsRange.strings() : InsightsTabViewModel.NewMerchantsRange.strings()
        let name = strings[itemIndex]
        return NSSize(width: name.length * 12, height: 30)
    }
    
    func scrubber(_ scrubber: NSScrubber, didSelectItemAt index: Int) {
        rangePopUpButton.selectItem(at: index)
        rangeChanged(rangePopUpButton)
    }
}
