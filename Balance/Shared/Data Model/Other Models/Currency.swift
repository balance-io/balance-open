//
//  Currency.swift
//  BalanceForBlockchain
//
//  Created by Benjamin Baron on 6/14/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

public enum Currency: Equatable {
    case fiat(enum: FiatCurrency)
    case crypto(enum: CryptoCurrency)
    case cryptoOther(code: String)
    
    public static func rawValue(_ code: String) -> Currency {
        let uppercased = code.uppercased()
        
        if let fiat = FiatCurrency(rawValue: uppercased) {
            return .fiat(enum: fiat)
        }
        
        if let crypto = CryptoCurrency(rawValue: uppercased) {
            return .crypto(enum: crypto)
        }
        
        return .cryptoOther(code: uppercased)
    }
    
    public var symbol: String {
        switch self {
        case .fiat(let fiat):        return fiat.symbol
        case .crypto(let crypto):    return crypto.symbol
        case .cryptoOther(let code): return code + " "
        }
    }
    
    public var code: String {
        switch self {
        case .fiat(let fiat):        return fiat.code
        case .crypto(let crypto):    return crypto.code
        case .cryptoOther(let code): return code
        }
    }
    
    public var name: String {
        switch self {
        case .fiat(let fiat):        return fiat.name
        case .crypto(let crypto):    return crypto.name
        case .cryptoOther(let code): return code
        }
    }
    
    public var decimals: Int {
        switch self {
        case .fiat(let fiat):   return fiat.decimals
        case .crypto(let crypto): return crypto.decimals
        case .cryptoOther: return 8
        }
    }
    
    public var isFiat: Bool {
        switch self {
        case .fiat: return true
        default:    return false
        }
    }
    
    public var isCrypto: Bool {
        return !isFiat
    }
    
    // Convenience values
    public static let usd: Currency   = .fiat(enum:   .usd)
    public static let eur: Currency   = .fiat(enum:   .eur)
    public static let gbp: Currency   = .fiat(enum:   .gbp)
    public static let btc: Currency   = .crypto(enum: .btc)
    public static let eth: Currency   = .crypto(enum: .eth)
    public static let ltc: Currency   = .crypto(enum: .ltc)
    
    // Equatable
    public static func ==(lhs: Currency, rhs: Currency) -> Bool {
        switch (lhs, rhs) {
        case let (.fiat(a), .fiat(b)):               return a == b
        case let (.crypto(a), .crypto(b)):           return a == b
        case let (.cryptoOther(a), .cryptoOther(b)): return a == b
            
        // Excaust switch cases instead of using default so we get a warning if we add new values
        case (.fiat, _):        return false
        case (.crypto, _):      return false
        case (.cryptoOther, _): return false
        }
    }
}

// Known/popular crypto currencies
public enum CryptoCurrency: String {
    case btc  = "BTC"
    case xbt  = "XBT" // Alternate symbol for BTC
    case bch  = "BCH"
    case eth  = "ETH"
    case ltc  = "LTC"
    case zec  = "ZEC"
    case dash = "DASH"
    case xrp  = "XRP"
    case xmr  = "XMR"
    case gnt  = "GNT"
    case zrx  = "ZRX"
    
    public var code: String {
        return rawValue
    }
    
    public var symbol: String {
        return rawValue + " "
    }
    
    public var name: String {
        switch self {
        case .btc, .xbt: return "Bitcoin"
        case .bch:       return "Bitcoin Cash"
        case .eth:       return "Ether"
        case .ltc:       return "Litecoin"
        case .zec:       return "Zcash"
        case .dash:      return "Dash"
        case .xrp:       return "Ripple"
        case .xmr:       return "Monero"
        case .gnt:       return "Golem"
        case .zrx:       return "0x"
        }
    }
    
    public var decimals: Int {
        return 8
    }
    
    public static func ==(lhs: CryptoCurrency, rhs: CryptoCurrency) -> Bool {
        // Connect alternate BTC symbol XBT
        if (lhs.code == "BTC" || lhs.code == "XBT") && (rhs.code == "BTC" || rhs.code == "XBT") {
            return true
        }
        
        return lhs.code == rhs.code
    }
}

public enum FiatCurrency: String, Equatable {
    case afn   = "AFN"
    case all   = "ALL"
    case ang   = "ANG"
    case ars   = "ARS"
    case aud   = "AUD"
    case awg   = "AWG"
    case azn   = "AZN"
    case bam   = "BAM"
    case bbd   = "BBD"
    case bgn   = "BGN"
    case bmd   = "BMD"
    case bnd   = "BND"
    case bob   = "BOB"
    case brl   = "BRL"
    case bsd   = "BSD"
    case bwp   = "BWP"
    case byn   = "BYN"
    case bzd   = "BZD"
    case cad   = "CAD"
    case chf   = "CHF"
    case clp   = "CLP"
    case cny   = "CNY"
    case cop   = "COP"
    case crc   = "CRC"
    case cup   = "CUP"
    case czk   = "CZK"
    case dkk   = "DKK"
    case dop   = "DOP"
    case egp   = "EGP"
    case eur   = "EUR"
    case fjd   = "FJD"
    case fkp   = "FKP"
    case gbp   = "GBP"
    case ggp   = "GGP"
    case ghs   = "GHS"
    case gip   = "GIP"
    case gtq   = "GTQ"
    case gyd   = "GYD"
    case hkd   = "HKD"
    case hnl   = "HNL"
    case hrk   = "HRK"
    case huf   = "HUF"
    case idr   = "IDR"
    case ils   = "ILS"
    case imp   = "IMP"
    case inr   = "INR"
    case irr   = "IRR"
    case isk   = "ISK"
    case jep   = "JEP"
    case jmd   = "JMD"
    case jpy   = "JPY"
    case kgs   = "KGS"
    case khr   = "KHR"
    case kpw   = "KPW"
    case krw   = "KRW"
    case kyd   = "KYD"
    case kzt   = "KZT"
    case lak   = "LAK"
    case lbp   = "LBP"
    case lkr   = "LKR"
    case lrd   = "LRD"
    case mkd   = "MKD"
    case mnt   = "MNT"
    case mur   = "MUR"
    case mxn   = "MXN"
    case myr   = "MYR"
    case mzn   = "MZN"
    case nad   = "NAD"
    case ngn   = "NGN"
    case nio   = "NIO"
    case nok   = "NOK"
    case npr   = "NPR"
    case nzd   = "NZD"
    case omr   = "OMR"
    case pab   = "PAB"
    case pen   = "PEN"
    case php   = "PHP"
    case pkr   = "PKR"
    case pln   = "PLN"
    case pyg   = "PYG"
    case qar   = "QAR"
    case ron   = "RON"
    case rsd   = "RSD"
    case rub   = "RUB"
    case sar   = "SAR"
    case sbd   = "SBD"
    case scr   = "SCR"
    case sek   = "SEK"
    case sgd   = "SGD"
    case shp   = "SHP"
    case sos   = "SOS"
    case srd   = "SRD"
    case svc   = "SVC"
    case syp   = "SYP"
    case thb   = "THB"
    case `try` = "TRY"
    case ttd   = "TTD"
    case tvd   = "TVD"
    case twd   = "TWD"
    case uah   = "UAH"
    case usd   = "USD"
    case uyu   = "UYU"
    case uzs   = "UZS"
    case vef   = "VEF"
    case vnd   = "VND"
    case xcd   = "XCD"
    case yer   = "YER"
    case zar   = "ZAR"
    case zwd   = "ZWD"
    
    public var symbol: String {
        switch self {
        case .afn: return "؋"
        case .all: return "Lek"
        case .ang: return "ƒ"
        case .ars: return "$"
        case .aud: return "$"
        case .awg: return "ƒ"
        case .azn: return "ман"
        case .bam: return "KM"
        case .bbd: return "$"
        case .bgn: return "лв"
        case .bmd: return "$"
        case .bnd: return "$"
        case .bob: return "$b"
        case .brl: return "R$"
        case .bsd: return "$"
        case .bwp: return "P"
        case .byn: return "Br"
        case .bzd: return "BZ$"
        case .cad: return "$"
        case .chf: return "CHF"
        case .clp: return "$"
        case .cny: return "¥"
        case .cop: return "$"
        case .crc: return "₡"
        case .cup: return "₱"
        case .czk: return "Kč"
        case .dkk: return "kr"
        case .dop: return "RD$"
        case .egp: return "£"
        case .eur: return "€"
        case .fjd: return "$"
        case .fkp: return "£"
        case .gbp: return "£"
        case .ggp: return "£"
        case .ghs: return "¢"
        case .gip: return "£"
        case .gtq: return "Q"
        case .gyd: return "$"
        case .hkd: return "$"
        case .hnl: return "L"
        case .hrk: return "kn"
        case .huf: return "Ft"
        case .idr: return "Rp"
        case .ils: return "₪"
        case .imp: return "£"
        case .inr: return "₹"
        case .irr: return "﷼"
        case .isk: return "kr"
        case .jep: return "£"
        case .jmd: return "J$"
        case .jpy: return "¥"
        case .kgs: return "лв"
        case .khr: return "៛"
        case .kpw: return "₩"
        case .krw: return "₩"
        case .kyd: return "$"
        case .kzt: return "лв"
        case .lak: return "₭"
        case .lbp: return "£"
        case .lkr: return "₨"
        case .lrd: return "$"
        case .mkd: return "ден"
        case .mnt: return "₮"
        case .mur: return "₨"
        case .mxn: return "$"
        case .myr: return "RM"
        case .mzn: return "MT"
        case .nad: return "$"
        case .ngn: return "₦"
        case .nio: return "C$"
        case .nok: return "kr"
        case .npr: return "₨"
        case .nzd: return "$"
        case .omr: return "﷼"
        case .pab: return "B/."
        case .pen: return "S/."
        case .php: return "₱"
        case .pkr: return "₨"
        case .pln: return "zł"
        case .pyg: return "Gs"
        case .qar: return "﷼"
        case .ron: return "lei"
        case .rsd: return "Дин."
        case .rub: return "₽"
        case .sar: return "﷼"
        case .sbd: return "$"
        case .scr: return "₨"
        case .sek: return "kr"
        case .sgd: return "$"
        case .shp: return "£"
        case .sos: return "S"
        case .srd: return "$"
        case .svc: return "$"
        case .syp: return "£"
        case .thb: return "฿"
        case .try: return "₺"
        case .ttd: return "TT$"
        case .tvd: return "$"
        case .twd: return "NT$"
        case .uah: return "₴"
        case .usd: return "$"
        case .uyu: return "$U"
        case .uzs: return "лв"
        case .vef: return "Bs"
        case .vnd: return "₫"
        case .xcd: return "$"
        case .yer: return "﷼"
        case .zar: return "R"
        case .zwd: return "Z$"
        }
    }
    
    public var name: String {
        switch self {
        case .afn: return "Afghanistan Afghani"
        case .all: return "Albania Lek"
        case .ang: return "Netherlands Antilles Guilder"
        case .ars: return "Argentina Peso"
        case .aud: return "Australia Dollar"
        case .awg: return "Aruba Guilder"
        case .azn: return "Azerbaijan Manat"
        case .bam: return "Bosnia and Herzegovina Convertible Marka"
        case .bbd: return "Barbados Dollar"
        case .bgn: return "Bulgaria Lev"
        case .bmd: return "Bermuda Dollar"
        case .bnd: return "Brunei Darussalam Dollar"
        case .bob: return "Bolivia Bolíviano"
        case .brl: return "Brazil Real"
        case .bsd: return "Bahamas Dollar"
        case .bwp: return "Botswana Pula"
        case .byn: return "Belarus Ruble"
        case .bzd: return "Belize Dollar"
        case .cad: return "Canada Dollar"
        case .chf: return "Switzerland Franc"
        case .clp: return "Chile Peso"
        case .cny: return "China Yuan Renminbi"
        case .cop: return "Colombia Peso"
        case .crc: return "Costa Rica Colon"
        case .cup: return "Cuba Peso"
        case .czk: return "Czech Republic Koruna"
        case .dkk: return "Denmark Krone"
        case .dop: return "Dominican Republic Peso"
        case .egp: return "Egypt Pound"
        case .eur: return "Euro Member Countries"
        case .fjd: return "Fiji Dollar"
        case .fkp: return "Falkland Islands (Malvinas) Pound"
        case .gbp: return "United Kingdom Pound"
        case .ggp: return "Guernsey Pound"
        case .ghs: return "Ghana Cedi"
        case .gip: return "Gibraltar Pound"
        case .gtq: return "Guatemala Quetzal"
        case .gyd: return "Guyana Dollar"
        case .hkd: return "Hong Kong Dollar"
        case .hnl: return "Honduras Lempira"
        case .hrk: return "Croatia Kuna"
        case .huf: return "Hungary Forint"
        case .idr: return "Indonesia Rupiah"
        case .ils: return "Israel Shekel"
        case .imp: return "Isle of Man Pound"
        case .inr: return "India Rupee"
        case .irr: return "Iran Rial"
        case .isk: return "Iceland Krona"
        case .jep: return "Jersey Pound"
        case .jmd: return "Jamaica Dollar"
        case .jpy: return "Japan Yen"
        case .kgs: return "Kyrgyzstan Som"
        case .khr: return "Cambodia Riel"
        case .kpw: return "Korea (North) Won"
        case .krw: return "Korea (South) Won"
        case .kyd: return "Cayman Islands Dollar"
        case .kzt: return "Kazakhstan Tenge"
        case .lak: return "Laos Kip"
        case .lbp: return "Lebanon Pound"
        case .lkr: return "Sri Lanka Rupee"
        case .lrd: return "Liberia Dollar"
        case .mkd: return "Macedonia Denar"
        case .mnt: return "Mongolia Tughrik"
        case .mur: return "Mauritius Rupee"
        case .mxn: return "Mexico Peso"
        case .myr: return "Malaysia Ringgit"
        case .mzn: return "Mozambique Metical"
        case .nad: return "Namibia Dollar"
        case .ngn: return "Nigeria Naira"
        case .nio: return "Nicaragua Cordoba"
        case .nok: return "Norway Krone"
        case .npr: return "Nepal Rupee"
        case .nzd: return "New Zealand Dollar"
        case .omr: return "Oman Rial"
        case .pab: return "Panama Balboa"
        case .pen: return "Peru Sol"
        case .php: return "Philippines Peso"
        case .pkr: return "Pakistan Rupee"
        case .pln: return "Poland Zloty"
        case .pyg: return "Paraguay Guarani"
        case .qar: return "Qatar Riyal"
        case .ron: return "Romania Leu"
        case .rsd: return "Serbia Dinar"
        case .rub: return "Russia Ruble"
        case .sar: return "Saudi Arabia Riyal"
        case .sbd: return "Solomon Islands Dollar"
        case .scr: return "Seychelles Rupee"
        case .sek: return "Sweden Krona"
        case .sgd: return "Singapore Dollar"
        case .shp: return "Saint Helena Pound"
        case .sos: return "Somalia Shilling"
        case .srd: return "Suriname Dollar"
        case .svc: return "El Salvador Colon"
        case .syp: return "Syria Pound"
        case .thb: return "Thailand Baht"
        case .try: return "Turkey Lira"
        case .ttd: return "Trinidad and Tobago Dollar"
        case .tvd: return "Tuvalu Dollar"
        case .twd: return "Taiwan New Dollar"
        case .uah: return "Ukraine Hryvnia"
        case .usd: return "United States Dollar"
        case .uyu: return "Uruguay Peso"
        case .uzs: return "Uzbekistan Som"
        case .vef: return "Venezuela Bolívar"
        case .vnd: return "Viet Nam Dong"
        case .xcd: return "East Caribbean Dollar"
        case .yer: return "Yemen Rial"
        case .zar: return "South Africa Rand"
        case .zwd: return "Zimbabwe Dollar"
        }
    }
    
    public var code: String {
        return rawValue
    }
    
    public var decimals: Int {
        switch self {
        case .clp, .irr, .isk, .jpy, .kpw, .krw, .lak, .lbp, .mkd, .pyg, .vnd: return 0
        case .omr: return 3
        default: return 2
        }
    }
    
    public static func ==(lhs: FiatCurrency, rhs: FiatCurrency) -> Bool {
        return lhs.code == rhs.code
    }
}
