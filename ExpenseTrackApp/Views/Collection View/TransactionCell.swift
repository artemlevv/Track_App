//
//  TransactionCell.swift
//  ExpenseTrackApp
//
//  Created by ARTEM on 06.03.2024.
//

import Foundation
import UIKit

class TransactionCell: UICollectionViewCell{
    
    private var transactionView: TransactionView?
    
    var transactionItem: TransactionItem?{
        didSet{
            guard let amount = transactionItem?.sum,
                  let category = transactionItem?.category,
                  let date = transactionItem?.date,
                  let transactionType = transactionItem?.transactionType
            else{
                return
            }
                    
            transactionView?.setView(amount: amount,
                                     category: category,
                                     date: date, transactionImage: TransactionType.init(rawValue: transactionType)?.image)
            if TransactionType.init(rawValue: transactionType) == .income{
               // transactionView?.tintColor = .green
                transactionView?.transactionImage.tintColor = .green
            } else if TransactionType.init(rawValue: transactionType) == .expense{
                transactionView?.transactionImage.tintColor = .red
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        guard transactionView == nil else {return}
        
        transactionView = TransactionView()
        
        self.contentView.addSubview(transactionView!)
        
        NSLayoutConstraint.activate([
            transactionView!.topAnchor.constraint(equalTo: self.topAnchor),
            transactionView!.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            transactionView!.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            transactionView!.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8)
        ])
        
    }
}
