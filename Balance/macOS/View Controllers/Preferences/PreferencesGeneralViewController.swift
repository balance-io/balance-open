import Cocoa
import MASShortcut

class PreferencesGeneralViewController: NSViewController {
    

    @IBOutlet weak var logInCheckBox: NSButton!
    @IBOutlet weak var themeSegmentControl: NSSegmentedControl!
    @IBOutlet weak var shortcutView: MASShortcutView!
    @IBOutlet weak var emailPreferencePopUpButton: NSPopUpButton!
    @IBOutlet weak var searchPreferencePopUpButton: NSPopUpButton!
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        shortcutView.associatedUserDefaultsKey = Shortcut.shortcutUserDefaultsKey
        shortcutView.shortcutValue = Shortcut.defaultShortcut
        
        logInCheckBox.state = defaults.launchAtLogin ? .on : .off
        
        themeSegmentControl.selectedSegment = defaults.selectedThemeType.rawValue
        
        emailPreferencePopUpButton.selectItem(at: defaults.emailPreference.rawValue)
        searchPreferencePopUpButton.selectItem(at: defaults.searchPreference.rawValue)
    }

    @IBAction func logInCheckBoxPress(_ sender: NSButton) {
        let enabled = (sender.state == .on)
        defaults.launchAtLogin = enabled
        sender.state = defaults.launchAtLogin ? .on : .off
    }
    
    @IBAction func themeChanged(_ sender: NSSegmentedControl) {
        if let themeType = ThemeType(rawValue: sender.selectedSegment) {
            if defaults.selectedThemeType != themeType {
                defaults.selectedThemeType = themeType
                NotificationCenter.postOnMainThread(name: Notifications.ReloadPopoverController)
            }
        }
    }
    
    @IBAction func emailPreferenceChanged(_ sender: NSPopUpButton) {
        if let emailPreference = EmailPreference(rawValue: sender.selectedTag()) {
            if defaults.emailPreference != emailPreference {
                defaults.emailPreference = emailPreference
                NotificationCenter.postOnMainThread(name: Notifications.ReloadPopoverController)
            }
        }
    }
    
    @IBAction func searchPreferenceChanged(_ sender: NSPopUpButton) {
        if let searchPreference = SearchPreference(rawValue: sender.selectedTag()) {
            if defaults.searchPreference != searchPreference {
                defaults.searchPreference = searchPreference
                NotificationCenter.postOnMainThread(name: Notifications.ReloadPopoverController)
            }
        }
    }
    
}
