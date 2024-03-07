//
//  TransactionView.swift
//  ExpenseTrackApp
//
//  Created by ARTEM on 06.03.2024.
//

import UIKit

class TransactionView: UIView {

    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "10 BTC"
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    let imageTransactionSize = 35
    lazy var transactionImage: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .black
        imageView.layer.cornerRadius = CGFloat(imageTransactionSize / 2)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    //Stack View for amount of BTC and type of transaction
    private lazy var amountStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [amountLabel, transactionImage])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 5
        stack.distribution = .fillProportionally
        return stack
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "22 Feb 2024"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "taxi"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    //Stack 
    private lazy var dateCategoryStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [dateLabel, categoryLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 20
        return stack
    }()
    
    
    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [amountStackView, dateCategoryStackView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 5
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    func setup(){
        self.layer.cornerRadius = 10
        self.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(mainStackView)
        let imageViewWidthConstraint = NSLayoutConstraint(item: transactionImage, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: CGFloat(imageTransactionSize))
        let imageViewHeightConstraint = NSLayoutConstraint(item: transactionImage, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: CGFloat(imageTransactionSize))
        transactionImage.addConstraints([imageViewWidthConstraint, imageViewHeightConstraint])
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            mainStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            mainStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            mainStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
        ])
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setView(amount: Double, category: Categories.RawValue, date: Date, transactionImage: UIImage?){
        self.amountLabel.text = "\(amount) BTC"
        self.categoryLabel.text = Categories(rawValue: category)?.name
        self.transactionImage.image = transactionImage
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm dd MMM yyyy"
        let dateString = dateFormatter.string(from: date)
        self.dateLabel.text = dateString
    }
    
}
