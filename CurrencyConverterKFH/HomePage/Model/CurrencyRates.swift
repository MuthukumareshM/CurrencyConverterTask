//
//  CurrencyRates.swift
//  CurrencyConverterKFH
//
//  Created by Muthukumaresh, Muthuvel (M.) on 01/08/23.
//

import Foundation

struct CurrencyRatesModel: Codable {
    let base, date: String
    let rates: [String: Double]
    let success: Bool
    let timestamp: Int
}

struct Rates: Codable {
    let countryCode: String
    let countryCurrencyRate: Double
}

