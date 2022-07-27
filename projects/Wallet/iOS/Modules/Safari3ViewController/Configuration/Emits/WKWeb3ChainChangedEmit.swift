//
//  WKWeb3ChainChangedEmit.swift
//  iOS
//
//  Created by Anton Spivak on 27.07.2022.
//

import Foundation
import JustonCORE

struct WKWeb3ChainChangedEmit: WKWeb3Emit {
    
    enum CodingKeys: CodingKey {
        
        case chainId
    }
    
    static var names: [String] {
        ["chainChanged"]
    }
    
    let chain: String
    
    init(
        chain: String
    ) {
        self.chain = chain
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(chain, forKey: .chainId)
    }
}
