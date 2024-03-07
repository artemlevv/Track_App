//
//  AddTransactionViewController.swift
//  ExpenseTrackApp
//
//  Created by ARTEM on 06.03.2024.
//

import Foundation
import UIKit

class AddTransactionViewController: UIViewController{
    
    // Add Transaction VC delegate
    weak var addTransactionVCDelegate: AddTransactionVCDelegate?
    
    // Tite Label
    private lazy var titlelabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 25)
        label.text = "Add an expense transaction"
        label.textAlignment = .center
        return label
    }()
    
    // Ctaegory picker
    private lazy var categoriesPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        return pickerView
    }()
    
    
    // Amount text field
    private lazy var amountTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter amount"
        
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOpacity = 0.5
        textField.layer.shadowOffset = CGSize(width: 0, height: 2)
        textField.layer.shadowRadius = 4
        return textField
    }()
    
    // Submit button
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 25)
        button.backgroundColor = .blue
        button.tintColor = .white
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // Top right corner button
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.backgroundColor = .white
        let config = UIImage.SymbolConfiguration(pointSize: 25)
        button.setImage(UIImage.init(systemName: "xmark", withConfiguration: config), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(closeAddView), for: .touchUpInside)
        button.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
        return button
    }()
    
    // Data Source for picker
    let categoriesDataSource = Categories.allCases.map { $0.name }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        categoriesPickerView.delegate = self
        categoriesPickerView.dataSource = self
        amountTextField.delegate = self
        setUp()
    }
    
    // UI set up
    private func setUp(){
        self.view.addSubview(titlelabel)
        self.view.addSubview(categoriesPickerView)
        self.view.addSubview(amountTextField)
        self.view.addSubview(addButton)
        NSLayoutConstraint.activate([
            titlelabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titlelabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            categoriesPickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            categoriesPickerView.topAnchor.constraint(equalTo: titlelabel.bottomAnchor, constant: 3),
            
           
            amountTextField.topAnchor.constraint(equalTo: categoriesPickerView.bottomAnchor, constant: 10),
            amountTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            amountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 25),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        self.view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    
    // Submit action
    @objc private func addButtonTapped() {
        guard let amountText = self.amountTextField.text, !amountText.isEmpty else {
            // Show an alert because the amount is empty
            let alert = UIAlertController(title: "Error", message: "Please enter an amount.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            return
        }

        let category = Categories.RawValue(categoriesPickerView.selectedRow(inComponent: 0))
        let amount: Double = (amountText as NSString).doubleValue
        
        guard let checkEnough = self.addTransactionVCDelegate?.checkEnoughBitcoin(amount: amount) else {
            // Show an alert on error
            let alert = UIAlertController(title: "Error", message: "Some error occurs", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            return
        }
        
        //Checking whether the user has a sufficient balance for expense
        guard checkEnough else{
            // Show an alert because not enough balance
            let alert = UIAlertController(title: "Error", message: "Not enough money on balance", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            return
        }
                
        self.addTransactionVCDelegate?.addExpenseTransaction(amount: amount, category: category)
        self.dismiss(animated: true, completion: nil)
        self.amountTextField.text = ""
    }
    
    // close action
    @objc private func closeAddView(){
        self.dismiss(animated: true, completion: nil)
        self.amountTextField.text = ""
    }
}

// Picker delegate and datasource
extension AddTransactionViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoriesDataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoriesDataSource[row]
    }
}

// Allow the user to enter only numbers and a dot
extension AddTransactionViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let inverseSet = NSCharacterSet(charactersIn:"0123456789").inverted

        let components = string.components(separatedBy: inverseSet)

        let filtered = components.joined(separator: "")

        if filtered == string {
            return true
        } else {
            if string == "." {
                let countdots = textField.text!.components(separatedBy:".").count - 1
                if countdots == 0 {
                    return true
                }else{
                    if countdots > 0 && string == "." {
                        return false
                    } else {
                        return true
                    }
                }
            }else{
                return false
            }
        }
    }
}
