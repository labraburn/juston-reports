//
//  Created by Anton Spivak
//

import Foundation
import CoreData

@globalActor
public final actor PersistenceWritableActor: Actor {
    
    public static var shared = PersistenceWritableActor()
    private let executor: PersistenceWritableExecutor
    
    public nonisolated var unownedExecutor: UnownedSerialExecutor {
        executor.asUnownedSerialExecutor()
    }
    
    public nonisolated var managedObjectContext: NSManagedObjectContext {
        executor.managedObjectContext
    }
    
    public init() {
        let managedObjectContext = PersistenceController.shared.managedObjectContext(withType: .writeContext)
        executor = PersistenceWritableExecutor(managedObjectContext: managedObjectContext)
    }
}

private final class PersistenceWritableExecutor: SerialExecutor {
    
    let managedObjectContext: NSManagedObjectContext
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    func enqueue(_ job: UnownedJob) {
        let unownedSerialExecutor = asUnownedSerialExecutor()
        managedObjectContext.perform({
            autoreleasepool(invoking: {
                job._runSynchronously(on: unownedSerialExecutor)
            })
        })
    }
    
    func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(ordinary: self)
    }
}

extension NSManagedObjectContext: @unchecked Sendable {}
