//
//  TransactionType.swift
//  ExpenseTrackApp
//
//  Created by ARTEM on 07.03.2024.
//

import Foundation
import UIKit

// Enum fot category of transaction income or expense
enum TransactionType: Int16{
    
    case expense = 0
    case income = 1
    
    // Image of transaction type
    var image: UIImage? {
        switch self {
        case .expense:
            return UIImage(systemName: "arrow.down.circle.fill")
        case .income:
            return UIImage(systemName: "arrow.up.circle.fill")
        }
    }
}
