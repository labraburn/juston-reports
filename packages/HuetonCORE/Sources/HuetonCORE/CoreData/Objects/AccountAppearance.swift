//
//  Created by Anton Spivak
//

import Foundation

public struct AccountAppearance {
    
    public static let `default` = AccountAppearance(
        kind: .glass(gradient0Color: 0xEB03FFFF, gradient1Color: 0x23FFD7A5),
        tintColor: 0xFFFFFFFF,
        controlsForegroundColor: 0x000000FF,
        controlsBackgroundColor: 0xFFFFFFFF
    )
    
    public enum Kind {
        
        case glass(gradient0Color: Int, gradient1Color: Int)
        case gradientImage(imageData: Data, shadowColor: Int)
    }
    
    public let kind: Kind
    public let tintColor: Int
    public let controlsForegroundColor: Int
    public let controlsBackgroundColor: Int
}

extension AccountAppearance: Codable {
    
    public enum CodingKeys: CodingKey {
        
        case kind
        case tintColor
        case controlsForegroundColor
        case controlsBackgroundColor
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        kind = (try? container.decode(Kind.self, forKey: .kind)) ?? AccountAppearance.default.kind
        tintColor = (try? container.decode(Int.self, forKey: .tintColor)) ?? AccountAppearance.default.tintColor
        controlsForegroundColor = (try? container.decode(Int.self, forKey: .controlsForegroundColor)) ?? AccountAppearance.default.controlsForegroundColor
        controlsBackgroundColor = (try? container.decode(Int.self, forKey: .controlsBackgroundColor)) ?? AccountAppearance.default.controlsBackgroundColor
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(kind, forKey: .kind)
        try container.encode(tintColor, forKey: .tintColor)
        try container.encode(controlsForegroundColor, forKey: .controlsForegroundColor)
        try container.encode(controlsBackgroundColor, forKey: .controlsBackgroundColor)
    }
}

extension AccountAppearance.Kind: Codable {
    
    public enum CodingKeys: CodingKey {
        
        case kase
        
        case gradient0Color
        case gradient1Color
        
        case imageData
        case shadowColor
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let kase = try container.decode(String.self, forKey: .kase)
        switch kase {
        case "glass":
            self = .glass(
                gradient0Color: (try? container.decode(Int.self, forKey: .gradient0Color)) ?? 0xEB03FFFF,
                gradient1Color: (try? container.decode(Int.self, forKey: .gradient1Color)) ?? 0x23FFD7A5
            )
        case "gradientImage":
            self = .gradientImage(
                imageData: (try? container.decode(Data.self, forKey: .imageData)) ?? Data(),
                shadowColor: (try? container.decode(Int.self, forKey: .shadowColor)) ?? 0x000000FF
            )
        default:
            self = .glass(
                gradient0Color: (try? container.decode(Int.self, forKey: .gradient0Color)) ?? 0xEB03FFFF,
                gradient1Color: (try? container.decode(Int.self, forKey: .gradient1Color)) ?? 0x23FFD7A5
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .glass(gradient0Color, gradient1Color):
            try container.encode("glass", forKey: .kase)
            try container.encode(gradient0Color, forKey: .gradient0Color)
            try container.encode(gradient1Color, forKey: .gradient1Color)
        case let .gradientImage(imageData, shadowColor):
            try container.encode("glass", forKey: .kase)
            try container.encode(imageData, forKey: .imageData)
            try container.encode(shadowColor, forKey: .shadowColor)
        }
    }
}
