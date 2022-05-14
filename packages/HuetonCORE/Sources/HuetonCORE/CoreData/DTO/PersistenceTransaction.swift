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
        date: Date,
        flags: Flags
    ) {
        self.init()
        self.id = id
        self.account = account
        self.date = date
        self.flags = flags
    }
}

// MARK: - CoreData Properties

public extension PersistenceTransaction {
    
    struct Flags: OptionSet {
        
        public let rawValue: Int64

        public static let pending = Flags(rawValue: 1 << 0)
        
        public init(rawValue: Int64) {
            self.rawValue = rawValue
        }
    }
    
    var id: Transaction.ID {
        get {
            Transaction.ID(
                logicalTime: raw_logical_time,
                hash: Data(hex: raw_hash)
            )
        }
        set {
            raw_logical_time = newValue.logicalTime
            raw_hash = newValue.hash.toHexString()
        }
    }
    
    var fromAddress: Address.RawAddress {
        get {
            Address.RawAddress(rawValue: raw_from_address)!
        }
        set {
            raw_from_address = newValue.rawValue
        }
    }
    
    var toAddresses: [Address.RawAddress] {
        get {
            raw_to_addresses.compactMap({ Address.RawAddress(rawValue: $0) })
        }
        set {
            raw_to_addresses = newValue.map({ $0.rawValue })
        }
    }
    
    var flags: Flags {
        set { raw_flags = newValue.rawValue }
        get { Flags(rawValue: raw_flags) }
    }
    
    @NSManaged var date: Date
    @NSManaged var account: PersistenceAccount
    @NSManaged var value: NSDecimalNumber
    @NSManaged var fees: NSDecimalNumber
    
    // MARK: Internal
    
    /// OptionSet
    @NSManaged
    private var raw_flags: Int64
    
    /// Logical time of transaction id
    @NSManaged
    private var raw_logical_time: Int64
    
    /// Hash of transaction id
    @NSManaged
    private var raw_hash: String
    
    @NSManaged
    private var raw_from_address: String
    
    @NSManaged
    private var raw_to_addresses: [String]
    
    /// Transient
    @objc
    private var raw_day_section_name: String {
        let startOfDay = Calendar.current.startOfDay(for: date)
        return Self.dateDaySectionFormatter.string(from: startOfDay)
    }
}

// MARK: - CoreData Methods

public extension PersistenceTransaction {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<PersistenceTransaction> {
        return NSFetchRequest<PersistenceTransaction>(entityName: "PersistenceTransaction")
    }
    
    @nonobjc class func fetchRequest(
        id: Transaction.ID
    ) -> NSFetchRequest<PersistenceTransaction> {
        let request = NSFetchRequest<PersistenceTransaction>(entityName: "PersistenceTransaction")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "raw_logical_time == %i", id.logicalTime),
            NSPredicate(format: "raw_hash == %@", id.hash.toHexString()),
        ])
        return request
    }
    
    @nonobjc class func fetchRequest(
        account: PersistenceAccount
    ) -> NSFetchRequest<PersistenceTransaction> {
        let request = NSFetchRequest<PersistenceTransaction>(entityName: "PersistenceTransaction")
        request.predicate = NSPredicate(format: "account == %@", account)
        return request
    }
    
    enum FetchedResultsControllerSection {
        
        case none
        case day
    }
    
    @MainActor
    @nonobjc class func fetchedResultsController(
        request: NSFetchRequest<PersistenceTransaction>,
        sections: FetchedResultsControllerSection
    ) -> NSFetchedResultsController<PersistenceTransaction> {
        let viewContext = PersistenceController.shared.managedObjectContext(withType: .main)
        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewContext,
            sectionNameKeyPath: {
                switch sections {
                case .none:
                    return nil
                case .day:
                    return #keyPath(raw_day_section_name)
                }
            }(),
            cacheName: nil
        )
    }
}

private extension PersistenceTransaction {
    
    private static let dateDaySectionFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter
    }()
}
