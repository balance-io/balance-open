import Cocoa

// In the storyboard, ensure the view controller's transition checkboxes are all off, and the NSTabView's delegate is set to this controller object

class PreferencesViewController: NSTabViewController {
    
    var originalSizes = [String : NSSize]()
    
    // MARK: - NSTabViewDelegate -
    
    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        super.tabView(tabView, didSelect: tabViewItem)
        
        if let window = self.view.window, let tabViewItem = tabViewItem {
            window.title = tabViewItem.label
            let size = originalSizes[tabViewItem.label] ?? NSSize(width: 500, height: 500)
            let contentFrame = window.frameRect(forContentRect: NSMakeRect(0.0, 0.0, size.width, size.height))
            var frame = window.frame
            frame.origin.y = frame.origin.y + (frame.size.height - contentFrame.size.height)
            frame.size.height = contentFrame.size.height
            frame.size.width = contentFrame.size.width
            window.setFrame(frame, display: false, animate: true)
            
            // Analytics
            BITHockeyManager.shared()?.metricsManager?.trackEvent(withName: "Preferences tab selected \(tabViewItem.label)")
        }
    }
}
