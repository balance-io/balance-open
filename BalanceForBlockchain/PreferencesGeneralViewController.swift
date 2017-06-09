import Cocoa
import MASShortcut

class PreferencesGeneralViewController: NSViewController {
    

    @IBOutlet weak var logInCheckBox: NSButton!
    @IBOutlet weak var themeSegmentControl: NSSegmentedControl!
    @IBOutlet weak var shortcutView: MASShortcutView!
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        shortcutView.associatedUserDefaultsKey = Shortcut.shortcutUserDefaultsKey
        shortcutView.shortcutValue = Shortcut.defaultShortcut
        
        logInCheckBox.state = defaults.launchAtLogin ? NSOnState : NSOffState
        
        themeSegmentControl.selectedSegment = defaults.selectedThemeType.rawValue
    }

    @IBAction func logInCheckBoxPress(_ sender: NSButton) {
        let enabled = (sender.state == NSOnState)
        defaults.launchAtLogin = enabled
        sender.state = defaults.launchAtLogin ? NSOnState : NSOffState
    }
    
    @IBAction func themeChanged(_ sender: NSSegmentedControl) {
        if let themeType = ThemeType(rawValue: sender.selectedSegment) {
            if defaults.selectedThemeType != themeType {
                defaults.selectedThemeType = themeType
                NotificationCenter.postOnMainThread(name: Notifications.ReloadPopoverController)
            }
        }
    }
}
