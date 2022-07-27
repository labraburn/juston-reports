//
//  WKWeb3RequestChainEvent.swift
//  iOS
//
//  Created by Anton Spivak on 27.07.2022.
//

import UIKit
import JustonCORE

struct WKWeb3RequestChainEvent: WKWeb3Event {
    
    struct Body: Decodable {}
    
    struct Response: Encodable {
        
        let chainId: String
    }
    
    static let names = ["ton_requestChain"]
    
    func process(
        account: PersistenceAccount?,
        context: UIViewController,
        url: URL,
        _ body: Body
    ) async throws -> [Response] {
        return [
            Response(
                chainId: SwiftyTON.configuration.network.rawValue
            )
        ]
    }
}
