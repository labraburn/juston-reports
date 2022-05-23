//
//  Created by Anton Spivak
//

import Foundation
import CoreData
import Objective42

public class PersistenceObject: NSManagedObject {
    
    
    // This methods/properties hidden from public usage to make write/read operations consistent
    // MARK: - Unavailable
    
    @available(*, unavailable)
    internal convenience init() {
        fatalError()
    }
    
    @available(*, unavailable)
    private override init(
        entity: NSEntityDescription,
        insertInto context: NSManagedObjectContext?
    ) {
        super.init(
            entity: entity,
            insertInto: context
        )
    }
    
    // This methods/properties only internal because NSManagedObjectContext usage hidden from public
    // MARK: - Internal init
    
    internal init(
        context: NSManagedObjectContext
    ) {
        let entityName = String(describing: Self.self).replacingOccurrences(of: "Persistence", with: "")
        
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        else {
            fatalError("Can't create entity named '\(entityName)'.")
        }
        
        super.init(
            entity: entity,
            insertInto: context
        )
    }
    
    // This methods/properties available in PersistenceWritableActor to add ability to perfrom write operations in CoreData
    // MARK: - Writable
    
    @PersistenceWritableActor
    public final class func writeableObjectIfExisted(
        id: NSManagedObjectID
    ) -> Self? {
        let context = PersistenceWritableActor.shared.managedObjectContext
        guard let object = try? context.existingObject(with: id) as? Self
        else {
            return nil
        }
        return object
    }
    
    @PersistenceWritableActor
    public final class func writeableObject(
        id: NSManagedObjectID
    ) -> Self {
        let context = PersistenceWritableActor.shared.managedObjectContext
        guard let object = try? context.existingObject(with: id) as? Self
        else {
            fatalError()
        }
        return object
    }
    
    @PersistenceWritableActor
    open func save() throws {
        let context = PersistenceWritableActor.shared.managedObjectContext
        guard context == managedObjectContext
        else {
            fatalError("Can't save \(self) from another context.")
        }
        
        try context.save()
    }
    
    @PersistenceWritableActor
    open func delete() throws {
        let context = PersistenceWritableActor.shared.managedObjectContext
        guard context == managedObjectContext
        else {
            fatalError("Can't save \(self) from another context.")
        }
        
        context.delete(self)
        try context.save()
    }
    
    // This methods/properties available in PersistenceWritableActor to add ability to perfrom write operations in CoreData
    // MARK: - Readable
    
    @PersistenceReadableActor
    public final class func readableObjectIfExisted(
        id: NSManagedObjectID
    ) -> Self? {
        let context = PersistenceReadableActor.shared.managedObjectContext
        guard let object = try? context.existingObject(with: id) as? Self
        else {
            return nil
        }
        return object
    }
    
    @PersistenceReadableActor
    public final class func readableObject(
        id: NSManagedObjectID
    ) -> Self {
        let context = PersistenceReadableActor.shared.managedObjectContext
        guard let object = try? context.existingObject(with: id) as? Self
        else {
            fatalError("")
        }
        return object
    }
}
