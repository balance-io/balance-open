import Cocoa

// In the storyboard, ensure the view controller's transition checkboxes are all off, and the NSTabView's delegate is set to this controller object

class PreferencesViewController: NSTabViewController {
    
    var originalSizes: [String: NSSize] = ["General": NSSize(width: 500, height: 150),
                                           "Accounts": NSSize(width: 500, height: 300),
                                           "Security": NSSize(width: 500, height: 250)]
    
    // MARK: - NSTabViewDelegate -
    
    override func viewWillAppear() {
        super.viewWillAppear()
        resizeWindow()
    }
    
    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        super.tabView(tabView, didSelect: tabViewItem)
        
        if let tabViewItem = tabViewItem {
            resizeWindow()
            
            // Analytics
            analytics.trackEvent(withName: "Preferences tab selected \(tabViewItem.label)")
        }
    }
    
    fileprivate func resizeWindow() {
        if let window = self.view.window, let tabViewItem = tabView.selectedTabViewItem {
            window.title = tabViewItem.label
            let size = originalSizes[tabViewItem.label] ?? NSSize(width: 500, height: 250)
            let contentFrame = window.frameRect(forContentRect: NSMakeRect(0.0, 0.0, size.width, size.height))
            var frame = window.frame
            frame.origin.y = frame.origin.y + (frame.size.height - contentFrame.size.height)
            frame.size.height = contentFrame.size.height
            frame.size.width = contentFrame.size.width
            
            if window.frame.size != frame.size {
                window.setFrame(frame, display: false, animate: true)
            }
        }
    }
}
