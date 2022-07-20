//
//  Created by Anton Spivak
//

import Foundation
import CoreData
import Objective42

public class PersistenceObject: NSManagedObject {
    
    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()
    
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
    
    // Sometimes, when no inverse relationship..
    // Shit happend
    public override func setValue(_ value: Any?, forUndefinedKey key: String) {
        if key == "" {
            return
        }
        
        super.setValue(value, forUndefinedKey: key)
    }
    
    // Codable
    
    internal func encode<T, V>(
        keyPath: KeyPath<T, V>,
        value: V?
    ) where T: PersistenceObject, V: Encodable {
        var _value: Any? = nil
        if let value = value {
            _value = try? Self.encoder.encode(value)
        }
        
        let _keyPath = NSExpression(forKeyPath: keyPath).keyPath
        setValue(_value, forKeyPath: _keyPath)
    }
    
    internal func decode<T, V>(
        keyPath: KeyPath<T, V>
    ) -> V? where T: PersistenceObject, V: Decodable {
        let _keyPath = NSExpression(forKeyPath: keyPath).keyPath
        guard let data = value(forKeyPath: _keyPath) as? Data,
              let value = try? Self.decoder.decode(V.self, from: data)
        else {
            return nil
        }
        return value
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
    
    @PersistenceReadableActor
    public final class func readableExecute<T>(
        _ request: NSFetchRequest<T>
    ) throws -> [T] where T: NSManagedObject {
        let context = PersistenceReadableActor.shared.managedObjectContext
        return try context.fetch(request)
    }
}
