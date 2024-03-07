//
//  PopUpAddBalanceDelegate.swift
//  ExpenseTrackApp
//
//  Created by ARTEM on 07.03.2024.
//

import Foundation

protocol PopUpAddBalanceDelegate: AnyObject{
    // Add bitcoin to Balance
    func addBalance(amount: Double)
}
