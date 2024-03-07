//
//  CoreDataService.swift
//  ExpenseTrackApp
//
//  Created by ARTEM on 07.03.2024.
//

import Foundation
import CoreData

final class CoreDataService: NSObject, NSFetchedResultsControllerDelegate{
    // MARK: - Properties
    private let coreDataStack: CoreDataStack
    
    // Balance
    private(set) var balance: Balance!
    
    //Bitcoin Rate
    private(set) var bitcoinRate: BitcoinRate?
    var bitcoinRateDidChange: ((BitcoinRate?) -> Void)?
    
    // Pagination Data
    private let stateLimitPagination = 20
    private var fetchLimit: Int = 20
    private var fetchOffset: Int = 0
    
    // Fetched result controller
    var fetchedResultsController: NSFetchedResultsController<TransactionItem>!
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
        super.init()
        self.balance = getBalance()
        self.setupFetchedResultsController()
        self.bitcoinRate = getBitcoinRate()
    }
    
    // Get Balance from database
    func getBalance() -> Balance?{
        let fetchRequest: NSFetchRequest<Balance> = Balance.fetchRequest()
        do{
            let results = try coreDataStack.managedContext.fetch(fetchRequest)
            
            var balance: Balance
            if results.count > 0 {
                balance = results.first!
            } else{
                balance = Balance(context: coreDataStack.managedContext)
                balance.amount = 0
                coreDataStack.saveContext()
            }
            return balance
        } catch{
            print("Error fetching data: \(error)")
        }
        return nil
    }
    
    // Get Bitcoin rate fot database
    func getBitcoinRate() -> BitcoinRate?{
        let fetchRequest: NSFetchRequest<BitcoinRate> = BitcoinRate.fetchRequest()
        do{
            let results = try coreDataStack.managedContext.fetch(fetchRequest)
            
            var bitcoinRate: BitcoinRate
            if results.count > 0 {
                bitcoinRate = results.first!
            } else{
                bitcoinRate = BitcoinRate(context: coreDataStack.managedContext)
                bitcoinRate.bitcoinRate = "0"
                bitcoinRate.lastTimeUpdate = nil
                coreDataStack.saveContext()
            }
            return bitcoinRate
        } catch{
            print("Error fetching data: \(error)")
        }
        return nil
    }
    
    // Update balance
    func updateBalance(amount: Double){
        let newBalance = balance.amount + amount
        if newBalance >= 0{
            balance.amount = newBalance
            coreDataStack.saveContext()
        }
    }
    
    // Update bitcoin rate
    func updateBitcoinRate(rate: String){
        bitcoinRate?.bitcoinRate = rate
        bitcoinRate?.lastTimeUpdate = Date.now
        coreDataStack.saveContext()
        bitcoinRateDidChange?(bitcoinRate)
    }
    
    //  Set up fetched result controller
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TransactionItem> = TransactionItem.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.fetchBatchSize = fetchLimit
        fetchRequest.returnsObjectsAsFaults = true
        fetchRequest.fetchLimit = fetchLimit
        fetchRequest.fetchOffset = fetchOffset
        

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataStack.managedContext,
            sectionNameKeyPath: "sectionIdentifier",
            cacheName: nil
        )
        fetchedResultsController.delegate = self

        do {
            NSFetchedResultsController<TransactionItem>.deleteCache(withName: fetchedResultsController.cacheName)
            try fetchedResultsController.performFetch()
        } catch {
            print("Error fetching data: \(error)")
        }
    }
    
    // Save new transaction
    func saveNewTransaction(sum: Double, category: Categories.RawValue?, transactionType: TransactionType.RawValue){
        let transaction = TransactionItem(context: coreDataStack.managedContext)
        transaction.id = UUID()
        if let category = category{
            transaction.category = category
        }
        transaction.date = Date.now
        transaction.sum = sum
        transaction.transactionType = transactionType
        coreDataStack.saveContext()
        updateFetchedResultController()
        
        if TransactionType.init(rawValue: transactionType) == .income{
            self.updateBalance(amount: sum)
        } else if TransactionType.init(rawValue: transactionType) == .expense{
            self.updateBalance(amount: -sum)
        }
    }
    
    // Update Fetched result controller
    func updateFetchedResultController() {
        do {
            NSFetchedResultsController<TransactionItem>.deleteCache(withName: fetchedResultsController.cacheName)
            try fetchedResultsController.performFetch()
        } catch {
            print("Error fetching data: \(error)")
        }
    }
    
    // Load next data on pagination
    func loadNext() {
        self.fetchLimit += stateLimitPagination
        
        fetchedResultsController.fetchRequest.fetchOffset = self.fetchOffset
        fetchedResultsController.fetchRequest.fetchLimit = self.fetchLimit
        do {
            NSFetchedResultsController<TransactionItem>.deleteCache(withName: fetchedResultsController.cacheName)
            try fetchedResultsController.performFetch()
        } catch {
            print("Error fetching data: \(error)")
        }
    }
}
