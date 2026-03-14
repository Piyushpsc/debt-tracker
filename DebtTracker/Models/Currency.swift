//
//  Currency.swift
//  Dime
//

import Foundation

struct Currency: Identifiable, Hashable, Codable {
    let code: String
    let symbol: String
    let flag: String
    let name: String

    var id: String { code }

    func format(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_IN")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "\(Int(amount))"
        return "\(symbol)\(formatted)"
    }
}

// MARK: - Popular currencies shown at top
let popularCurrencies: [Currency] = [
    Currency(code: "USD", symbol: "$",  flag: "🇺🇸", name: "US Dollar"),
    Currency(code: "EUR", symbol: "€",  flag: "🇪🇺", name: "Euro"),
    Currency(code: "GBP", symbol: "£",  flag: "🇬🇧", name: "British Pound"),
    Currency(code: "INR", symbol: "₹",  flag: "🇮🇳", name: "Indian Rupee"),
    Currency(code: "JPY", symbol: "¥",  flag: "🇯🇵", name: "Japanese Yen"),
    Currency(code: "CNY", symbol: "¥",  flag: "🇨🇳", name: "Chinese Yuan"),
    Currency(code: "AUD", symbol: "A$", flag: "🇦🇺", name: "Australian Dollar"),
    Currency(code: "CAD", symbol: "C$", flag: "🇨🇦", name: "Canadian Dollar"),
    Currency(code: "AED", symbol: "د.إ",flag: "🇦🇪", name: "UAE Dirham"),
    Currency(code: "SGD", symbol: "S$", flag: "🇸🇬", name: "Singapore Dollar"),
]

// MARK: - All currencies
let allCurrencies: [Currency] = [
    Currency(code: "AED", symbol: "د.إ", flag: "🇦🇪", name: "UAE Dirham"),
    Currency(code: "AFN", symbol: "؋",   flag: "🇦🇫", name: "Afghan Afghani"),
    Currency(code: "ALL", symbol: "L",   flag: "🇦🇱", name: "Albanian Lek"),
    Currency(code: "AMD", symbol: "֏",   flag: "🇦🇲", name: "Armenian Dram"),
    Currency(code: "ANG", symbol: "ƒ",   flag: "🇳🇱", name: "Netherlands Antillean Guilder"),
    Currency(code: "AOA", symbol: "Kz",  flag: "🇦🇴", name: "Angolan Kwanza"),
    Currency(code: "ARS", symbol: "$",   flag: "🇦🇷", name: "Argentine Peso"),
    Currency(code: "AUD", symbol: "A$",  flag: "🇦🇺", name: "Australian Dollar"),
    Currency(code: "AWG", symbol: "ƒ",   flag: "🇦🇼", name: "Aruban Florin"),
    Currency(code: "AZN", symbol: "₼",   flag: "🇦🇿", name: "Azerbaijani Manat"),
    Currency(code: "BAM", symbol: "KM",  flag: "🇧🇦", name: "Bosnia-Herzegovina Convertible Mark"),
    Currency(code: "BBD", symbol: "Bds$",flag: "🇧🇧", name: "Barbadian Dollar"),
    Currency(code: "BDT", symbol: "৳",   flag: "🇧🇩", name: "Bangladeshi Taka"),
    Currency(code: "BGN", symbol: "лв",  flag: "🇧🇬", name: "Bulgarian Lev"),
    Currency(code: "BHD", symbol: "BD",  flag: "🇧🇭", name: "Bahraini Dinar"),
    Currency(code: "BND", symbol: "B$",  flag: "🇧🇳", name: "Brunei Dollar"),
    Currency(code: "BOB", symbol: "Bs.", flag: "🇧🇴", name: "Bolivian Boliviano"),
    Currency(code: "BRL", symbol: "R$",  flag: "🇧🇷", name: "Brazilian Real"),
    Currency(code: "BSD", symbol: "B$",  flag: "🇧🇸", name: "Bahamian Dollar"),
    Currency(code: "BTN", symbol: "Nu",  flag: "🇧🇹", name: "Bhutanese Ngultrum"),
    Currency(code: "BWP", symbol: "P",   flag: "🇧🇼", name: "Botswana Pula"),
    Currency(code: "BYN", symbol: "Br",  flag: "🇧🇾", name: "Belarusian Ruble"),
    Currency(code: "BZD", symbol: "BZ$", flag: "🇧🇿", name: "Belize Dollar"),
    Currency(code: "CAD", symbol: "C$",  flag: "🇨🇦", name: "Canadian Dollar"),
    Currency(code: "CHF", symbol: "Fr",  flag: "🇨🇭", name: "Swiss Franc"),
    Currency(code: "CLP", symbol: "$",   flag: "🇨🇱", name: "Chilean Peso"),
    Currency(code: "CNY", symbol: "¥",   flag: "🇨🇳", name: "Chinese Yuan"),
    Currency(code: "COP", symbol: "$",   flag: "🇨🇴", name: "Colombian Peso"),
    Currency(code: "CRC", symbol: "₡",   flag: "🇨🇷", name: "Costa Rican Colón"),
    Currency(code: "CUP", symbol: "$",   flag: "🇨🇺", name: "Cuban Peso"),
    Currency(code: "CVE", symbol: "$",   flag: "🇨🇻", name: "Cape Verdean Escudo"),
    Currency(code: "CZK", symbol: "Kč",  flag: "🇨🇿", name: "Czech Koruna"),
    Currency(code: "DJF", symbol: "Fdj", flag: "🇩🇯", name: "Djiboutian Franc"),
    Currency(code: "DKK", symbol: "kr",  flag: "🇩🇰", name: "Danish Krone"),
    Currency(code: "DOP", symbol: "RD$", flag: "🇩🇴", name: "Dominican Peso"),
    Currency(code: "DZD", symbol: "دج",  flag: "🇩🇿", name: "Algerian Dinar"),
    Currency(code: "EGP", symbol: "£",   flag: "🇪🇬", name: "Egyptian Pound"),
    Currency(code: "ERN", symbol: "Nfk", flag: "🇪🇷", name: "Eritrean Nakfa"),
    Currency(code: "ETB", symbol: "Br",  flag: "🇪🇹", name: "Ethiopian Birr"),
    Currency(code: "EUR", symbol: "€",   flag: "🇪🇺", name: "Euro"),
    Currency(code: "FJD", symbol: "FJ$", flag: "🇫🇯", name: "Fijian Dollar"),
    Currency(code: "GBP", symbol: "£",   flag: "🇬🇧", name: "British Pound"),
    Currency(code: "GEL", symbol: "₾",   flag: "🇬🇪", name: "Georgian Lari"),
    Currency(code: "GHS", symbol: "₵",   flag: "🇬🇭", name: "Ghanaian Cedi"),
    Currency(code: "GMD", symbol: "D",   flag: "🇬🇲", name: "Gambian Dalasi"),
    Currency(code: "GTQ", symbol: "Q",   flag: "🇬🇹", name: "Guatemalan Quetzal"),
    Currency(code: "HKD", symbol: "HK$", flag: "🇭🇰", name: "Hong Kong Dollar"),
    Currency(code: "HNL", symbol: "L",   flag: "🇭🇳", name: "Honduran Lempira"),
    Currency(code: "HRK", symbol: "kn",  flag: "🇭🇷", name: "Croatian Kuna"),
    Currency(code: "HTG", symbol: "G",   flag: "🇭🇹", name: "Haitian Gourde"),
    Currency(code: "HUF", symbol: "Ft",  flag: "🇭🇺", name: "Hungarian Forint"),
    Currency(code: "IDR", symbol: "Rp",  flag: "🇮🇩", name: "Indonesian Rupiah"),
    Currency(code: "ILS", symbol: "₪",   flag: "🇮🇱", name: "Israeli Shekel"),
    Currency(code: "INR", symbol: "₹",   flag: "🇮🇳", name: "Indian Rupee"),
    Currency(code: "IQD", symbol: "ع.د", flag: "🇮🇶", name: "Iraqi Dinar"),
    Currency(code: "IRR", symbol: "﷼",   flag: "🇮🇷", name: "Iranian Rial"),
    Currency(code: "ISK", symbol: "kr",  flag: "🇮🇸", name: "Icelandic Króna"),
    Currency(code: "JMD", symbol: "J$",  flag: "🇯🇲", name: "Jamaican Dollar"),
    Currency(code: "JOD", symbol: "JD",  flag: "🇯🇴", name: "Jordanian Dinar"),
    Currency(code: "JPY", symbol: "¥",   flag: "🇯🇵", name: "Japanese Yen"),
    Currency(code: "KES", symbol: "KSh", flag: "🇰🇪", name: "Kenyan Shilling"),
    Currency(code: "KGS", symbol: "лв",  flag: "🇰🇬", name: "Kyrgyzstani Som"),
    Currency(code: "KHR", symbol: "៛",   flag: "🇰🇭", name: "Cambodian Riel"),
    Currency(code: "KRW", symbol: "₩",   flag: "🇰🇷", name: "South Korean Won"),
    Currency(code: "KWD", symbol: "KD",  flag: "🇰🇼", name: "Kuwaiti Dinar"),
    Currency(code: "KZT", symbol: "₸",   flag: "🇰🇿", name: "Kazakhstani Tenge"),
    Currency(code: "LAK", symbol: "₭",   flag: "🇱🇦", name: "Laotian Kip"),
    Currency(code: "LBP", symbol: "ل.ل", flag: "🇱🇧", name: "Lebanese Pound"),
    Currency(code: "LKR", symbol: "₨",   flag: "🇱🇰", name: "Sri Lankan Rupee"),
    Currency(code: "LYD", symbol: "LD",  flag: "🇱🇾", name: "Libyan Dinar"),
    Currency(code: "MAD", symbol: "MAD", flag: "🇲🇦", name: "Moroccan Dirham"),
    Currency(code: "MDL", symbol: "L",   flag: "🇲🇩", name: "Moldovan Leu"),
    Currency(code: "MKD", symbol: "ден", flag: "🇲🇰", name: "Macedonian Denar"),
    Currency(code: "MMK", symbol: "K",   flag: "🇲🇲", name: "Myanmar Kyat"),
    Currency(code: "MNT", symbol: "₮",   flag: "🇲🇳", name: "Mongolian Tugrik"),
    Currency(code: "MUR", symbol: "₨",   flag: "🇲🇺", name: "Mauritian Rupee"),
    Currency(code: "MVR", symbol: "Rf",  flag: "🇲🇻", name: "Maldivian Rufiyaa"),
    Currency(code: "MXN", symbol: "$",   flag: "🇲🇽", name: "Mexican Peso"),
    Currency(code: "MYR", symbol: "RM",  flag: "🇲🇾", name: "Malaysian Ringgit"),
    Currency(code: "MZN", symbol: "MT",  flag: "🇲🇿", name: "Mozambican Metical"),
    Currency(code: "NAD", symbol: "N$",  flag: "🇳🇦", name: "Namibian Dollar"),
    Currency(code: "NGN", symbol: "₦",   flag: "🇳🇬", name: "Nigerian Naira"),
    Currency(code: "NIO", symbol: "C$",  flag: "🇳🇮", name: "Nicaraguan Córdoba"),
    Currency(code: "NOK", symbol: "kr",  flag: "🇳🇴", name: "Norwegian Krone"),
    Currency(code: "NPR", symbol: "₨",   flag: "🇳🇵", name: "Nepalese Rupee"),
    Currency(code: "NZD", symbol: "NZ$", flag: "🇳🇿", name: "New Zealand Dollar"),
    Currency(code: "OMR", symbol: "﷼",   flag: "🇴🇲", name: "Omani Rial"),
    Currency(code: "PAB", symbol: "B/.", flag: "🇵🇦", name: "Panamanian Balboa"),
    Currency(code: "PEN", symbol: "S/.", flag: "🇵🇪", name: "Peruvian Sol"),
    Currency(code: "PHP", symbol: "₱",   flag: "🇵🇭", name: "Philippine Peso"),
    Currency(code: "PKR", symbol: "₨",   flag: "🇵🇰", name: "Pakistani Rupee"),
    Currency(code: "PLN", symbol: "zł",  flag: "🇵🇱", name: "Polish Zloty"),
    Currency(code: "PYG", symbol: "₲",   flag: "🇵🇾", name: "Paraguayan Guarani"),
    Currency(code: "QAR", symbol: "﷼",   flag: "🇶🇦", name: "Qatari Riyal"),
    Currency(code: "RON", symbol: "lei", flag: "🇷🇴", name: "Romanian Leu"),
    Currency(code: "RSD", symbol: "din", flag: "🇷🇸", name: "Serbian Dinar"),
    Currency(code: "RUB", symbol: "₽",   flag: "🇷🇺", name: "Russian Ruble"),
    Currency(code: "RWF", symbol: "Fr",  flag: "🇷🇼", name: "Rwandan Franc"),
    Currency(code: "SAR", symbol: "﷼",   flag: "🇸🇦", name: "Saudi Riyal"),
    Currency(code: "SDG", symbol: "£",   flag: "🇸🇩", name: "Sudanese Pound"),
    Currency(code: "SEK", symbol: "kr",  flag: "🇸🇪", name: "Swedish Krona"),
    Currency(code: "SGD", symbol: "S$",  flag: "🇸🇬", name: "Singapore Dollar"),
    Currency(code: "SOS", symbol: "S",   flag: "🇸🇴", name: "Somali Shilling"),
    Currency(code: "SYP", symbol: "£",   flag: "🇸🇾", name: "Syrian Pound"),
    Currency(code: "THB", symbol: "฿",   flag: "🇹🇭", name: "Thai Baht"),
    Currency(code: "TJS", symbol: "SM",  flag: "🇹🇯", name: "Tajikistani Somoni"),
    Currency(code: "TMT", symbol: "T",   flag: "🇹🇲", name: "Turkmenistani Manat"),
    Currency(code: "TND", symbol: "DT",  flag: "🇹🇳", name: "Tunisian Dinar"),
    Currency(code: "TRY", symbol: "₺",   flag: "🇹🇷", name: "Turkish Lira"),
    Currency(code: "TTD", symbol: "TT$", flag: "🇹🇹", name: "Trinidad and Tobago Dollar"),
    Currency(code: "TWD", symbol: "NT$", flag: "🇹🇼", name: "New Taiwan Dollar"),
    Currency(code: "TZS", symbol: "TSh", flag: "🇹🇿", name: "Tanzanian Shilling"),
    Currency(code: "UAH", symbol: "₴",   flag: "🇺🇦", name: "Ukrainian Hryvnia"),
    Currency(code: "UGX", symbol: "USh", flag: "🇺🇬", name: "Ugandan Shilling"),
    Currency(code: "USD", symbol: "$",   flag: "🇺🇸", name: "US Dollar"),
    Currency(code: "UYU", symbol: "$U",  flag: "🇺🇾", name: "Uruguayan Peso"),
    Currency(code: "UZS", symbol: "лв",  flag: "🇺🇿", name: "Uzbekistani Som"),
    Currency(code: "VES", symbol: "Bs.F",flag: "🇻🇪", name: "Venezuelan Bolívar"),
    Currency(code: "VND", symbol: "₫",   flag: "🇻🇳", name: "Vietnamese Dong"),
    Currency(code: "XAF", symbol: "Fr",  flag: "🇨🇲", name: "Central African CFA Franc"),
    Currency(code: "XOF", symbol: "Fr",  flag: "🇸🇳", name: "West African CFA Franc"),
    Currency(code: "YER", symbol: "﷼",   flag: "🇾🇪", name: "Yemeni Rial"),
    Currency(code: "ZAR", symbol: "R",   flag: "🇿🇦", name: "South African Rand"),
    Currency(code: "ZMW", symbol: "ZK",  flag: "🇿🇲", name: "Zambian Kwacha"),
]
