//
//  Created by Anton Spivak
//

import Foundation
import CoreData
import SwiftyTON
import UIKit

@objc(PersistanceBrowserFavourite)
public class PersistenceBrowserFavourite: PersistenceObject {
    
    @PersistenceWritableActor
    public init(
        title: String,
        subtitle: String?,
        url: URL,
        account: PersistenceAccount
    ) {
        let context = PersistenceWritableActor.shared.managedObjectContext
        super.init(context: context)
        
        self.title = title
        self.subtitle = subtitle
        self.url = url
        self.account = account
        self.dateCreated = Date()
    }
}

// MARK: - CoreData Properties

public extension PersistenceBrowserFavourite {
    
    var url: URL {
        set { raw_url = newValue.absoluteString }
        get {
            guard let url = URL(string: raw_url)
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
    var dateCreated: Date
    
    @NSManaged
    var account: PersistenceAccount

    /// url
    @NSManaged
    private var raw_url: String
}

// MARK: - CoreData Methods

public extension PersistenceBrowserFavourite {
    
    @nonobjc
    class func fetchRequest() -> NSFetchRequest<PersistenceBrowserFavourite> {
        let fetchRequest = NSFetchRequest<PersistenceBrowserFavourite>(
            entityName: "BrowserFavourite"
        )
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "dateCreated", ascending: false)
        ]
        
        return fetchRequest
    }
    
    @nonobjc
    class func fetchRequest(
        account: PersistenceAccount
    ) -> NSFetchRequest<PersistenceBrowserFavourite> {
        let fetchRequest = fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "account == %@", account.objectID)
        return fetchRequest
    }
    
    @nonobjc
    class func fetchRequest(
        account: PersistenceAccount,
        query: String
    ) -> NSFetchRequest<PersistenceBrowserFavourite> {
        let fetchRequest = fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                NSPredicate(
                    format: "account == %@", account.objectID
                ),
                NSCompoundPredicate(
                    orPredicateWithSubpredicates: [
                        NSPredicate(
                            format: "title CONTAINS[cd] %@", query
                        ),
                        NSPredicate(
                            format: "subtitle CONTAINS[cd] %@", query
                        ),
                        NSPredicate(
                            format: "raw_url CONTAINS[cd] %@", query
                        ),
                    ]
                ),
            ]
        )
        return fetchRequest
    }
    
    @nonobjc
    class func fetchRequest(
        url: URL
    ) -> NSFetchRequest<PersistenceBrowserFavourite> {
        let fetchRequest = fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "raw_url == %@", url.absoluteString)
        return fetchRequest
    }
    
    @PersistenceReadableActor
    @nonobjc
    class func fetchedResultsController(
        request: NSFetchRequest<PersistenceBrowserFavourite>
    ) -> NSFetchedResultsController<PersistenceBrowserFavourite> {
        let context = PersistenceReadableActor.shared.managedObjectContext
        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
}
