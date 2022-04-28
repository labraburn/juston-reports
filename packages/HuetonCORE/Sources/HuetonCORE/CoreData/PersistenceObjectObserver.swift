//
//  Created by Anton Spivak
//

import Foundation
import CoreData
import ObjectiveC.runtime

public final class PersistenceObjectObserver {
    
    private let uuid = UUID()
    
    fileprivate init() {}
}

extension PersistenceObjectObserver: Hashable {
    
    public static func == (lhs: PersistenceObjectObserver, rhs: PersistenceObjectObserver) -> Bool {
        lhs.uuid == rhs.uuid
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}

public extension NSManagedObject {
    
    private final class ObserverContainer {
        
        let block: () -> ()
        
        init(_ block: @escaping () -> ()) {
            self.block = block
        }
    }
    
    private enum Keys {
        
        static var hashtable: UInt8 = 0
    }
    
    /// Warning - should be called only at main tread
    private var observers: NSMapTable<PersistenceObjectObserver, ObserverContainer> {
        if let value = objc_getAssociatedObject(self, &Keys.hashtable) as? NSMapTable<PersistenceObjectObserver, ObserverContainer> {
            return value
        } else {
            let value = NSMapTable<PersistenceObjectObserver, ObserverContainer>.weakToStrongObjects()
            objc_setAssociatedObject(self, &Keys.hashtable, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return value
        }
    }
    
    /// Warning - should be called only at main tread
    fileprivate func _didUpdateInsideViewContext() {
        let enumerator = observers.objectEnumerator()
        while let value = enumerator?.nextObject() as? ObserverContainer {
            value.block()
        }
    }
    
    // MARK: API
    
    @MainActor
    func addObjectDidChangeObserver(_ observer: @escaping () -> ()) -> PersistenceObjectObserver {
        let key = PersistenceObjectObserver()
        observers.setObject(ObserverContainer(observer), forKey: key)
        return key
    }
}

internal struct ManagedObjectContextObjectsDidChangeObserver {
    
    private static var observer: AnyObject?
    
    internal static func startObservingIfNeccessary() {
        guard observer == nil
        else {
            return
        }
        
        let didSave = { (_ persistenceObject: PersistenceObject) in
            persistenceObject._didUpdateInsideViewContext()
        }
        
        let block = { (_ notification: Notification) in
            (notification.userInfo?[NSRefreshedObjectsKey] as? Set<PersistenceObject>)?.forEach(didSave)
            (notification.userInfo?[NSUpdatedObjectsKey] as? Set<PersistenceObject>)?.forEach(didSave)
        }
        
        observer = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
            object: PersistenceController.shared.managedObjectContext(withType: .main),
            queue: .main,
            using: block
        )
    }
}
