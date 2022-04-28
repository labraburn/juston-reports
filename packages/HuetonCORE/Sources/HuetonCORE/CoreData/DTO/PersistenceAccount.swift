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
        appearance: AccountAppearance,
        subscriptions: [AccountSubscription],
        flags: Flags
    ) {
        self.init()
        self.name = name
        self.rawAddress = rawAddress
        self.appearance = appearance
        self.subscriptions = subscriptions
        self.flags = flags
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.dateCreated = Date()
    }
    
    @MainActor
    public func saveAsLastSorting() throws {
        let request = Self.fetchRequest()
        let count = (try managedObjectContext?.count(for: request)) ?? 0
        
        self.sortingUserValue = Int64(count) + 1
        
        try managedObjectContext?.save()
    }
    
    @MainActor
    public func saveAsLastUsage() throws {
        let request = Self.fetchRequestSortingUser()
        let accounts = try managedObjectContext?.fetch(request)

        guard let accounts = accounts,
              accounts.count > 0,
              let indexOfSelf = accounts.firstIndex(of: self)
        else {
            return
        }

        var value = Int64(0)
        for i in indexOfSelf ..< accounts.count {
            accounts[i].sortingLastUsageValue = value
            value += 1
        }

        for i in 0 ..< indexOfSelf {
            accounts[i].sortingLastUsageValue = value
            value += 1
        }
        
        guard managedObjectContext?.hasChanges ?? false
        else {
            return
        }

        try managedObjectContext?.save()
    }
}

// MARK: - CoreData Properties

public extension PersistenceAccount {
    
    struct Flags: OptionSet {
        
        public let rawValue: Int64

        public static let readonly = Flags(rawValue: 1 << 0)
        
        public init(rawValue: Int64) {
            self.rawValue = rawValue
        }
    }
    
    var appearance: AccountAppearance {
        set { raw_appearance = newValue }
        get {
            guard let appearance = raw_appearance as? AccountAppearance
            else {
                fatalError("Looks like data is fault.")
            }
            return appearance
        }
    }
    
    var rawAddress: Address.RawAddress {
        set { raw_address = newValue.rawValue }
        get {
            guard let rawAddress = Address.RawAddress(rawValue: raw_address)
            else {
                fatalError("Looks like data is fault.")
            }
            return rawAddress
        }
    }
    
    var subscriptions: [AccountSubscription] {
        set { raw_subscriptions = newValue }
        get {
            guard let subscriptions = raw_subscriptions as? [AccountSubscription]
            else {
                return []
            }
            return subscriptions
        }
    }
    
    var flags: Flags {
        set { raw_flags = newValue.rawValue }
        get { Flags(rawValue: raw_flags) }
    }
    
    @NSManaged var name: String
    @NSManaged var balance: NSDecimalNumber
    
    @NSManaged var dateCreated: Date
    @NSManaged var dateLastSynchronization: Date?
    
    @NSManaged var sortingUserValue: Int64
    @NSManaged var sortingLastUsageValue: Int64
    
    // MARK: Internal
    
    /// OptionSet
    @NSManaged
    private var raw_flags: Int64
    
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

// MARK: - CoreData Methods

public extension PersistenceAccount {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<PersistenceAccount> {
        return NSFetchRequest<PersistenceAccount>(entityName: "PersistenceAccount")
    }
    
    @nonobjc class func fetchRequestSortingLastUsage() -> NSFetchRequest<PersistenceAccount> {
        let fetchRequest = NSFetchRequest<PersistenceAccount>(entityName: "PersistenceAccount")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "sortingLastUsageValue", ascending: true)
        ]
        return fetchRequest
    }
    
    @nonobjc class func fetchRequestSortingUser() -> NSFetchRequest<PersistenceAccount> {
        let fetchRequest = NSFetchRequest<PersistenceAccount>(entityName: "PersistenceAccount")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "sortingUserValue", ascending: true)
        ]
        return fetchRequest
    }
    
    @nonobjc class func fetchRequest(
        rawAddress: Address.RawAddress
    ) -> NSFetchRequest<PersistenceAccount> {
        let request = NSFetchRequest<PersistenceAccount>(entityName: "PersistenceAccount")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "raw_address == %@", rawAddress.rawValue),
        ])
        return request
    }
    
    @MainActor
    @nonobjc class func fetchedResultsController(
        request: NSFetchRequest<PersistenceAccount>
    ) -> NSFetchedResultsController<PersistenceAccount> {
        let viewContext = PersistenceController.shared.managedObjectContext(withType: .main)
        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
}
