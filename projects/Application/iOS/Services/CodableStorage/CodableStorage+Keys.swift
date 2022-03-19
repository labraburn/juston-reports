//
//  CodableStorage+Keys.swift
//  iOS
//
//  Created by Anton Spivak on 19.03.2022.
//

import Foundation
import SwiftyTON

extension CodableStorage.Key {
    
    static func wallet(for rawAddress: Address.RawAddress) -> CodableStorage.Key {
        CodableStorage.Key(rawValue: "wallet_\(rawAddress.rawValue)")
    }
    
    static func lastTransactions(for rawAddress: Address.RawAddress) -> CodableStorage.Key {
        CodableStorage.Key(rawValue: "last_transactions_\(rawAddress.rawValue)")
    }
}
