//
//  Created by Anton Spivak
//

import Foundation
import CoreData

private class PersistentContainer: NSPersistentContainer {
    
    private static let _defaultDirectoryURL: URL = {
        FileManager.default.directoryURL(
            with: .group(),
            with: .persistent,
            pathComponent: .coreData
        )
    }()
    
    override class func defaultDirectoryURL() -> URL { _defaultDirectoryURL }
}

internal class PersistenceController {
    
    internal static let shared = PersistenceController()

    internal let container: NSPersistentContainer
    internal var viewContext: NSManagedObjectContext { container.viewContext }
    internal var managedObjectModel: NSManagedObjectModel { container.managedObjectModel }
    internal var persistentStoreCoordinator: NSPersistentStoreCoordinator { container.persistentStoreCoordinator }

    init() {
        let nameName = "Model"
        guard let modelURL = Bundle.module.url(forResource: nameName, withExtension: "momd")
        else {
            fatalError("Can't locate \(nameName).momd.")
        }
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL)
        else {
            fatalError("Can't instatiate object model.")
        }
        
        container = PersistentContainer(name: nameName, managedObjectModel: model)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            
            self.container.viewContext.automaticallyMergesChangesFromParent = true
            self.container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
            
            guard let error = error
            else {
                return
            }
            
            /*
             Typical reasons for an error here include:
             * The parent directory does not exist, cannot be created, or disallows writing.
             * The persistent store is not accessible, due to permissions or data protection when the device is locked.
             * The device is out of space.
             * The store could not be migrated to the current model version.
             Check the error message to determine what the actual problem was.
             */
            fatalError("Unresolved error \(error), \(error.localizedDescription)")
        })
    }
}
