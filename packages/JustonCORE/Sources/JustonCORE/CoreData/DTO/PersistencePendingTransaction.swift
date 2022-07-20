//
//  Created by Anton Spivak
//

import Foundation
import CoreData
import SwiftyTON

@objc(PersistencePendingTransaction)
public class PersistencePendingTransaction: PersistenceObject {
    
    /// Create and insert into main context
    @PersistenceWritableActor
    public init(
        account: PersistenceAccount,
        destinationAddress: ConcreteAddress,
        value: Currency,
        estimatedFees: Currency,
        body: Data,
        bodyHash: Data
    ) {
        let context = PersistenceWritableActor.shared.managedObjectContext
        super.init(context: context)
        
        self.account = account
        self.destinationAddress = destinationAddress
        self.body = body
        self.bodyHash = bodyHash
        self.value = value
        self.estimatedFees = estimatedFees
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.dateCreated = Date()
    }
    
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
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PendingTransaction")
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

public extension PersistencePendingTransaction {
    
    var destinationAddress: ConcreteAddress {
        get {
            guard let address = Address(rawValue: raw_destination_address)
            else {
                fatalError("Looks like data is fault.")
            }
            
            return ConcreteAddress(
                address: address,
                representation: .base64url(flags: .bounceable)
            )
        }
        set {
            raw_destination_address = newValue.address.rawValue
        }
    }
    
    var value: Currency {
        get { Currency(value: raw_value) }
        set { raw_value = newValue.value }
    }
    
    var estimatedFees: Currency {
        get { Currency(value: raw_estimated_fees) }
        set { raw_estimated_fees = newValue.value }
    }
    
    var body: Data {
        get { Data(hex: raw_body) }
        set { raw_body = newValue.toHexString() }
    }
    
    var bodyHash: Data {
        get { Data(hex: raw_body_hash) }
        set { raw_body_hash = newValue.toHexString() }
    }
    
    @NSManaged
    var account: PersistenceAccount
    
    @NSManaged
    var dateCreated: Date
    
    // MARK: Internal
    
    /// Raw addresses like `0:346576878`
    @NSManaged
    private var raw_destination_address: String
    
    /// nanotons
    @NSManaged
    private var raw_value: Int64
    
    /// nanotons
    @NSManaged
    private var raw_estimated_fees: Int64
    
    /// HEX of transaction body
    @NSManaged
    private var raw_body: String
    
    /// HEX of transaction body
    @NSManaged
    private var raw_body_hash: String
}

// MARK: - CoreData Methods

public extension PersistencePendingTransaction {
    
    @nonobjc
    class func fetchRequest() -> NSFetchRequest<PersistencePendingTransaction> {
        return NSFetchRequest<PersistencePendingTransaction>(entityName: "PendingTransaction")
    }
    
    @nonobjc
    class func fetchRequest(
        account: PersistenceAccount
    ) -> NSFetchRequest<PersistencePendingTransaction> {
        let request = NSFetchRequest<PersistencePendingTransaction>(entityName: "PendingTransaction")
        request.predicate = NSPredicate(format: "account == %@", account)
        return request
    }
    
    @PersistenceReadableActor
    @nonobjc
    class func fetchedResultsController(
        request: NSFetchRequest<PersistencePendingTransaction>
    ) -> NSFetchedResultsController<PersistencePendingTransaction> {
        let context = PersistenceReadableActor.shared.managedObjectContext
        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
}
