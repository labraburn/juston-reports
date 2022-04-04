//
//  Created by Anton Spivak
//

import Foundation
import CoreData
import Objective42

public protocol PersistenceObjectObserver: AnyObject {
    
    func persistenceObjectDidChange(_ persistenceObject: PersistenceObject)
}

public class PersistenceObject: NSManagedObject {
    
    private let observers: NSHashTable<AnyObject> = .weakObjects()
    
    private override init(
        entity: NSEntityDescription,
        insertInto context: NSManagedObjectContext?
    ) {
        super.init(
            entity: entity,
            insertInto: context
        )
    }
    
    /// Create and insert into main context
    internal init() {
        let context = PersistenceController.shared.viewContext
        super.init(
            entity: Self.entity(with: context),
            insertInto: nil
        )
    }
    
    public override func didSave() {
        super.didSave()
        observers.allObjects.forEach({ ($0 as? PersistenceObjectObserver)?.persistenceObjectDidChange(self) })
    }
    
    // MARK: API
    
    public func register(observer: PersistenceObjectObserver) {
        guard observers.contains(observers)
        else {
            return
        }
    }
    
    public func remove(observer: PersistenceObjectObserver) {
        observers.remove(observer)
    }
    
    open func save() throws {
        let context = PersistenceController.shared.viewContext
        if (try? context.existingObject(with: objectID)) == nil {
            context.insert(self)
        }
        try context.save()
    }
    
    open func delete() throws {
        let context = PersistenceController.shared.viewContext
        context.delete(self)
        try context.save()
    }
    
    public final class func object<T>(with id: NSManagedObjectID, type: T.Type) -> T where T: NSManagedObject {
        let viewContext = PersistenceController.shared.viewContext
        var object: NSManagedObject? = nil
        
        try? O42NSExceptionHandler.execute({ object = viewContext.object(with: id) })
        
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
    
    public final class func perform(_ code: @escaping (_ viewContext: NSManagedObjectContext) throws -> ()) throws {
        let viewContext = PersistenceController.shared.viewContext
        var error: Error? = nil
        
        viewContext.performAndWait {
            do {
                try code(viewContext)
            } catch let _error {
                error = _error
            }
        }
        
        guard let error = error
        else {
            return
        }
        
        throw error
    }
    
    public final class func entity(with context: NSManagedObjectContext) -> NSEntityDescription {
        let entityName = String(describing: Self.self)
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        else {
            fatalError("Can't create entity named '\(entityName)'.")
        }
        return entity
    }
}

// MARK: - Fetches

extension PersistenceObject {
    
    public class func fetch<T>(_ request: NSFetchRequest<T>) throws -> [T] where T : NSFetchRequestResult {
        let viewContext = PersistenceController.shared.viewContext
        return try viewContext.fetch(request)
    }

    public class func count<T>(for request: NSFetchRequest<T>) throws -> Int where T : NSFetchRequestResult {
        let viewContext = PersistenceController.shared.viewContext
        return try viewContext.count(for: request)
    }
}
