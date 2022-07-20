//
//  Created by Anton Spivak
//

import Foundation
import CoreData
import SwiftyTON

@objc(PersistanceBrowserBanner)
public class PersistenceBrowserBanner: PersistenceObject {
    
    @PersistenceWritableActor
    public init(
        title: String,
        subtitle: String?,
        imageURL: URL,
        action: BrowserBannerAction,
        priority: Int64
    ) {
        let context = PersistenceWritableActor.shared.managedObjectContext
        super.init(context: context)
        
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
        self.action = action
        self.priority = priority
    }
    
    @PersistenceWritableActor
    public static func removeAllBeforeInserting(
        _ banners: @PersistenceWritableActor () -> [PersistenceBrowserBanner]
    ) throws {
        let context = PersistenceWritableActor.shared.managedObjectContext

        // First: delete
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BrowserBanner")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs

        let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
        let deleted = result?.result as? [NSManagedObjectID] ?? []

        // Second: insert
        
        let _ = banners()
        
        // Third: save in one request
        
        try context.save()
        
        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: [NSDeletedObjectsKey : deleted],
            into: [
                PersistenceReadableActor.shared.managedObjectContext
            ]
        )
    }
}

// MARK: - CoreData Properties

public extension PersistenceBrowserBanner {
    
    var action: BrowserBannerAction {
        set { raw_action = newValue }
        get {
            guard let action = raw_action as? BrowserBannerAction
            else {
                fatalError("Looks like data is fault.")
            }
            return action
        }
    }
    
    var imageURL: URL {
        set { raw_image_url = newValue.absoluteString }
        get {
            guard let url = URL(string: raw_image_url)
            else {
                fatalError("Looks like data is fault.")
            }
            return url
        }
    }
    
    @NSManaged
    var title: String
    
    @NSManaged
    var subtitle: String?
    
    @NSManaged
    var priority: Int64
    
    /// url value
    @NSManaged
    var raw_image_url: String
    
    /// AccountAppearanceTransformer
    @NSManaged
    private var raw_action: Any
}

// MARK: - CoreData Methods

public extension PersistenceBrowserBanner {
    
    @nonobjc
    class func fetchRequest(
    ) -> NSFetchRequest<PersistenceBrowserBanner> {
        let fetchRequest = NSFetchRequest<PersistenceBrowserBanner>(
            entityName: "BrowserBanner"
        )
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "priority", ascending: false)
        ]
        
        return fetchRequest
    }
    
    @PersistenceReadableActor
    @nonobjc
    class func fetchedResultsController(
        request: NSFetchRequest<PersistenceBrowserBanner>
    ) -> NSFetchedResultsController<PersistenceBrowserBanner> {
        let context = PersistenceReadableActor.shared.managedObjectContext
        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
}
