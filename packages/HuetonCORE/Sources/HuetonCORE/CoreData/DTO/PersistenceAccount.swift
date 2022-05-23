//
//  Created by Anton Spivak
//

import Foundation
import CoreData
import SwiftyTON

@objc(PersistenceAccount)
public class PersistenceAccount: PersistenceObject {
    
    @PersistenceWritableActor
    public init(
        keyPublic: String?,
        keySecretEncrypted: String?,
        selectedAddress: Address,
        name: String,
        appearance: AccountAppearance,
        flags: Flags = []
    ) {
        let context = PersistenceWritableActor.shared.managedObjectContext
        super.init(context: context)
        
        if let keyPublic = keyPublic {
            self.raw_unique_identifier = "0a" + keyPublic
        } else {
            self.raw_unique_identifier = "0b" + selectedAddress.rawValue.rawValue
        }
        
        self.keyPublic = keyPublic
        self.keySecretEncrypted = keySecretEncrypted
        
        self.selectedAddress = selectedAddress
        self.name = name
        self.appearance = appearance
        self.flags = flags
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.dateCreated = Date()
    }
    
    @PersistenceWritableActor
    public func saveAsLastSorting() throws {
        let context = PersistenceWritableActor.shared.managedObjectContext
        guard context == managedObjectContext
        else {
            fatalError("Can't save \(self) from another context.")
        }
        
        let request = Self.fetchRequest()
        let count = (try managedObjectContext?.count(for: request)) ?? 0
        
        self.sortingUserValue = Int64(count) + 1
        
        try context.save()
    }
    
    @PersistenceWritableActor
    public func saveAsLastUsage() throws {
        let context = PersistenceWritableActor.shared.managedObjectContext
        guard context == managedObjectContext
        else {
            fatalError("Can't save \(self) from another context.")
        }
        
        let request = Self.fetchRequestSortingUser()
        let accounts = try context.fetch(request)

        guard accounts.count > 0,
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
        
        guard context.hasChanges
        else {
            return
        }

        try context.save()
    }
}

// MARK: - CoreData Properties

public extension PersistenceAccount {
    
    struct Flags: OptionSet {
        
        public let rawValue: Int64
        
        public static let isNotificationsEnabled = Flags(rawValue: 1 << 0)
        
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
    
    var selectedAddress: Address {
        set { raw_selected_address = newValue.rawValue.rawValue }
        get {
            guard let address = Address(string: raw_selected_address)
            else {
                fatalError("Looks like data is fault.")
            }
            return address
        }
    }
    
    var balance: Currency {
        get { Currency(value: raw_balance) }
        set { raw_balance = newValue.value }
    }
    
    var flags: Flags {
        set { raw_flags = newValue.rawValue }
        get { Flags(rawValue: raw_flags) }
    }
    
    var isPublicKey: Bool { keyPublic != nil }
    var isReadonly: Bool { keySecretEncrypted == nil }
    
    /// 32-byte public key (HEX)
    @NSManaged
    var keyPublic: String?
    
    @NSManaged
    var keySecretEncrypted: String?
    
    @NSManaged
    var name: String
    
    @NSManaged
    var dateCreated: Date
    
    @NSManaged
    var dateLastSynchronization: Date?
    
    @NSManaged
    var sortingUserValue: Int64
    
    @NSManaged
    var sortingLastUsageValue: Int64
    
    // MARK: Internal
    
    /// nanotons
    @NSManaged
    private var raw_balance: Int64
    
    /// OptionSet
    @NSManaged
    private var raw_flags: Int64
    
    /// raw address (`workchain:hex`)
    @NSManaged
    private var raw_selected_address: String
    
    /// `0a` + public key (hex, 32 bytes) _or_ `0b` + raw address (`workchain:hex`)
    @NSManaged
    private var raw_unique_identifier: String
    
    /// AccountAppearanceTransformer
    @NSManaged
    private var raw_appearance: Any
}

// MARK: - CoreData Methods

public extension PersistenceAccount {
    
    @nonobjc
    class func fetchRequest() -> NSFetchRequest<PersistenceAccount> {
        return NSFetchRequest<PersistenceAccount>(entityName: "Account")
    }
    
    @nonobjc
    class func fetchRequestSortingLastUsage() -> NSFetchRequest<PersistenceAccount> {
        let fetchRequest = NSFetchRequest<PersistenceAccount>(entityName: "Account")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "sortingLastUsageValue", ascending: true)
        ]
        return fetchRequest
    }
    
    @nonobjc
    class func fetchRequestSortingUser() -> NSFetchRequest<PersistenceAccount> {
        let fetchRequest = NSFetchRequest<PersistenceAccount>(entityName: "Account")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "sortingUserValue", ascending: true)
        ]
        return fetchRequest
    }
    
    @nonobjc
    class func fetchRequest(
        selectedAddress: Address
    ) -> NSFetchRequest<PersistenceAccount> {
        let request = NSFetchRequest<PersistenceAccount>(entityName: "Account")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "raw_selected_address == %@", selectedAddress.rawValue.rawValue),
        ])
        return request
    }
    
    @PersistenceReadableActor
    @nonobjc
    class func fetchedResultsController(
        request: NSFetchRequest<PersistenceAccount>
    ) -> NSFetchedResultsController<PersistenceAccount> {
        let context = PersistenceReadableActor.shared.managedObjectContext
        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
}
