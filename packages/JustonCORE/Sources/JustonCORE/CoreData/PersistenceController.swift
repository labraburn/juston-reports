//
//  Created by Anton Spivak
//

import Foundation
import CoreData

internal class PersistenceController {
    
    internal enum ManagedObjectContextType {
        
        /// Main thread, singleton object
        case readContext
        
        /// Background thread, always new object
        case writeContext
    }
    
    internal static let shared = PersistenceController()
    private let container: NSPersistentContainer

    init() {
        let nameName = "Model"
        guard let modelURL = Bundle.module.url(forResource: nameName, withExtension: "momd")
        else {
            fatalError("[CoreData]: Can't locate \(nameName).momd.")
        }
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL)
        else {
            fatalError("[CoreData]: Can't instatiate object model.")
        }
        
        container = PersistentContainer(name: nameName, managedObjectModel: model)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            guard let error = error
            else {
                return
            }
            
            fatalError("[CoreData]: Unresolved error \(error), \(error.localizedDescription)")
        })
        
        let persistentStoreDescription = container.persistentStoreDescriptions.first
        persistentStoreDescription?.shouldMigrateStoreAutomatically = true
        persistentStoreDescription?.shouldInferMappingModelAutomatically = true
    }
    
    internal func managedObjectContext(
        withType type: ManagedObjectContextType
    ) -> NSManagedObjectContext {
        switch type {
        case .readContext:
            let context = container.viewContext
            context.automaticallyMergesChangesFromParent = true
            context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
            context.persistentStoreCoordinator = container.persistentStoreCoordinator
            return context
        case .writeContext:
            let context = container.newBackgroundContext()
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            context.persistentStoreCoordinator = container.persistentStoreCoordinator
            return context
        }
    }
}

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
