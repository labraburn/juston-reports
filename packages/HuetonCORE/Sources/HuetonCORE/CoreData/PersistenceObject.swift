//
//  Created by Anton Spivak
//

import Foundation
import CoreData
import Objective42

public class PersistenceObject: NSManagedObject {
    
    /// Create and insert into main context
    @MainActor
    internal convenience init() {
        let context = PersistenceController.shared.managedObjectContext(withType: .main)
        self.init(
            context: context
        )
    }
    
    /// Create and insert into context
    internal convenience init(context: NSManagedObjectContext) {
        let entityName = String(describing: Self.self)
        
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        else {
            fatalError("Can't create entity named '\(entityName)'.")
        }
        
        self.init(
            entity: entity,
            insertInto: context
        )
    }
    
    /// Create and insert into context
    private override init(
        entity: NSEntityDescription,
        insertInto context: NSManagedObjectContext?
    ) {
        super.init(
            entity: entity,
            insertInto: context
        )
    }
    
    @MainActor
    open func save() throws {
        try managedObjectContext?.save()
    }
    
    @MainActor
    open func delete() throws {
        managedObjectContext?.delete(self)
        try managedObjectContext?.save()
    }
    
    public final class func object<T>(with id: NSManagedObjectID, type: T.Type) -> T where T: NSManagedObject {
        let context = PersistenceController.shared.managedObjectContext(withType: .main)
        var object: NSManagedObject? = nil
        
        try? O42NSExceptionHandler.execute({ object = context.object(with: id) })
        
        guard let object = object
        else {
            fatalError("Can't locate object with id \(id).")
        }
        
        guard let casted = object as? T
        else {
            fatalError("Can't cast managed object: \(object) to type : \(String(describing: T.self)).")
        }
        
        return casted
    }
}

// MARK: - Fetches

extension PersistenceObject {
    
    @MainActor
    public class func fetch<T>(_ request: NSFetchRequest<T>) throws -> [T] where T : NSFetchRequestResult {
        let viewContext = PersistenceController.shared.managedObjectContext(withType: .main)
        return try viewContext.fetch(request)
    }
    
    @MainActor
    public class func count<T>(for request: NSFetchRequest<T>) throws -> Int where T : NSFetchRequestResult {
        let viewContext = PersistenceController.shared.managedObjectContext(withType: .main)
        return try viewContext.count(for: request)
    }
}
