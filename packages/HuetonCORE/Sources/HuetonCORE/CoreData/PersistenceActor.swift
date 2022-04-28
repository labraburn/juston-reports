//
//  Created by Anton Spivak
//

import Foundation
import CoreData

public final actor PersistenceActor: Actor {
    
    private let executor: PersistenceExecutor
    
    public nonisolated var unownedExecutor: UnownedSerialExecutor {
        executor.asUnownedSerialExecutor()
    }
    
    public nonisolated var managedObjectContext: NSManagedObjectContext {
        executor.managedObjectContext
    }
    
    public init() {
        let managedObjectContext = PersistenceController.shared.managedObjectContext(withType: .background)
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        executor = PersistenceExecutor(managedObjectContext: managedObjectContext)
    }
}

private final class PersistenceExecutor: SerialExecutor {
    
    let managedObjectContext: NSManagedObjectContext
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    func enqueue(_ job: UnownedJob) {
        let unownedSerialExecutor = asUnownedSerialExecutor()
        managedObjectContext.perform({
            job._runSynchronously(on: unownedSerialExecutor)
        })
    }
    
    func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(ordinary: self)
    }
}

extension NSManagedObjectContext: @unchecked Sendable {}
