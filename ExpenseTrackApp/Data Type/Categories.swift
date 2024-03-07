//
//  Categories.swift
//  ExpenseTrackApp
//
//  Created by ARTEM on 06.03.2024.
//

import Foundation

// Enum for categories of expenses
enum Categories: Int16, CaseIterable{
    case groceries = 0
    case taxi = 1
    case electronics = 2
    case restaurant = 3
    case other = 4
    
    //Category name
    var name: String{
        return "\(self)"
    }
}
