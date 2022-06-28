//
//  WKWeb3RequestAccountsEvent.swift
//  iOS
//
//  Created by Anton Spivak on 27.06.2022.
//

import UIKit
import HuetonCORE

struct WKWeb3RequestAccountsEvent: WKWeb3Event {
    
    struct Body: Decodable {}
    
    static let names = ["ton_requestAccounts"]
    
    func process(
        account: PersistenceAccount?,
        context: UIViewController,
        url: URL,
        _ body: Body
    ) async throws -> [String] {
        guard let account = account
        else {
            throw WKWeb3Error(.unauthorized)
        }
        
        let address = Address(rawValue: account.selectedContract.address)
        return [address.convert(to: .base64url(flags: [.bounceable]))]
    }
}
