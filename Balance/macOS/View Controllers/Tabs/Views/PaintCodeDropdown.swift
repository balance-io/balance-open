//
//  PaintCodeDropdown.swift
//  Bal
//
//  Created by Benjamin Baron on 1/30/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation
import SnapKit

protocol PaintCodeDropdownDelegate: class {
    func dropdownSelectedIndexChanged(_ dropdown: PaintCodeDropdown)
}

// TODO: Rewrite this to do the expansion as another view in the window to avoid all the layout hacks
// Right now this class isn't generalized at all, it's really specific to TransactionsViewController.
class PaintCodeDropdown: View {
    struct Notifications {
        static let opened = Notification.Name("PaintCodeDropdown_opened")
        static let closed = Notification.Name("PaintCodeDropdown_opened")
        
        struct Keys {
            static let dropdown = "dropdown"
        }
    }
    
    typealias DropdownDrawingBlock = (_ frame: NSRect, _ backgroundColor: NSColor?) -> (Void)
    
    var drawingBlock: DropdownDrawingBlock? {
        didSet {
            self.needsDisplay = true
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        drawingBlock?(self.bounds, selectedIndex > 0 || overrideColor ? drawingBackgroundColor : nil)
    }
    
    weak var delegate: PaintCodeDropdownDelegate?
    
    override var isFlipped: Bool {
        return true
    }
    
    fileprivate(set) var isOpen = false
    fileprivate var isAnimating = false
    fileprivate var heightConstraint: NSLayoutConstraint!
    
    var drawingBackgroundColor: NSColor?
    var overrideColor = false {
        didSet {
            self.needsDisplay = true
        }
    }
    
    var selectedIndex: Int = 0
    
    func updateSelectedIndex(_ index: Int) {
        guard index >= 0 && index < items.count else {
            return
        }
        
        selectedIndex = index
        titleLabel.stringValue = items[selectedIndex]
        delegate?.dropdownSelectedIndexChanged(self)
        overrideColor = false
        self.needsDisplay = true
    }
    
    var items = [String]() {
        didSet {
            close()
            createLabels()
        }
    }
    
    fileprivate(set) var titleLabel = LabelField()
    fileprivate var labels = [LabelField]()
    fileprivate var spacers = [View]()
    
    init() {
        super.init(frame: NSRect(x: 0, y: 0, width: 100, height: 36))
        commonInit()
    }
    
    init(items: [String]) {
        self.items = items
        super.init(frame: NSRect(x: 0, y: 0, width: 100, height: 36))
        createLabels()
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        // Doing it this way because animating SnapKit constraints is currently broken
        heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 36)
        self.addConstraint(heightConstraint)
        
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(dropdownClosed), name: Notifications.closed)
        
        self.drawingBlock = CurrentTheme.type == .light ? SearchFilterButtonsLight.drawButton : SearchFilterButtonsDark.drawButton
    }
    
    @objc fileprivate func dropdownClosed(notification: Notification) {
        if notification.userInfo?[Notifications.Keys.dropdown] as? PaintCodeDropdown != self {
            close()
        }
    }
    
    fileprivate func createLabels() {
        titleLabel.removeFromSuperview()
        for label in labels {
            label.removeFromSuperview()
        }
        labels.removeAll()
        
        for spacer in spacers {
            spacer.removeFromSuperview()
        }
        spacers.removeAll()
        
        func makeLabel(title: String, index: Int) -> LabelField {
            let label = LabelField()
            label.font = .mediumSystemFont(ofSize: 12)
            label.textColor = .white
            label.stringValue = title
            label.alignment = .center
            label.verticalAlignment = .center
            label.cell?.lineBreakMode = .byTruncatingTail
            self.addSubview(label)
            label.snp.makeConstraints { make in
                make.width.equalToSuperview().offset(-6)
                make.height.equalTo(30)
                make.top.equalTo(3 + (index * 31))
                make.centerX.equalToSuperview()
            }
            
            return label
        }
        
        titleLabel = makeLabel(title: items.first ?? "", index: 0)
        for (index, item) in items.enumerated() {
            let spacer = View()
            spacer.layerBackgroundColor = NSColor(deviceWhiteInt: 0, alpha: 0.05)
            self.addSubview(spacer)
            spacer.snp.makeConstraints { make in
                make.width.equalToSuperview().offset(-6)
                make.height.equalTo(1)
                make.top.equalTo(3 + ((index + 1) * 31))
                make.centerX.equalToSuperview()
            }
            spacers.append(spacer)
            
            let label = makeLabel(title: item, index: index + 1)
            labels.append(label)
        }
        
        // First spacer is visible when closed
        spacers.first?.alphaValue = 0.0
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        // Have to override this or we don't get mouseUp events apparantly
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        let location = self.convert(theEvent.locationInWindow, from: nil)
        let isInsideButton = NSPointInRect(location, self.bounds)
        if isInsideButton {
            if isOpen {
                let index = self.index(at: location)
                if index >= 0 && selectedIndex != index {
                    updateSelectedIndex(index)
                }
                close()
            } else {
                open()
            }
        }
    }
    
    fileprivate func index(at location: NSPoint) -> Int {
        if let superview = self.superview {
            let superLocation = superview.convert(location, from: self)
            if let labelField = self.hitTest(superLocation) as? LabelField, let index = labels.index(of: labelField) {
                return index
            }
        }
        
        return -1
    }
    
    func open() {
        guard !isOpen && !isAnimating else {
            return
        }
        
        NotificationCenter.postOnMainThread(name: Notifications.opened, object: nil, userInfo: [Notifications.Keys.dropdown: self])
        
        isAnimating = true

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(controlPoints: 0, 0, 0.2, 1)
            heightConstraint.animator().constant = CGFloat(36 + (items.count * 31))
            self.animator().needsUpdateConstraints = true
            spacers.first?.animator().alphaValue = 1.0
        }, completionHandler: {
            self.isOpen = true
            self.isAnimating = false
        })
    }
    
    func close() {
        guard isOpen && !isAnimating else {
            return
        }
        
        NotificationCenter.postOnMainThread(name: Notifications.closed, object: nil, userInfo: [Notifications.Keys.dropdown: self])
        
        isAnimating = true
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(controlPoints: 0, 0, 0.2, 1)
            heightConstraint.animator().constant = CGFloat(36)
            self.animator().needsUpdateConstraints = true
            self.animator().needsDisplay = true
            spacers.first?.animator().alphaValue = 0.0
        }, completionHandler: {
            self.isOpen = false
            self.isAnimating = false
        })
    }
}
