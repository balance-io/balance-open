import Cocoa
import MASShortcut

class PreferencesGeneralViewController: NSViewController {
    

    @IBOutlet weak var logInCheckBox: NSButton!
    @IBOutlet weak var shortcutView: MASShortcutView!
    @IBOutlet weak var mainCurrencyPopupButton: NSPopUpButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let automaticCurrency = "Automatic - \(NSLocale.current.currencyCode ?? "USD")"
        let currencies = [automaticCurrency, "USD", "EUR", "GBP", "BTC", "ETH"]
        for currency in currencies {
            mainCurrencyPopupButton.addItem(withTitle: currency)
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        shortcutView.associatedUserDefaultsKey = Shortcut.shortcutUserDefaultsKey
        shortcutView.shortcutValue = Shortcut.defaultShortcut
        
        logInCheckBox.state = defaults.launchAtLogin ? .on : .off
        
        
    }

    @IBAction func logInCheckBoxPress(_ sender: NSButton) {
        let enabled = (sender.state == .on)
        defaults.launchAtLogin = enabled
        sender.state = defaults.launchAtLogin ? .on : .off
    }
    
    @IBAction func mainCurrencyChanged(_ sender: NSPopUpButton) {
        if sender.indexOfSelectedItem == 0 {
            defaults.masterCurrency = nil
        } else if let currencyCode = sender.titleOfSelectedItem {
            defaults.masterCurrency = Currency.rawValue(currencyCode)
        }
    }
}
