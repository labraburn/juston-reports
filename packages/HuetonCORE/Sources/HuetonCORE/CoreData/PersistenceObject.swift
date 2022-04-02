//
//  Created by Anton Spivak
//

import Foundation
import CoreData
import Combine
import Objective42

@MainActor
public class PersistenceObject: NSManagedObject {
    
    public var changes: (() -> ())?
    
    @MainActor
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
    internal init(shouldInsertIntoViewContext: Bool) {
        let context = PersistenceController.shared.viewContext
        super.init(
            entity: Self.entity(with: context),
            insertInto: shouldInsertIntoViewContext ? context : nil
        )
    }
    
    @MainActor
    public override func didSave() {
        super.didSave()
        changes?()
    }
    
    // MARK: API
    
    @MainActor
    open func save() throws {
        let context = PersistenceController.shared.viewContext
        if (try? context.existingObject(with: objectID)) == nil {
            context.insert(self)
        }
        try context.save()
    }
    
    @MainActor
    open func delete() throws {
        let context = PersistenceController.shared.viewContext
        context.delete(self)
        try context.save()
    }
    
    @MainActor
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
    
    @MainActor
    public final class func perform(_ code: @escaping (_ viewContext: NSManagedObjectContext) throws -> ()) throws {
        let viewContext = PersistenceController.shared.viewContext
        var error: Error? = nil
        
        viewContext.perform {
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
    
    @MainActor
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
    
    @MainActor
    public class func fetch<T>(_ request: NSFetchRequest<T>) throws -> [T] where T : NSFetchRequestResult {
        let viewContext = PersistenceController.shared.viewContext
        return try viewContext.fetch(request)
    }

    @MainActor
    public class func count<T>(for request: NSFetchRequest<T>) throws -> Int where T : NSFetchRequestResult {
        let viewContext = PersistenceController.shared.viewContext
        return try viewContext.count(for: request)
    }
}
