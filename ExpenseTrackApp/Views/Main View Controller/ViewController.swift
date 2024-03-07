//
//  ViewController.swift
//  ExpenseTrackApp
//
//  Created by ARTEM on 05.03.2024.
//

import UIKit
import CoreData

class ViewController: UIViewController{
    
    private var addTransactionVC: AddTransactionViewController = AddTransactionViewController()
    
    //MARK: - Top View with Balance and "Top up" button nad "Add Transaction Button"
    private lazy var topView: TopView = {
        let view = TopView(addBalanceAction: { [weak self] in
            self?.showPopupApp()
        }, addTransactionAction: { [weak self] in
            guard let self = self else{return}
            addTransactionVC.modalPresentationStyle = .popover
            if let popoverController = addTransactionVC.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
                
                // Present the view controller
                self.present(addTransactionVC, animated: true, completion: nil)
            }
        })
        return view
    }()
    
    //MARK: - Pop up to Add Balance
    private lazy var popUpAddBalance: PopUpAddBalance = PopUpAddBalance()
    
    //MARK: - Bitcoin rate label in top right corner
    let bitcoinRateLabel = UILabel()
    
    //MARK: - Collection View of Transactions
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .init(width: UIScreen.main.bounds.width, height: 130)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TransactionCell.self, forCellWithReuseIdentifier: "TransactionCell")
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    
    //MARK: - Core Data Properties
    var coreDataService: CoreDataService
    
    
    init( coreDataService: CoreDataService ) {
        self.coreDataService = coreDataService
        super.init(nibName: nil, bundle: nil)
        self.coreDataService.bitcoinRateDidChange = { [weak self] bitcoinRate in
            guard let self = self else {return}
            // Update the label text with the new bitcoinRate
            DispatchQueue.main.async {
                if let stringRate = self.coreDataService.bitcoinRate?.bitcoinRate{
                    self.bitcoinRateLabel.text = "1 BTC = \(stringRate) USD"
                    self.bitcoinRateLabel.sizeToFit()
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        self.addTransactionVC.addTransactionVCDelegate = self
        self.popUpAddBalance.popUpAddBalanceDelegate = self
        
        if let stringBalance = coreDataService.balance{
            let formattedBalance = String(format: "%.3f", stringBalance.amount)
            self.topView.balanceLabel.text = "\(formattedBalance) BTC"
        }

    }
    
    func setup(){
        //Set up of top right Bitcoin rate label
        if let stringRate = self.coreDataService.bitcoinRate?.bitcoinRate{
            bitcoinRateLabel.text = "1 BTC = \(stringRate) USD"
        }
        bitcoinRateLabel.font = UIFont.boldSystemFont(ofSize: 14)
        bitcoinRateLabel.sizeToFit()
        let titleBarButtonItem = UIBarButtonItem(customView: bitcoinRateLabel)
        navigationItem.rightBarButtonItem = titleBarButtonItem
        
        self.view.backgroundColor = .white
        
        //Adding for top View
        self.view.addSubview(topView)
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            topView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
        ])
        
        //Adding Collection View
        self.view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 5),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    //Function to show popUp with animation
    func showPopupApp(){
        popUpAddBalance.alpha = 0.0
        self.view.addSubview(popUpAddBalance)

        UIView.animate(withDuration: 0.3) {
            self.popUpAddBalance.alpha = 1.0
        }
    }

}


extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return coreDataService.fetchedResultsController.sections?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = coreDataService.fetchedResultsController.sections else {
            return 0
        }
        return sections[section].numberOfObjects
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let transaction = coreDataService.fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TransactionCell", for: indexPath) as! TransactionCell
        cell.transactionItem = transaction
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeaderView", for: indexPath) as! SectionHeaderView
        headerView.titleLabel.text = coreDataService.fetchedResultsController.sections?[indexPath.section].name
        return headerView
    }
}

extension ViewController: UICollectionViewDelegate {
    
    // Check if the user has stopped dragging
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            loadNext()
        }
    }
    
    // Scrolling has come to a complete stop, initiate the fetch operation
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadNext()
    }

    func loadNext() {
        let lastItem = collectionView.numberOfItems(inSection: 0) - 1
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems

        // Check if the last visible item is the last item in the section
        if let lastVisibleIndexPath = visibleIndexPaths.last, lastVisibleIndexPath.item == lastItem {
            coreDataService.loadNext()
            collectionView.reloadData()
        }
    }
}

extension ViewController: NSFetchedResultsControllerDelegate{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.reloadData()
    }
}

//Delegate for Add Transaction View Controller
extension ViewController: AddTransactionVCDelegate{
    
    func checkEnoughBitcoin(amount: Double) -> Bool {
        return self.coreDataService.balance.amount >= amount
    }
    
    
    func addExpenseTransaction(amount: Double, category: Categories.RawValue) {
        self.coreDataService.saveNewTransaction(sum: amount, category: category, transactionType: TransactionType.expense.rawValue)
        self.collectionView.reloadData()
        if let stringBalance = coreDataService.balance{
            let formattedBalance = String(format: "%.3f", stringBalance.amount)
            self.topView.balanceLabel.text = "\(formattedBalance) BTC"
        }
    }
}

//Delegate for Pop Up View
extension ViewController: PopUpAddBalanceDelegate{
    func addBalance(amount: Double) {
        self.coreDataService.saveNewTransaction(sum: amount, category: nil, transactionType: TransactionType.income.rawValue)
        self.collectionView.reloadData()
        if let stringBalance = coreDataService.balance{
            let formattedBalance = String(format: "%.3f", stringBalance.amount)
            self.topView.balanceLabel.text = "\(formattedBalance) BTC"
        }
    }
    
    
}

// Set Height for UiCOllectionView Header
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
}
