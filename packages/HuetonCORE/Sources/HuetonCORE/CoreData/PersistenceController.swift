//
//  Created by Anton Spivak
//

import Foundation
import CoreData

internal class PersistenceController {
    
    internal enum ManagedObjectContextType {
        
        case main
        case background
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
        case .main:
            return container.viewContext
        case .background:
            return container.newBackgroundContext()
        }
    }
    
    private func load(
        removePersistentStoresIfNeeded: Bool
    ) {
        let container = container
        container.loadPersistentStores(completionHandler: { [weak self] (storeDescription, error) in
            if let error = error {
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
            } else {
                container.viewContext.automaticallyMergesChangesFromParent = true
                container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
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
