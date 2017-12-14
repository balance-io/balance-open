import Cocoa
import MASShortcut

class PreferencesGeneralViewController: NSViewController {
    
    @IBOutlet weak var logInCheckBox: NSButton!
    @IBOutlet weak var shortcutView: MASShortcutView!
    @IBOutlet weak var mainCurrencyPopupButton: NSPopUpButton!
    
    let autoPlusSeparaterOffset = 2
    let currencyCodes = ["USD", "EUR", "GBP", "---", "AUD", "CAD", "CNY", "DKK", "HKD", "JPY", "---", "BTC", "ETH", "LTC"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let automaticCurrency = "Automatic - \(NSLocale.current.currencyCode ?? "USD")"
        mainCurrencyPopupButton.addItem(withTitle: automaticCurrency)
        mainCurrencyPopupButton.menu?.addItem(NSMenuItem.separator())
        for code in currencyCodes {
            if code == "---" {
                mainCurrencyPopupButton.menu?.addItem(NSMenuItem.separator())
            } else {
                let title = Currency.rawValue(code).longName
                mainCurrencyPopupButton.addItem(withTitle: title)
            }
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        shortcutView.associatedUserDefaultsKey = Shortcut.shortcutUserDefaultsKey
        if shortcutView.shortcutValue == nil {
            shortcutView.shortcutValue = Shortcut.defaultShortcut
        }
        
        logInCheckBox.state = defaults.launchAtLogin ? .on : .off
        
        if defaults.isMasterCurrencySet, let index = currencyCodes.index(of: defaults.masterCurrency.code) {
            mainCurrencyPopupButton.selectItem(at: index + autoPlusSeparaterOffset)
        }
    }

    @IBAction func logInCheckBoxPress(_ sender: NSButton) {
        let enabled = (sender.state == .on)
        defaults.launchAtLogin = enabled
        sender.state = defaults.launchAtLogin ? .on : .off
    }
    
    @IBAction func mainCurrencyChanged(_ sender: NSPopUpButton) {
        let index = sender.indexOfSelectedItem
        if index == 0 {
            defaults.masterCurrency = nil
        } else {
            let code = currencyCodes[index - autoPlusSeparaterOffset]
            defaults.masterCurrency = Currency.rawValue(code)
        }
    }
}
