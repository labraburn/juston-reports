//
//  Created by Anton Spivak
//

import Foundation

public enum BrowserBannerAction {
    
    case unknown
    
    case url(value: URL)
    case inapp(value: InApp)
}

extension BrowserBannerAction: Codable {
    
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
            guard let string = try? container.decode(String.self, forKey: .url),
                  let url = URL(string: string)
            else {
                self = .unknown
                return
            }
            self = .url(value: url)
        case "inapp":
            guard let string = try? container.decode(String.self, forKey: .type),
                  let inapp = InApp(rawValue: string)
            else {
                self = .unknown
                return
            }
            self = .inapp(value: inapp)
        default:
            self = .unknown
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .unknown:
            try container.encode("unknown", forKey: .kase)
        case let .url(value):
            try container.encode("url", forKey: .kase)
            try container.encode(value, forKey: .url)
        case let .inapp(value):
            try container.encode("inapp", forKey: .kase)
            try container.encode(value.rawValue, forKey: .type)
        }
    }
}

extension BrowserBannerAction: Hashable {}
