//
//  WKWeb3AccountsChangedEmit.swift
//  iOS
//
//  Created by Anton Spivak on 28.06.2022.
//

import Foundation
import JustonCORE

typealias WKWeb3AccountsChangedEmit = [String]

extension WKWeb3AccountsChangedEmit: WKWeb3Emit {
    
    static var names: [String] {
        ["ton_accounts", "accountsChanged"]
    }
    
    init(
        accounts: [PersistenceAccount]
    ) {
        self.init(
            accounts.map({
                return $0.convienceSelectedAddress.description
            })
        )
    }
}
