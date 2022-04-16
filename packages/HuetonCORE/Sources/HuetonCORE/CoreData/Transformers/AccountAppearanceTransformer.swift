//
//  Created by Anton Spivak
//

import Foundation
import CoreData

internal class AccountAppearanceTransformer: GenericCodableTransformer<AccountAppearance> {
    
    static func register() {
        ValueTransformer.setValueTransformer(AccountAppearanceTransformer(), forName: .AccountAppearanceTransformer)
    }
}

private extension NSValueTransformerName {
    
    static let AccountAppearanceTransformer = NSValueTransformerName(rawValue: "AccountAppearanceTransformer")
}
