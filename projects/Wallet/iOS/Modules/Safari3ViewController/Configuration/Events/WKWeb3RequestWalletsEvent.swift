//
//  WKWeb3RequestWalletsEvent.swift
//  iOS
//
//  Created by Anton Spivak on 28.06.2022.
//

import UIKit
import HuetonCORE

struct WKWeb3RequestWalletsEvent: WKWeb3Event {
    
    struct Body: Decodable {}
    
    struct Response: Encodable {
        
        let address: String
        let publicKey: String
        let walletVersion: String
    }
    
    static let names = ["ton_requestWallets"]
    
    func process(
        account: PersistenceAccount?,
        context: UIViewController,
        url: URL,
        _ body: Body
    ) async throws -> [Response] {
        guard let account = account,
              let keyPublic = account.keyPublic,
              let kind = account.selectedContract.kind
        else {
            throw WKWeb3Error(.unauthorized)
        }
        
        return [
            Response(
                address: account.convienceSelectedAddress.description,
                publicKey: keyPublic,
                walletVersion: kind.name
            )
        ]
    }
}
