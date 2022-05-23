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
        
        let persistentStoreDescription = container.persistentStoreDescriptions.first
        persistentStoreDescription?.shouldMigrateStoreAutomatically = true
        persistentStoreDescription?.shouldInferMappingModelAutomatically = true
        
        load(removePersistentStoresIfNeeded: true)
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
    
    private func load(
        removePersistentStoresIfNeeded: Bool
    ) {
        let container = container
        container.loadPersistentStores(completionHandler: { [weak self] (storeDescription, error) in
            guard let error = error
            else {
                return
            }

            let nserror = error as NSError
            if removePersistentStoresIfNeeded && (nserror.code == 134140 || nserror.code == 134110) {
                #warning("TODO: Remove this code.")
                if let url = container.persistentStoreDescriptions.first?.url {
                    try? FileManager.default.removeItem(at: url)
                    self?.load(removePersistentStoresIfNeeded: false)
                }
            } else {
                fatalError("[CoreData]: Unresolved error \(error), \(error.localizedDescription)")
            }
        })
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

////
////  Created by Anton Spivak
////
//
//import Foundation
//import CoreData
//
//internal class PersistenceController {
//
//    internal enum ManagedObjectContextType {
//
//        /// Main thread, singleton
//        case readContext
//
//        /// Background thread, always new
//        case writeContext
//    }
//
//    internal static let shared = PersistenceController()
//
//    private let container: NSPersistentContainer
//
//    private lazy var context: NSManagedObjectContext = {
//        let context = container.newBackgroundContext()
//        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//        return context
//    }()
//
//    private lazy var readContext: NSManagedObjectContext = {
//        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
//        context.parent = self.context
//        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
//        context.automaticallyMergesChangesFromParent = true
//        return context
//    }()
//
//    init() {
//        let nameName = "Model"
//        guard let modelURL = Bundle.module.url(forResource: nameName, withExtension: "momd")
//        else {
//            fatalError("[CoreData]: Can't locate \(nameName).momd.")
//        }
//
//        guard let model = NSManagedObjectModel(contentsOf: modelURL)
//        else {
//            fatalError("[CoreData]: Can't instatiate object model.")
//        }
//
//        let container = PersistentContainer(name: nameName, managedObjectModel: model)
//
//        let persistentStoreDescription = container.persistentStoreDescriptions.first
//        persistentStoreDescription?.shouldMigrateStoreAutomatically = true
//        persistentStoreDescription?.shouldInferMappingModelAutomatically = true
//
//        self.container = container
//
//        load(removePersistentStoresIfNeeded: true)
//    }
//
//    internal func managedObjectContext(
//        withType type: ManagedObjectContextType
//    ) -> NSManagedObjectContext {
//        switch type {
//        case .readContext:
//            return readContext
//        case .writeContext:
//            let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
//            context.parent = self.context
//            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//            context.automaticallyMergesChangesFromParent = true
//            return context
//        }
//    }
//
//    private func load(
//        removePersistentStoresIfNeeded: Bool
//    ) {
//        let container = container
//        container.loadPersistentStores(completionHandler: { [weak self] (storeDescription, error) in
//            guard let error = error
//            else {
//                return
//            }
//
//            let nserror = error as NSError
//            if removePersistentStoresIfNeeded && (nserror.code == 134140 || nserror.code == 134110) {
//                #warning("TODO: Remove this code.")
//                if let url = container.persistentStoreDescriptions.first?.url {
//                    try? FileManager.default.removeItem(at: url)
//                    self?.load(removePersistentStoresIfNeeded: false)
//                }
//            } else {
//                fatalError("[CoreData]: Unresolved error \(error), \(error.localizedDescription)")
//            }
//        })
//    }
//}
//
//private class PersistentContainer: NSPersistentContainer {
//
//    private static let _defaultDirectoryURL: URL = {
//        FileManager.default.directoryURL(
//            with: .group(),
//            with: .persistent,
//            pathComponent: .coreData
//        )
//    }()
//
//    override class func defaultDirectoryURL() -> URL { _defaultDirectoryURL }
//}
