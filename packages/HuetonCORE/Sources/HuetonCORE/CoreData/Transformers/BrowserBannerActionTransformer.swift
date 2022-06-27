//
//  Created by Anton Spivak
//

import Foundation
import CoreData

internal class BrowserBannerActionTransformer: GenericCodableTransformer<BrowserBannerAction> {
    
    static func register() {
        ValueTransformer.setValueTransformer(BrowserBannerActionTransformer(), forName: .BrowserBannerActionTransformer)
    }
}

private extension NSValueTransformerName {
    
    static let BrowserBannerActionTransformer = NSValueTransformerName(rawValue: "BrowserBannerActionTransformer")
}
