//
//  Account.swift
//  iOS
//
//  Created by Anton Spivak on 21.03.2022.
//

import Foundation
import SwiftyTON

struct Account {
    
    let name: String
    let rawAddress: Address.RawAddress
}

extension Account: Codable {}
extension Account: Hashable {}

extension CodableStorage.Methods {
    
    func accounts() async -> [Account] {
        (try? await storage.value(of: [Account].self, forKey: .accounts)) ?? []
    }
    
    func save(accounts: [Account]) {
        Task {
            try? await storage.save(value: accounts, forKey: .accounts)
        }
    }
}

fileprivate extension CodableStorage.Key {
    
    static var accounts: CodableStorage.Key {
        CodableStorage.Key(rawValue: "accounts")
    }
}
