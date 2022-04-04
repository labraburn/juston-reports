//
//  Created by Anton Spivak
//

import Foundation
import CoreData
import SwiftyTON

@objc(PersistenceAccount)
public class PersistenceAccount: PersistenceObject {
    
    /// Create and insert into main context
    public convenience init(
        rawAddress: Address.RawAddress,
        name: String
    ) {
        self.init()
        self.rawAddress = rawAddress
        self.name = name
    }
}

extension PersistenceAccount {
    
    public var rawAddress: Address.RawAddress {
        get {
            Address.RawAddress(
                workchain: raw_workchain,
                hash: [UInt8](hex: raw_address)
            )
        }
        set {
            raw_workchain = newValue.workchain
            raw_address = newValue.hash.toHexString()
        }
    }
    
    @NSManaged public var name: String
    @NSManaged public var transactions: NSArray
    @NSManaged public var synchronizationDate: Date?
    @NSManaged public var balance: NSDecimalNumber
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PersistenceAccount> {
        return NSFetchRequest<PersistenceAccount>(entityName: "PersistenceAccount")
    }
    
    @nonobjc public class func fetchRequest(
        rawAddress: Address.RawAddress
    ) -> NSFetchRequest<PersistenceAccount> {
        let request = NSFetchRequest<PersistenceAccount>(entityName: "PersistenceAccount")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "raw_workchain == %i", rawAddress.workchain),
            NSPredicate(format: "raw_address == %@", rawAddress.hash.toHexString()),
        ])
        return request
    }
    
    @nonobjc public class func fetchedResultsController(
        request: NSFetchRequest<PersistenceAccount>
    ) -> NSFetchedResultsController<PersistenceAccount> {
        let viewContext = PersistenceController.shared.viewContext
        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
    
    // MARK: Internal
    
    @NSManaged private var raw_workchain: Int32
    @NSManaged private var raw_address: String
}

extension PersistenceAccount {

    @objc(insertObject:inTransactionsAtIndex:)
    @NSManaged public func insertIntoTransactions(_ value: PersistenceTransaction, at idx: Int)

    @objc(removeObjectFromTransactionsAtIndex:)
    @NSManaged public func removeFromTransactions(at idx: Int)

    @objc(insertTransactions:atIndexes:)
    @NSManaged public func insertIntoTransactions(_ values: [PersistenceTransaction], at indexes: NSIndexSet)

    @objc(removeTransactionsAtIndexes:)
    @NSManaged public func removeFromTransactions(at indexes: NSIndexSet)

    @objc(replaceObjectInTransactionsAtIndex:withObject:)
    @NSManaged public func replaceTransactions(at idx: Int, with value: PersistenceTransaction)

    @objc(replaceTransactionsAtIndexes:withTransactions:)
    @NSManaged public func replaceTransactions(at indexes: NSIndexSet, with values: [PersistenceTransaction])

    @objc(addTransactionsObject:)
    @NSManaged public func addToTransactions(_ value: PersistenceTransaction)

    @objc(removeTransactionsObject:)
    @NSManaged public func removeFromTransactions(_ value: PersistenceTransaction)

    @objc(addTransactions:)
    @NSManaged public func addToTransactions(_ values: NSOrderedSet)

    @objc(removeTransactions:)
    @NSManaged public func removeFromTransactions(_ values: NSOrderedSet)
}
