//
//  TopView.swift
//  ExpenseTrackApp
//
//  Created by ARTEM on 05.03.2024.
//

import UIKit

class TopView: UIView {
    
    private lazy var addTransactionButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Add transaction"
        config.baseBackgroundColor = .blue
        config.baseForegroundColor = .white
        config.buttonSize = .large
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: .semibold)
        button.addTarget(self, action: #selector(didTapAddTransaction), for: .touchUpInside)
        return button
    }()
    
    lazy var balanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "10 BTC"
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        return label
    }()
    
    private lazy var addBalanceButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Top Up"
        config.baseBackgroundColor = .blue
        config.baseForegroundColor = .white
        config.buttonSize = .medium
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapAddBalance), for: .touchUpInside)
        return button
    }()
    
    private lazy var balanceStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 5
        return stack
    }()
    
    private var addBalanceAction: () -> ()
    private var addTransactionAction: () -> ()
    
    init(addBalanceAction: @escaping () -> (), addTransactionAction: @escaping () -> ()){
        self.addBalanceAction = addBalanceAction
        self.addTransactionAction = addTransactionAction
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        self.layer.cornerRadius = 10
        self.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(balanceStackView)
        balanceStackView.addArrangedSubview(balanceLabel)
        balanceStackView.addArrangedSubview(addBalanceButton)
        self.addSubview(addTransactionButton)
        
        
        NSLayoutConstraint.activate([
            balanceStackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 8),
            balanceStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            balanceStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            addTransactionButton.topAnchor.constraint(equalTo: balanceStackView.bottomAnchor, constant: 10),
            addTransactionButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            addTransactionButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            addTransactionButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
        ])
    }
    
    @objc func didTapAddBalance(sender: UIButton){
        addBalanceAction()
    }
    
    @objc func didTapAddTransaction(sender: UIButton){
        addTransactionAction()
    }
}
