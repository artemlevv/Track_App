//
//  AddTransactionVCDelegate.swift
//  ExpenseTrackApp
//
//  Created by ARTEM on 07.03.2024.
//

import Foundation

protocol AddTransactionVCDelegate: AnyObject{
    
    // Add expense
    func addExpenseTransaction(amount: Double, category: Categories.RawValue)
    // Checking enough amount fo Bitcoin on Balance
    func checkEnoughBitcoin(amount: Double) -> Bool
}
