//
//  Model.swift
//  ExpenseTrackApp
//
//  Created by ARTEM on 05.03.2024.
//

import Foundation

// Model for decode Json

struct BitcoinCurrency: Codable{
    let bpi: BPI
}

struct BPI: Codable{
    let USD: Usd
}

struct Usd: Codable{
    let rate: String
}

