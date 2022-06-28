//
//  Created by Anton Spivak
//

import Foundation
import HuetonMOON

public extension Configurations {
    
    enum Action {
        
        case url(value: URL)
        case inapp(value: InApp)
    }
}

extension Configurations.Action: Codable {
    
    public enum CodingKeys: CodingKey {
        
        case kase
        
        case url
        case type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let kase = try container.decode(String.self, forKey: .kase)
        switch kase {
        case "url":
            self = .url(
                value: try container.decode(URL.self, forKey: .url)
            )
        case "inapp":
            self = .inapp(
                value: try container.decode(InApp.self, forKey: .type)
            )
        default:
            throw DecodingError.dataCorruptedError(
                forKey: CodingKeys.kase,
                in: container,
                debugDescription: "Undefined `kase`"
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .url(value):
            try container.encode("url", forKey: .kase)
            try container.encode(value, forKey: .url)
        case let .inapp(value):
            try container.encode("inapp", forKey: .kase)
            try container.encode(value.rawValue, forKey: .type)
        }
    }
}

extension Configurations.Action: Hashable {}
