//
//  WKWeb3ChainChangedEmit.swift
//  iOS
//
//  Created by Anton Spivak on 27.07.2022.
//

import Foundation
import JustonCORE

struct WKWeb3ChainChangedEmit: WKWeb3Emit {
    
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
        var container = encoder.singleValueContainer()
        try container.encode([chain])
    }
}
