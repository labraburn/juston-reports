//
//  Created by Anton Spivak
//

import Foundation

public enum AccountSubscription {
    
    case unsupported
    case transactions
}

extension AccountSubscription: Codable {
    
    public enum CodingKeys: CodingKey {
        
        case kase
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let kase = try container.decode(String.self, forKey: .kase)
        switch kase {
        case "transactions":
            self = .transactions
        default:
            self = .unsupported
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .unsupported:
            try container.encode("unsupported", forKey: .kase)
        case .transactions:
            try container.encode("transactions", forKey: .kase)
        }
    }
}
