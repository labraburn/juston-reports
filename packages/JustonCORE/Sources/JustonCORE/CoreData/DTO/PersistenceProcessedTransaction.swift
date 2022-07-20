//
//  Created by Anton Spivak
//

import Foundation
import CoreData
import SwiftyTON

@objc(PersistenceProcessedTransaction)
public class PersistenceProcessedTransaction: PersistenceObject {
    
    public override func willSave() {
        super.willSave()
        
        // Check optional CoreData property, but not optional Swift property
        let _ = self.account
    }
    
    @PersistenceWritableActor
    public static func removeAll(
        for account: PersistenceAccount
    ) throws {
        let context = PersistenceWritableActor.shared.managedObjectContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ProcessedTransaction")
        fetchRequest.predicate = NSPredicate(format: "account == %@", account.objectID)
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs
        
        let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
        let deleted = result?.result as? [NSManagedObjectID] ?? []
        
        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: [NSDeletedObjectsKey : deleted],
            into: [
                PersistenceReadableActor.shared.managedObjectContext
            ]
        )
        
        try context.save()
    }
}

// MARK: - CoreData Properties

public extension PersistenceProcessedTransaction {
    
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
    
    var fees: Currency {
        get { Currency(value: raw_fees) }
        set { raw_fees = newValue.value }
    }
    
    @NSManaged
    var date: Date
    
    @NSManaged
    var account: PersistenceAccount
    
    @NSManaged
    var `in`: PersistenceProcessedAction?
    
    @NSManaged
    var `out`: Set<PersistenceProcessedAction>
    
    // MARK: Internal
    
    /// Logical time of transaction
    @NSManaged
    private var raw_logical_time: Int64
    
    /// Hash of transaction
    @NSManaged
    private var raw_hash: String
    
    /// nanotons
    @NSManaged
    internal var raw_fees: Int64
    
    /// Transient
    @objc
    private var raw_day_section_name: String {
        let startOfDay = Calendar.current.startOfDay(for: date)
        return Self.dateDaySectionFormatter.string(from: startOfDay)
    }
}

// MARK: - CoreData Methods

public extension PersistenceProcessedTransaction {
    
    @nonobjc
    class func fetchRequest() -> NSFetchRequest<PersistenceProcessedTransaction> {
        return NSFetchRequest<PersistenceProcessedTransaction>(entityName: "ProcessedTransaction")
    }
    
    @nonobjc
    class func fetchRequest(
        account: PersistenceAccount
    ) -> NSFetchRequest<PersistenceProcessedTransaction> {
        let request = NSFetchRequest<PersistenceProcessedTransaction>(entityName: "ProcessedTransaction")
        request.predicate = NSPredicate(format: "account == %@", account)
        return request
    }
    
    enum FetchedResultsControllerSection {
        
        case none
        case day
    }
    
    @PersistenceReadableActor
    @nonobjc
    class func fetchedResultsController(
        request: NSFetchRequest<PersistenceProcessedTransaction>,
        sections: FetchedResultsControllerSection
    ) -> NSFetchedResultsController<PersistenceProcessedTransaction> {
        let context = PersistenceReadableActor.shared.managedObjectContext
        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
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

private extension PersistenceProcessedTransaction {
    
    private static let dateDaySectionFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter
    }()
}
