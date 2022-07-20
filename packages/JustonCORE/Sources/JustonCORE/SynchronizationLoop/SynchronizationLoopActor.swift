//
//  Created by Anton Spivak
//

import Foundation
import CoreData

@globalActor
public final actor SynchronizationLoopGlobalActor: GlobalActor {
    
    public static var shared = SynchronizationLoopActor()
}

public final actor SynchronizationLoopActor: Actor {
    
    private let executor: DispatchExecutor
    
    public nonisolated var unownedExecutor: UnownedSerialExecutor {
        executor.asUnownedSerialExecutor()
    }
    
    public init() {
        let dispatchQueue = DispatchQueue(label: "com.juston.core.synchronization-loop-actor", qos: .utility)
        executor = DispatchExecutor(dispatchQueue: dispatchQueue)
    }
}
