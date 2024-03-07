//
//  PopUpAddBalance.swift
//  ExpenseTrackApp
//
//  Created by ARTEM on 06.03.2024.
//

import UIKit

class PopUpAddBalance: UIView, UITextFieldDelegate {

    // Pop up delegate
    weak var popUpAddBalanceDelegate: PopUpAddBalanceDelegate?
    
    //Container contstraint center Y
    private var containerCenterYConstraint: NSLayoutConstraint!
    
    // Title Label
    private lazy var titlelabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.text = "Enter count of BTC to add"
        label.textAlignment = .center
        return label
    }()
    
    // Text field for amount of BTC
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.placeholder = "Enter amount of BTC"
        return textField
    }()
    
    // Submit transaction button
    private lazy var submitButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(submitAddBalance), for: .touchUpInside)
        return button
    }()
    
    // Vertical stack for all UIViews
    private lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titlelabel, textField, submitButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 15
        return stack
    }()
    
    //Container for all views
    private lazy var container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        return view
    }()
    
    
    // Right top close button
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.backgroundColor = .white
        let config = UIImage.SymbolConfiguration(pointSize: 25)
        button.setImage(UIImage.init(systemName: "xmark", withConfiguration: config), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(closePopUpView), for: .touchUpInside)
        button.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        self.frame = UIScreen.main.bounds
        
        // Notifications for when the keyboard opens/closes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
        
        // Add UI elements
        self.addSubview(container)
        containerCenterYConstraint = container.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        NSLayoutConstraint.activate([
            containerCenterYConstraint,
            container.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            container.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.7),
            container.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.3)
        ])
        
        container.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            stack.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 10),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
        ])
        
        textField.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Remove observers
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Right top xmark action
    @objc func closePopUpView(sender: UIButton){
        self.closePopUp()
    }
    
    // Submit transaction action
    @objc func submitAddBalance(sender: UIButton){
        guard let amountText = self.textField.text, !amountText.isEmpty else {
            // Show an alert because the amount is empty
            let alert = UIAlertController(title: "Error", message: "Please enter an amount.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            if let viewController = self.firstAvailableViewController() {
                viewController.present(alert, animated: true, completion: nil)
            }
            return
        }

        let amount: Double = (amountText as NSString).doubleValue
        self.popUpAddBalanceDelegate?.addBalance(amount: amount)
        self.closePopUp()
    }
    
    // Close Pop Up action
    private func closePopUp(){
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0.0
        }) { _ in
            self.removeFromSuperview()
            self.textField.text = ""
        }
    }
    
    // Action to move pop up on keyboard opening
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        if textField.isEditing{
            moveViewWithKeyboard(notification: notification, viewBottomConstraint: self.containerCenterYConstraint, keyboardWillShow: true)
        }
    }

    // Action to move pop up back on keybord closing
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        moveViewWithKeyboard(notification: notification, viewBottomConstraint: self.containerCenterYConstraint, keyboardWillShow: false)
    }
    
    func moveViewWithKeyboard(notification: NSNotification, viewBottomConstraint: NSLayoutConstraint, keyboardWillShow: Bool) {
            
            // Keyboard's animation duration
        let keyboardDuration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
            
            // Keyboard's animation curve
        let keyboardCurve = UIView.AnimationCurve(rawValue: notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! Int)!
            
            // Change the constant
        if keyboardWillShow {
            viewBottomConstraint.constant = -100
        }else {
            viewBottomConstraint.constant = 0
        }
            
        let animator = UIViewPropertyAnimator(duration: keyboardDuration, curve: keyboardCurve) { [weak self] in
            self?.container.layoutIfNeeded()
        }
            
        animator.startAnimation()
    }
    
    // Allow the user to enter only numbers and a dot
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

// Extension to show Error Alert
extension UIView {
    func firstAvailableViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let currentResponder = responder {
            if let viewController = currentResponder as? UIViewController {
                return viewController
            }
            responder = currentResponder.next
        }
        return nil
    }
}
