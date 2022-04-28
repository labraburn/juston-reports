//
//  Created by Anton Spivak
//

import Foundation
import CoreData

@globalActor
public final actor SynchronizationActor: GlobalActor {
    
    public static var shared = PersistenceActor()
}
