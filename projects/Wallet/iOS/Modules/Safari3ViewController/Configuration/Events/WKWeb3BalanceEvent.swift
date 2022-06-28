//
//  WKWeb3BalanceEvent.swift
//  iOS
//
//  Created by Anton Spivak on 28.06.2022.
//

import UIKit
import HuetonCORE

struct WKWeb3BalanceEvent: WKWeb3Event {
    
    struct Body: Decodable {}
    
    struct Response: Encodable {
        
        let address: String
        let publicKey: String
        let walletVersion: String
    }
    
    static let names = ["ton_getBalance"]
    
    func process(
        account: PersistenceAccount?,
        context: UIViewController,
        url: URL,
        _ body: Body
    ) async throws -> String {
        guard let account = account
        else {
            throw WKWeb3Error(.unauthorized)
        }
        
        let contract = try await Contract(rawAddress: account.selectedContract.address)
        return "\(contract.info.balance.value)"
    }
}
