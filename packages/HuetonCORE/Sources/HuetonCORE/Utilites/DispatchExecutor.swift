//
//  Created by Anton Spivak
//

import Foundation
import CoreData

public final class DispatchExecutor: SerialExecutor {
    
    let dispatchQueue: DispatchQueue
    
    init(dispatchQueue: DispatchQueue) {
        self.dispatchQueue = dispatchQueue
    }
    
    public func enqueue(_ job: UnownedJob) {
        let unownedSerialExecutor = asUnownedSerialExecutor()
        dispatchQueue.async(execute: {
            job._runSynchronously(on: unownedSerialExecutor)
        })
    }
    
    public func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(ordinary: self)
    }
}
