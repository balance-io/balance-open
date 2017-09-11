//
//  TransactionsTabTouchbar.swift
//  Bal
//
//  Created by Benjamin Baron on 5/22/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation
import JMSRangeSlider

@available(OSX 10.12.2, *)
fileprivate extension NSTouchBar.CustomizationIdentifier {
    static var main = NSTouchBar.CustomizationIdentifier("software.balanced.balancemac.mainBar")
    static var accounts = NSTouchBar.CustomizationIdentifier("software.balanced.balancemac.accountsBar")
    static var categories = NSTouchBar.CustomizationIdentifier("software.balanced.balancemac.categoriesBar")
    static var time = NSTouchBar.CustomizationIdentifier("software.balanced.balancemac.timeBar")
    static var amount = NSTouchBar.CustomizationIdentifier("software.balanced.balancemac.amountBar")
}

@available(OSX 10.12.2, *)
fileprivate extension NSTouchBarItem.Identifier {
    static var accountsPopover = NSTouchBarItem.Identifier("software.balanced.balancemac.accountsPopover")
    static var categoriesPopover = NSTouchBarItem.Identifier("software.balanced.balancemac.categoriesPopover")
    static var timePopover = NSTouchBarItem.Identifier("software.balanced.balancemac.timePopover")
    static var amountPopover = NSTouchBarItem.Identifier("software.balanced.balancemac.amountPopover")
    
    static var accountsScrollView = NSTouchBarItem.Identifier("software.balanced.balancemac.accountsScrollView")
    static var categoriesScrubber = NSTouchBarItem.Identifier("software.balanced.balancemac.categoriesScrubber")
    static var timeScrubber = NSTouchBarItem.Identifier("software.balanced.balancemac.timeScrubber")
    static var amountOverLabel = NSTouchBarItem.Identifier("software.balanced.balancemac.amountOverLabel")
    static var amountRangeSlider = NSTouchBarItem.Identifier("software.balanced.balancemac.amountRangeSlider")
    static var amountUnderLabel = NSTouchBarItem.Identifier("software.balanced.balancemac.amountUnderSlider")
}

@available(OSX 10.12.2, *)
extension TransactionsTabViewController : NSTouchBarDelegate, NSScrubberDelegate, NSScrubberDataSource, NSScrubberFlowLayoutDelegate {
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier = .main
        touchBar.defaultItemIdentifiers = [.accountsPopover, .timePopover, .categoriesPopover, .amountPopover]
        return touchBar
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        if touchBar.customizationIdentifier == .main {
            return createTopLevelItem(identifier: identifier)
        } else {
            return createSubItem(touchBar: touchBar, identifier: identifier)
        }
    }
    
    fileprivate func createTopLevelItem(identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        if identifier == .accountsPopover {
            let popoverItem = NSPopoverTouchBarItem(identifier: identifier)
            touchBarUpdatePopoverItem(popoverItem, isCreation: true)
            
            let popoverTouchBar = NSTouchBar()
            popoverTouchBar.delegate = self
            popoverTouchBar.customizationIdentifier = .accounts
            popoverTouchBar.defaultItemIdentifiers = [.accountsScrollView]
            
            popoverItem.popoverTouchBar = popoverTouchBar
            return popoverItem
        } else if identifier == .categoriesPopover {
            let popoverItem = NSPopoverTouchBarItem(identifier: identifier)
            touchBarUpdatePopoverItem(popoverItem, isCreation: true)
            
            let popoverTouchBar = NSTouchBar()
            popoverTouchBar.delegate = self
            popoverTouchBar.customizationIdentifier = .categories
            
            // Add scrubber
            popoverTouchBar.defaultItemIdentifiers = [.categoriesScrubber]
            
            popoverItem.popoverTouchBar = popoverTouchBar
            return popoverItem
        } else if identifier == .timePopover {
            let popoverItem = NSPopoverTouchBarItem(identifier: identifier)
            touchBarUpdatePopoverItem(popoverItem, isCreation: true)
            
            let popoverTouchBar = NSTouchBar()
            popoverTouchBar.delegate = self
            popoverTouchBar.customizationIdentifier = .time
            
            // Add scrubber
            popoverTouchBar.defaultItemIdentifiers = [.timeScrubber]
            
            popoverItem.popoverTouchBar = popoverTouchBar
            return popoverItem
        } else if identifier == .amountPopover {
            let popoverItem = NSPopoverTouchBarItem(identifier: identifier)
            touchBarUpdatePopoverItem(popoverItem, isCreation: true)
            
            let popoverTouchBar = NSTouchBar()
            popoverTouchBar.delegate = self
            popoverTouchBar.customizationIdentifier = .amount
            popoverTouchBar.defaultItemIdentifiers = [.amountOverLabel, .amountRangeSlider, .amountUnderLabel]
            popoverItem.popoverTouchBar = popoverTouchBar
            return popoverItem
        }
        
        return nil
    }
    
    fileprivate func createSubItem(touchBar: NSTouchBar, identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        if touchBar.customizationIdentifier == .accounts {
            let item = NSCustomTouchBarItem(identifier: identifier)
            item.view = TouchBarShared.createAccountButtonsScrollview(target: self, accountButtonAction:  #selector(touchBarSearchAccount(_:)), showAllAccountsButton: true, allAccountsButtonAction: #selector(touchBarSearchAllAccounts(_:)))
            return item
        } else if touchBar.customizationIdentifier == .categories || touchBar.customizationIdentifier == .time {
            let scrubber = NSScrubber()
            scrubber.identifier = NSUserInterfaceItemIdentifier(rawValue: touchBar.customizationIdentifier!.rawValue)
            scrubber.register(NSScrubberTextItemView.self, forItemIdentifier: NSUserInterfaceItemIdentifier(rawValue: touchBar.customizationIdentifier!.rawValue))
            scrubber.scrubberLayout = NSScrubberFlowLayout()
            scrubber.mode = .free
            scrubber.selectionBackgroundStyle = .roundedBackground
            scrubber.showsAdditionalContentIndicators = true
            scrubber.delegate = self
            scrubber.dataSource = self
            
            let item = NSCustomTouchBarItem(identifier: identifier)
            item.view = scrubber
            
            return item
        } else if touchBar.customizationIdentifier == .amount {
            if identifier == .amountOverLabel {
                touchBarOverLabel = LabelField()
                touchBarOverLabel!.verticalAlignment = .center
                touchBarOverLabel!.alignment = .right
                touchBarOverLabel!.font = CurrentTheme.defaults.touchBarFont
                touchBarOverLabel!.snp.makeConstraints { make in
                    make.width.equalTo(100)
                    make.height.equalTo(30)
                }
                
                let item = NSCustomTouchBarItem(identifier: identifier)
                item.view = touchBarOverLabel!
                return item
            } else if identifier == .amountRangeSlider {
                let itemTuple = JMSRangeSlider.touchBarItem(identifier: identifier, width: 400.0, target: self, action: #selector(touchBarAmountRangeChanged(_:)))
                touchBarRangeSlider = itemTuple.1
                return itemTuple.0
            } else if identifier == .amountUnderLabel {
                touchBarUnderLabel = LabelField()
                touchBarUnderLabel!.verticalAlignment = .center
                touchBarUnderLabel!.alignment = .left
                touchBarUnderLabel!.font = CurrentTheme.defaults.touchBarFont
                touchBarUnderLabel!.snp.makeConstraints { make in
                    make.width.equalTo(100)
                    make.height.equalTo(30)
                }
                
                touchBarUpdateSliderFromSearch(touchBarRangeSlider!)
                
                let item = NSCustomTouchBarItem(identifier: identifier)
                item.view = touchBarUnderLabel!
                return item
            }
        }
        
        return nil
    }
    
    // MARK: Scrubber
    
    func numberOfItems(for scrubber: NSScrubber) -> Int {
        if scrubber.identifier?.rawValue == NSTouchBar.CustomizationIdentifier.categories.rawValue {
            return CategoryRepository.si.allCategoryNames().count + 1
        } else if scrubber.identifier?.rawValue == NSTouchBar.CustomizationIdentifier.time.rawValue {
            return viewModel.times.count
        }
        return 0
    }
    
    func scrubber(_ scrubber: NSScrubber, viewForItemAt index: Int) -> NSScrubberItemView {
        if scrubber.identifier?.rawValue == NSTouchBar.CustomizationIdentifier.categories.rawValue {
            let itemView = NSScrubberItemView()
            let spacing = 10.0
            
            let name = index == 0 ? "All Categories" : CategoryRepository.si.allCategoryNames()[index - 1]
            let image = index == 0 ? #imageLiteral(resourceName: "tb-category") : Category.touchBarImage(forCategory: name)
            let imageSize = image?.size ?? NSZeroSize
            let imageView = NSImageView()
            imageView.image = image
            itemView.addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.width.equalTo(imageSize.width)
                make.height.equalTo(imageSize.height)
                make.centerY.equalToSuperview()
                make.leading.equalToSuperview().offset(spacing)
            }
            
            let nameField = LabelField()
            nameField.verticalAlignment = .center
            nameField.font = CurrentTheme.defaults.touchBarFont
            nameField.stringValue = name
            itemView.addSubview(nameField)
            nameField.snp.makeConstraints { make in
                make.leading.equalTo(imageView.snp.trailing).offset(spacing)
                make.trailing.equalToSuperview()
                make.height.equalToSuperview()
                make.centerY.equalToSuperview()
            }
            
            // Hack to get scrubber selection to update on creation because NSScrubber has a bug and won't respect the selectedItem property on init
            if index == 5 {
                async {
                    if let popoverItem = self.touchBar?.item(forIdentifier: .categoriesPopover) as? NSPopoverTouchBarItem {
                        self.touchBarUpdatePopoverItem(popoverItem)
                    }
                }
            }
            
            return itemView
        } else if scrubber.identifier?.rawValue == NSTouchBar.CustomizationIdentifier.time.rawValue {
            if let itemView = scrubber.makeItem(withIdentifier: scrubber.identifier!, owner: nil) as? NSScrubberTextItemView {
                itemView.textField.stringValue = viewModel.times[index]
                
                // Hack to get scrubber selection to update on creation because NSScrubber has a bug and won't respect the selectedItem property on init
                if index == 4 {
                    async {
                        if let popoverItem = self.touchBar?.item(forIdentifier: .timePopover) as? NSPopoverTouchBarItem {
                            self.touchBarUpdatePopoverItem(popoverItem)
                        }
                    }
                }
                
                return itemView
            }
        }
        
        return NSScrubberItemView()
    }
    
    func scrubber(_ scrubber: NSScrubber, layout: NSScrubberFlowLayout, sizeForItemAt itemIndex: Int) -> NSSize {
        if scrubber.identifier?.rawValue == NSTouchBar.CustomizationIdentifier.categories.rawValue {
            let name = itemIndex == 0 ? "All Categories" : CategoryRepository.si.allCategoryNames()[itemIndex - 1]
            let nameSize = name.size(font: CurrentTheme.defaults.touchBarFont)
            
            let image = itemIndex == 0 ? #imageLiteral(resourceName: "tb-category") : Category.touchBarImage(forCategory: name)
            let imageSize = image?.size ?? NSZeroSize
            
            let spacing: CGFloat = 10.0
            
            return NSSize(width: spacing + imageSize.width + spacing + nameSize.width + spacing, height: 30)
        } else if scrubber.identifier?.rawValue == NSTouchBar.CustomizationIdentifier.time.rawValue {
            let time = viewModel.times[itemIndex]
            return NSSize(width: time.length * 12, height: 30)
        }
        return NSZeroSize
    }
    
    func scrubber(_ scrubber: NSScrubber, didSelectItemAt index: Int) {
        if scrubber.identifier?.rawValue == NSTouchBar.CustomizationIdentifier.categories.rawValue {
            let name = index == 0 ? nil : CategoryRepository.si.allCategoryNames()[index - 1]
            touchBarSearchCategory(name: name)
        } else if scrubber.identifier?.rawValue == NSTouchBar.CustomizationIdentifier.time.rawValue {
            let time = viewModel.times[index]
            touchBarSearchTime(time: time)
        }
    }
    
    // MARK: Actions
    
    @objc fileprivate func touchBarSearchAllAccounts(_ sender: NSButton) {
        viewModel.searchTokens[.in] = nil
        viewModel.searchTokens[.account] = nil
        viewModel.searchTokens[.accountMatches] = nil
        let searchString = Search.createSearchString(forTokens: viewModel.searchTokens)
        performSearch(searchString)
        self.view.window?.makeFirstResponder(self)
        
        touchBarUpdateAllPopoverItems()
        updateSearchFilters()
        if let popoverItem = self.touchBar?.item(forIdentifier: .accountsPopover) as? NSPopoverTouchBarItem {
            popoverItem.dismissPopover(nil)
        }
    }
    
    @objc fileprivate func touchBarSearchAccount(_ sender: NSButton) {
        let institution = InstitutionRepository.si.allInstitutions(sorted: true)[sender.tag]
        viewModel.searchTokens[.in] = nil
        viewModel.searchTokens[.account] = nil
        viewModel.searchTokens[.accountMatches] = institution.name
        let searchString = Search.createSearchString(forTokens: viewModel.searchTokens)
        performSearch(searchString)
        self.view.window?.makeFirstResponder(self)
        
        touchBarUpdateAllPopoverItems()
        updateSearchFilters()
        if let popoverItem = self.touchBar?.item(forIdentifier: .accountsPopover) as? NSPopoverTouchBarItem {
            popoverItem.dismissPopover(nil)
        }
    }
    
    fileprivate func touchBarSearchCategory(name: String?) {
        viewModel.searchTokens[.category] = nil
        viewModel.searchTokens[.categoryMatches] = name
        let searchString = Search.createSearchString(forTokens: viewModel.searchTokens)
        performSearch(searchString)
        self.view.window?.makeFirstResponder(self)
        
        touchBarUpdateAllPopoverItems()
        updateSearchFilters()
        if let popoverItem = self.touchBar?.item(forIdentifier: .categoriesPopover) as? NSPopoverTouchBarItem {
            popoverItem.dismissPopover(nil)
        }
    }
    
    fileprivate func touchBarSearchTime(time: String) {
        viewModel.searchTokens[.before] = nil
        viewModel.searchTokens[.after] = nil
        viewModel.searchTokens[.when] = time == "All Time" ? nil : time
        let searchString = Search.createSearchString(forTokens: viewModel.searchTokens)
        performSearch(searchString)
        self.view.window?.makeFirstResponder(self)
        
        touchBarUpdateAllPopoverItems()
        updateSearchFilters()
        if let popoverItem = self.touchBar?.item(forIdentifier: .timePopover) as? NSPopoverTouchBarItem {
            popoverItem.dismissPopover(nil)
        }
    }
    
    @objc fileprivate func touchBarSearchAmount(_ sender: JMSRangeSlider) {
        let overCents = centsForSliderValue(sliderValue: sender.lowerValue)
        if overCents > viewModel.minTransactionAmount {
            viewModel.searchTokens[.over] = centsToString(overCents, showCents: false)
        } else {
            viewModel.searchTokens[.over] = nil
        }
        
        let underCents = centsForSliderValue(sliderValue: sender.upperValue)
        if underCents < viewModel.maxTransactionAmount {
            viewModel.searchTokens[.under] = centsToString(underCents, showCents: false)
        } else {
            viewModel.searchTokens[.under] = nil
        }
        
        let searchString = Search.createSearchString(forTokens: viewModel.searchTokens)
        performSearch(searchString)
        self.view.window?.makeFirstResponder(self)
        
        touchBarUpdateAllPopoverItems()
        updateSearchFilters()
    }
    
    @objc fileprivate func touchBarAmountRangeChanged(_ sender: JMSRangeSlider) {
        touchBarUpdateRangeLabels(sender: sender)
        rateLimitedSearchAmount(sender: sender)
    }
    
    fileprivate func touchBarUpdateSliderFromSearch(_ slider: JMSRangeSlider) {
        var overCents = viewModel.minTransactionAmount
        if let overToken = viewModel.searchTokens[.over], let cents = stringToCents(overToken), cents > viewModel.minTransactionAmount {
            overCents = cents
        }
        
        var underCents = viewModel.maxTransactionAmount
        if let underToken = viewModel.searchTokens[.under], let cents = stringToCents(underToken), cents < viewModel.maxTransactionAmount {
            underCents = cents
        }
        
        if overCents > underCents {
            overCents = viewModel.minTransactionAmount
            underCents = viewModel.maxTransactionAmount
        }
        
        let lowerValue = sliderValueForCents(cents: overCents)
        let upperValue = sliderValueForCents(cents: underCents)
        if slider.lowerValue != lowerValue || slider.upperValue != upperValue {
            slider.lowerValue = lowerValue
            slider.upperValue = upperValue
        }
        
        touchBarUpdateRangeLabels(sender: slider)
    }
    
    fileprivate func touchBarUpdateRangeLabels(sender: JMSRangeSlider) {
        let overCents = centsForSliderValue(sliderValue: sender.lowerValue)
        let underCents = centsForSliderValue(sliderValue: sender.upperValue)
        
        touchBarOverLabel?.stringValue = centsToString(overCents, showCents: false)
        touchBarUnderLabel?.stringValue = centsToString(underCents, showCents: false)
    }
    
    @objc fileprivate func rateLimitedSearchAmount(sender: JMSRangeSlider) {
        let delay = 0.25
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(touchBarSearchAmount), object: sender)
        self.perform(#selector(touchBarSearchAmount), with: sender, afterDelay: delay)
    }
    
    func centsForSliderValue(sliderValue: Double) -> Int {
        let cents = Int(pow(sliderValue, 2) * Double(viewModel.maxTransactionAmount - viewModel.minTransactionAmount)) + viewModel.minTransactionAmount
        return cents
    }
    
    func sliderValueForCents(cents: Int) -> Double {
        let sliderValue = sqrt(Double(cents - viewModel.minTransactionAmount) / Double(viewModel.maxTransactionAmount - viewModel.minTransactionAmount))
        return sliderValue
    }
    
    func touchBarPopoverLabel(forToken token: SearchToken, value: String?) -> String? {
        guard let value = value else {
            return nil
        }
        
        switch token {
        case .accountMatches:
            if InstitutionRepository.si.allInstitutions().map({$0.name}).contains(value) {
                // Truncate to 20 characters
                if value.length > 20 {
                    var truncated = value.substring(to: 20)
                    if truncated.hasSuffix(" ") || truncated.hasSuffix(".") {
                        truncated = truncated.substring(to: 29)
                    }
                    truncated += "…"
                    return truncated
                } else {
                    return value
                }
            }
        case .categoryMatches:
            if CategoryRepository.si.allCategoryNames().contains(value) {
                return value
            }
        case .when:
            if viewModel.times.contains(value) {
                return value
            }
        case .over, .under:
            let overString = viewModel.searchTokens[.over]
            let underString = viewModel.searchTokens[.under]
            if overString != nil || underString != nil {
                let overCents = overString == nil ? viewModel.minTransactionAmount : stringToCents(overString!)
                let underCents = underString == nil ? viewModel.maxTransactionAmount : stringToCents(underString!)
                if let overCents = overCents, let underCents = underCents {
                    return "\(centsToString(overCents, showCents: false)) - \(centsToString(underCents, showCents: false))"
                }
            }
        default:
            return nil
        }
        
        return nil
    }
    
    func touchBarDefaultPopoverLabelAndImage(forIdentifier identifier: NSTouchBarItem.Identifier) -> (String, NSImage) {
        switch identifier {
        case NSTouchBarItem.Identifier.accountsPopover:
            return ("All Accounts", #imageLiteral(resourceName: "tb-account"))
        case NSTouchBarItem.Identifier.categoriesPopover:
            return ("All Categories", #imageLiteral(resourceName: "tb-category"))
        case NSTouchBarItem.Identifier.timePopover:
            return ("All Time", #imageLiteral(resourceName: "tb-when"))
        case NSTouchBarItem.Identifier.amountPopover:
            return ("Any Amount", #imageLiteral(resourceName: "tb-amount"))
        default:
            // Should never happen
            return ("", NSImage())
        }
    }
    
    func touchBarUpdatePopoverItem(_ popoverItem: NSPopoverTouchBarItem, isCreation: Bool = false) {
        let tokens = searchField.stringValue.length == 0 ? [SearchToken: String]() : viewModel.searchTokens
        
        switch popoverItem.identifier {
        case NSTouchBarItem.Identifier.accountsPopover :
            let defaults = touchBarDefaultPopoverLabelAndImage(forIdentifier: .accountsPopover)
            if let title = touchBarPopoverLabel(forToken: .accountMatches, value: tokens[.accountMatches]) {
                popoverItem.collapsedRepresentationLabel = title
                popoverItem.collapsedRepresentationImage = defaults.1
            } else {
                popoverItem.collapsedRepresentationLabel = defaults.0
                popoverItem.collapsedRepresentationImage = defaults.1
            }
        case NSTouchBarItem.Identifier.categoriesPopover:
            let scrubber = popoverItem.popoverTouchBar.item(forIdentifier: .categoriesScrubber)?.view as? NSScrubber
            if let title = touchBarPopoverLabel(forToken: .categoryMatches, value: tokens[.categoryMatches]) {
                popoverItem.collapsedRepresentationLabel = title
                popoverItem.collapsedRepresentationImage = Category.touchBarImage(forCategory: title)
                if !isCreation {
                    if let token = tokens[.categoryMatches], let index = CategoryRepository.si.allCategoryNames().index(of: token) {
                        scrubber?.selectedIndex = index + 1
                    } else {
                        scrubber?.selectedIndex = -1
                    }
                }
            } else {
                let defaults = touchBarDefaultPopoverLabelAndImage(forIdentifier: .categoriesPopover)
                popoverItem.collapsedRepresentationLabel = defaults.0
                popoverItem.collapsedRepresentationImage = defaults.1
                if !isCreation {
                    scrubber?.selectedIndex = 0
                }
            }
        case NSTouchBarItem.Identifier.timePopover:
            let scrubber = popoverItem.popoverTouchBar.item(forIdentifier: .timeScrubber)?.view as? NSScrubber
            let defaults = touchBarDefaultPopoverLabelAndImage(forIdentifier: .timePopover)
            if let title = touchBarPopoverLabel(forToken: .when, value: tokens[.when]) {
                popoverItem.collapsedRepresentationLabel = title
                popoverItem.collapsedRepresentationImage = defaults.1
                if !isCreation {
                    if let token = tokens[.when], let index = viewModel.times.index(of: token) {
                        scrubber?.selectedIndex = index
                    } else {
                        scrubber?.selectedIndex = -1
                    }
                }
            } else {
                popoverItem.collapsedRepresentationLabel = defaults.0
                popoverItem.collapsedRepresentationImage = defaults.1
                if !isCreation {
                    scrubber?.selectedIndex = 0
                }
            }
        case NSTouchBarItem.Identifier.amountPopover:
            if let title = touchBarPopoverLabel(forToken: .over, value: tokens[.over] ?? tokens[.under]) {
                popoverItem.collapsedRepresentationLabel = title
                popoverItem.collapsedRepresentationImage = nil
            } else {
                let defaults = touchBarDefaultPopoverLabelAndImage(forIdentifier: .amountPopover)
                popoverItem.collapsedRepresentationLabel = defaults.0
                popoverItem.collapsedRepresentationImage = defaults.1
            }
            
            if let touchBarRangeSlider = touchBarRangeSlider {
                touchBarUpdateSliderFromSearch(touchBarRangeSlider)
            }
        default:
            break
        }
    }
    
    func touchBarUpdateAllPopoverItems() {
        if let popoverItem = self.touchBar?.item(forIdentifier: .accountsPopover) as? NSPopoverTouchBarItem {
            touchBarUpdatePopoverItem(popoverItem)
        }
        
        if let popoverItem = self.touchBar?.item(forIdentifier: .categoriesPopover) as? NSPopoverTouchBarItem {
            touchBarUpdatePopoverItem(popoverItem)
        }
        
        if let popoverItem = self.touchBar?.item(forIdentifier: .timePopover) as? NSPopoverTouchBarItem {
            touchBarUpdatePopoverItem(popoverItem)
        }
        
        if let popoverItem = self.touchBar?.item(forIdentifier: .amountPopover) as? NSPopoverTouchBarItem {
            touchBarUpdatePopoverItem(popoverItem)
        }
    }
}
