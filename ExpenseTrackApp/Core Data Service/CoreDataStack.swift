//
//  CoreDataService.swift
//  ExpenseTrackApp
//
//  Created by ARTEM on 07.03.2024.
//

import Foundation
import CoreData

class CoreDataStack {
    static let modelName = "ExpenseTrackApp"
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: CoreDataStack.modelName)
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var managedContext: NSManagedObjectContext = {
      return persistentContainer.viewContext
    }()
    
    init(){}
    
    func saveContext() {
      guard managedContext.hasChanges else { return }
      
      do {
        try managedContext.save()
      }
      catch let error as NSError {
        print("Error: \(error), \(error.userInfo)")
      }
    }
}

// Section identifier fot Transactions
extension TransactionItem {
    @objc var sectionIdentifier: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date!)
    }
}
