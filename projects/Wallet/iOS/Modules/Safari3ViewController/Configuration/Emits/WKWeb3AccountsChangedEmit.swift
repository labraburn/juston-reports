//
//  WKWeb3AccountsChangedEmit.swift
//  iOS
//
//  Created by Anton Spivak on 28.06.2022.
//

import Foundation
import JustonCORE

struct WKWeb3AccountsChangedEmit: WKWeb3Emit {
    
    static var names: [String] {
        ["accountsChanged"]
    }
    
    let accounts: [String]
    
    init(
        accounts: [PersistenceAccount]
    ) {
        self.accounts = accounts.map({
            return $0.convienceSelectedAddress.description
        })
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(accounts)
    }
}
