//
//  Created by Anton Spivak
//

import Foundation
import CoreData

internal class AccountSubscriptionArrayTransformer: GenericCodableTransformer<[AccountSubscription]> {
    
    static func register() {
        ValueTransformer.setValueTransformer(AccountSubscriptionArrayTransformer(), forName: .AccountSubscriptionArrayTransformer)
    }
}

private extension NSValueTransformerName {
    
    static let AccountSubscriptionArrayTransformer = NSValueTransformerName(rawValue: "AccountSubscriptionArrayTransformer")
}
