//
//  Created by Anton Spivak
//

import Foundation

public extension BrowserBannerAction {
    
    enum InApp: String {
        
        case web3promo
    }
}

extension BrowserBannerAction.InApp: Hashable {}
