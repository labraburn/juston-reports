//
//  Created by Anton Spivak
//

import Foundation
import CoreData
import SwiftyTON

@objc(PersistenceTransaction)
public class PersistenceTransaction: PersistenceObject {
    
    /// Create and insert into main context
    @MainActor
    public convenience init(
        id: Transaction.ID,
        account: PersistenceAccount,
        date: Date
    ) {
        self.init()
        self.id = id
        self.account = account
        self.date = date
    }
}

extension PersistenceTransaction {
    
    public var id: Transaction.ID {
        get {
            Transaction.ID(
                value: raw_identifier,
                hash: Data(hex: raw_hash)
            )
        }
        set {
            raw_identifier = newValue.value
            raw_hash = newValue.hash.toHexString()
        }
    }
    
    public var fromAddress: Address.RawAddress {
        get {
            Address.RawAddress(rawValue: raw_from_address)!
        }
        set {
            raw_from_address = newValue.rawValue
        }
    }
    
    public var toAddresses: [Address.RawAddress] {
        get {
            raw_to_addresses.compactMap({ Address.RawAddress(rawValue: $0) })
        }
        set {
            raw_to_addresses = newValue.map({ $0.rawValue })
        }
    }
    
    @NSManaged public var date: Date?
    @NSManaged public var account: PersistenceAccount?
    @NSManaged public var value: NSDecimalNumber
    @NSManaged public var fees: NSDecimalNumber
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PersistenceTransaction> {
        return NSFetchRequest<PersistenceTransaction>(entityName: "PersistenceTransaction")
    }
    
    @nonobjc public class func fetchRequest(
        id: Transaction.ID
    ) -> NSFetchRequest<PersistenceTransaction> {
        let request = NSFetchRequest<PersistenceTransaction>(entityName: "PersistenceTransaction")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "raw_identifier == %i", id.value),
            NSPredicate(format: "raw_hash == %@", id.hash.toHexString()),
        ])
        return request
    }
    
    @nonobjc public class func fetchRequest(
        account: PersistenceAccount
    ) -> NSFetchRequest<PersistenceTransaction> {
        let request = NSFetchRequest<PersistenceTransaction>(entityName: "PersistenceTransaction")
        request.predicate = NSPredicate(format: "account == %@", account)
        return request
    }
    
    @nonobjc public class func fetchedResultsController(
        request: NSFetchRequest<PersistenceTransaction>
    ) -> NSFetchedResultsController<PersistenceTransaction> {
        let viewContext = PersistenceController.shared.viewContext
        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
    
    // MARK: Internal
    
    @NSManaged private var raw_identifier: Int64
    @NSManaged private var raw_hash: String
    @NSManaged private var raw_from_address: String
    @NSManaged private var raw_to_addresses: [String]
}
