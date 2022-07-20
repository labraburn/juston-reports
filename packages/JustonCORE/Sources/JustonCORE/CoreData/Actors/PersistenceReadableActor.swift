//
//  Created by Anton Spivak
//

import Foundation
import CoreData

public typealias PersistenceReadableActor = MainActor

public extension PersistenceReadableActor {
    
    nonisolated var managedObjectContext: NSManagedObjectContext {
        PersistenceController.shared.managedObjectContext(withType: .readContext)
    }
}
