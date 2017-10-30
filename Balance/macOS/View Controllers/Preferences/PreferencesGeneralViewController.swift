import Cocoa
import MASShortcut

class PreferencesGeneralViewController: NSViewController {
    
    @IBOutlet weak var logInCheckBox: NSButton!
    @IBOutlet weak var shortcutView: MASShortcutView!
    @IBOutlet weak var mainCurrencyPopupButton: NSPopUpButton!
    
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
                let currency = Currency.rawValue(code)
                let title = "\(currency.name) (\(currency.code))"
                mainCurrencyPopupButton.addItem(withTitle: title)
            }
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        shortcutView.associatedUserDefaultsKey = Shortcut.shortcutUserDefaultsKey
        shortcutView.shortcutValue = Shortcut.defaultShortcut
        
        logInCheckBox.state = defaults.launchAtLogin ? .on : .off
        
        if let masterCurrency = defaults.masterCurrency, let index = currencyCodes.index(of: masterCurrency.code) {
            mainCurrencyPopupButton.selectItem(at: index + 2)
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
            let code = currencyCodes[index - 2]
            defaults.masterCurrency = Currency.rawValue(code)
        }
    }
}
