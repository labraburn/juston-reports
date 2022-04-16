//
//  Created by Anton Spivak
//

import Foundation
import CoreData
import SwiftyTON

@objc(PersistenceAccount)
public class PersistenceAccount: PersistenceObject {
    
    /// Create and insert into main context
    @MainActor
    public convenience init(
        rawAddress: Address.RawAddress,
        name: String,
        appearance: AccountAppearance
    ) {
        self.init()
        self.name = name
        self.rawAddress = rawAddress
        self.appearance = appearance
    }
}

extension PersistenceAccount {
    
    public var appearance: AccountAppearance {
        get {
            raw_appearance as! AccountAppearance
        }
        set {
            raw_appearance = newValue
        }
    }
    
    public var rawAddress: Address.RawAddress {
        get {
            Address.RawAddress(rawValue: raw_address)!
        }
        set {
            raw_address = newValue.rawValue
        }
    }
    
    @NSManaged public var name: String
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
            NSPredicate(format: "raw_address == %@", rawAddress.rawValue),
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
    
    @NSManaged private var raw_address: String
    @NSManaged private var raw_appearance: Any
}
