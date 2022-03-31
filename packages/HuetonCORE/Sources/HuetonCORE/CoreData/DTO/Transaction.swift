//
//  Created by Anton Spivak
//

import Foundation
import CoreData

@objc(Transaction)
public class Transaction: PersistenceObject {
    
    public convenience init(shouldInsertIntoViewContext: Bool = false, date: Date, account: Account) {
        self.init(shouldInsertIntoViewContext: shouldInsertIntoViewContext)
        self.date = date
        self.account = account
    }
}

extension Transaction {
    
    @NSManaged public var date: Date?
    @NSManaged public var account: Account?
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }
    
    @nonobjc public class func fetchedResultsController(
        request: NSFetchRequest<Transaction>
    ) -> NSFetchedResultsController<Transaction> {
        let viewContext = PersistenceController.shared.viewContext
        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
}
