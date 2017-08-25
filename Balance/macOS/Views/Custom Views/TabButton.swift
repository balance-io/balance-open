//
//  TabButton.swift
//  Bal
//
//  Created by Benjamin Baron on 6/7/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import AppKit
import BalanceVectorGraphics

class TabButton: View {
    let icon: TabIcon
    let altIcon: TabIcon?
    let label = LabelField()
    let button = Button()
    var active = false
    var altBehavior = false {
        didSet {
            if icon is FeedTabIcon {
                (icon as? NSView)?.isHidden = altBehavior
                (altIcon as? NSView)?.isHidden = !altBehavior
            }
        }
    }
    
    init(iconView: TabIcon, altIconView: TabIcon? = nil, labelText: String) {
        self.icon = iconView
        self.altIcon = altIconView
        super.init(frame: NSZeroRect)
        
        self.snp.makeConstraints { make in
            make.width.equalTo(80)
            make.height.equalTo(45)
        }
        
        iconView.tabIconBorderColor = CurrentTheme.tabs.header.tabIconBorderColor
        iconView.tabIconColor = CurrentTheme.tabs.header.tabIconColorInactive
        iconView.tabIconSelectedColor = CurrentTheme.tabs.header.tabIconColorActive
        if let feedIcon = iconView as? FeedTabIcon {
            feedIcon.bubbleColor = CurrentTheme.tabs.header.tabIconColorInactive
            feedIcon.bubbleSelectedColor = CurrentTheme.tabs.header.tabIconColorActive
        }
        if let icon = iconView as? NSView {
            icon.alphaValue = 1.0
            self.addSubview(icon)
            icon.snp.makeConstraints { make in
                make.width.equalTo(26)
                make.height.equalTo(20)
                make.centerX.equalTo(self)
                make.top.equalTo(self).inset(6)
            }
        }
        
        if let altIconView = altIconView {
            altIconView.tabIconBorderColor = CurrentTheme.tabs.header.tabIconBorderColor
            altIconView.tabIconColor = CurrentTheme.tabs.header.tabIconColorInactive
            altIconView.tabIconSelectedColor = CurrentTheme.tabs.header.tabIconColorActive
            if let feedIcon = altIconView as? FeedTabIcon {
                feedIcon.bubbleColor = CurrentTheme.tabs.header.tabIconNotificationBubbleColor
                feedIcon.bubbleSelectedColor = CurrentTheme.tabs.header.tabIconNotificationBubbleColor
            }
            if let icon = altIconView as? NSView {
                icon.alphaValue = 1.0
                icon.isHidden = true
                self.addSubview(icon)
                icon.snp.makeConstraints { make in
                    make.width.equalTo(26)
                    make.height.equalTo(20)
                    make.centerX.equalTo(self)
                    make.top.equalTo(self).inset(6)
                }
            }
        }
        
        label.backgroundColor = CurrentTheme.defaults.backgroundColor
        label.textColor = CurrentTheme.tabs.header.tabFontColor
        label.stringValue = labelText
        label.alignment = .center
        label.font = CurrentTheme.tabs.header.tabFont
        label.alphaValue = 1.0
        self.addSubview(label)
        label.snp.makeConstraints { make in
            make.width.equalTo(self)
            make.height.equalTo(12)
            make.bottom.equalTo(self).inset(6.5)
            make.centerX.equalTo(self)
        }
        
        button.isBordered = false
        button.title = ""
        button.setAccessibilityLabel(labelText)
        button.setAccessibilitySelected(false)
        
        self.addSubview(button)
        button.snp.makeConstraints { make in
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    func activate() {
        if !active {
            label.alphaValue = 1.0
            label.font = NSFont.systemFont(ofSize: 10.5)
            label.textColor = CurrentTheme.tabs.header.tabFontColorActive
            icon.addHighlightAnimation(reverseAnimation: false, completionBlock: nil)
            altIcon?.addHighlightAnimation(reverseAnimation: false, completionBlock: nil)
            active = true
            button.setAccessibilitySelected(true)
        }
    }
    
    func deactivate() {
        if active {
            label.alphaValue = 1.08
            label.font = NSFont.systemFont(ofSize: 10.5)
            label.textColor = CurrentTheme.tabs.header.tabFontColor
            icon.addHighlightAnimation(reverseAnimation: true, completionBlock: nil)
            altIcon?.addHighlightAnimation(reverseAnimation: true, completionBlock: nil)
            active = false
            button.setAccessibilitySelected(false)
        }
    }
}
