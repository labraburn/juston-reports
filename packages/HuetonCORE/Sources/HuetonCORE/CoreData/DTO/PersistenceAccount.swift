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
        self.subscriptions = []
    }
}

extension PersistenceAccount {
    
    public var appearance: AccountAppearance {
        set { raw_appearance = newValue }
        get {
            guard let appearance = raw_appearance as? AccountAppearance
            else {
                fatalError("Looks like data is fault.")
            }
            return appearance
        }
    }
    
    public var rawAddress: Address.RawAddress {
        set { raw_address = newValue.rawValue }
        get {
            guard let rawAddress = Address.RawAddress(rawValue: raw_address)
            else {
                fatalError("Looks like data is fault.")
            }
            return rawAddress
        }
    }
    
    public var subscriptions: [AccountSubscription] {
        set { raw_subscriptions = newValue }
        get {
            guard let subscriptions = raw_subscriptions as? [AccountSubscription]
            else {
                return []
            }
            return subscriptions
        }
    }
    
    @NSManaged
    public var name: String
    
    @NSManaged
    public var synchronizationDate: Date?
    
    @NSManaged
    public var balance: NSDecimalNumber
    
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<PersistenceAccount> {
        return NSFetchRequest<PersistenceAccount>(entityName: "PersistenceAccount")
    }
    
    @nonobjc
    public class func fetchRequest(
        rawAddress: Address.RawAddress
    ) -> NSFetchRequest<PersistenceAccount> {
        let request = NSFetchRequest<PersistenceAccount>(entityName: "PersistenceAccount")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "raw_address == %@", rawAddress.rawValue),
        ])
        return request
    }
    
    @nonobjc
    public class func fetchedResultsController(
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
    
    /// -1:00000000000000
    @NSManaged
    private var raw_address: String
    
    /// AccountAppearanceTransformer
    @NSManaged
    private var raw_appearance: Any
    
    /// AccountSubscriptionArrayTransformer
    @NSManaged
    private var raw_subscriptions: Any
}
