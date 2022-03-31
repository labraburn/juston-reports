//
//  Created by Anton Spivak
//

import Foundation
import CoreData
import SwiftyTON

@objc(Account)
public class Account: PersistenceObject {
    
    public convenience init(shouldInsertIntoViewContext: Bool = false, rawAddress: Address.RawAddress, name: String) {
        self.init(shouldInsertIntoViewContext: shouldInsertIntoViewContext)
        self.rawAddress = rawAddress
        self.name = name
    }
}

extension Account {
    
    public var rawAddress: Address.RawAddress {
        get {
            .init(workchain: workchain, hash: address)
        }
        set {
            workchain = newValue.workchain
            address = newValue.hash
        }
    }
    
    @NSManaged private var workchain: Int32
    @NSManaged private var address: [UInt8]
    
    @NSManaged public var name: String
    @NSManaged public var transactions: NSArray
    @NSManaged public var balance: NSDecimalNumber
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Account> {
        return NSFetchRequest<Account>(entityName: "Account")
    }
    
    @nonobjc public class func fetchedResultsController(
        request: NSFetchRequest<Account>
    ) -> NSFetchedResultsController<Account> {
        let viewContext = PersistenceController.shared.viewContext
        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
}

extension Account {

    @objc(insertObject:inTransactionsAtIndex:)
    @NSManaged public func insertIntoTransactions(_ value: Transaction, at idx: Int)

    @objc(removeObjectFromTransactionsAtIndex:)
    @NSManaged public func removeFromTransactions(at idx: Int)

    @objc(insertTransactions:atIndexes:)
    @NSManaged public func insertIntoTransactions(_ values: [Transaction], at indexes: NSIndexSet)

    @objc(removeTransactionsAtIndexes:)
    @NSManaged public func removeFromTransactions(at indexes: NSIndexSet)

    @objc(replaceObjectInTransactionsAtIndex:withObject:)
    @NSManaged public func replaceTransactions(at idx: Int, with value: Transaction)

    @objc(replaceTransactionsAtIndexes:withTransactions:)
    @NSManaged public func replaceTransactions(at indexes: NSIndexSet, with values: [Transaction])

    @objc(addTransactionsObject:)
    @NSManaged public func addToTransactions(_ value: Transaction)

    @objc(removeTransactionsObject:)
    @NSManaged public func removeFromTransactions(_ value: Transaction)

    @objc(addTransactions:)
    @NSManaged public func addToTransactions(_ values: NSOrderedSet)

    @objc(removeTransactions:)
    @NSManaged public func removeFromTransactions(_ values: NSOrderedSet)
}
