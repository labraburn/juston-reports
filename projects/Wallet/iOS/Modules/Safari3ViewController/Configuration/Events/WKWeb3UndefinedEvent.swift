//
//  WKWeb3UndefinedEvent.swift
//  iOS
//
//  Created by Anton Spivak on 28.06.2022.
//

import UIKit
import HuetonCORE

struct WKWeb3UndefinedEvent: WKWeb3Event {
    
    struct Body: Decodable {}
    struct Response: Encodable {}
    
    static let names = ["_undefined"]
    
    func process(
        account: PersistenceAccount?,
        context: UIViewController,
        _ body: Body
    ) async throws -> Response {
        throw WKWeb3Error(.unsupportedMethod)
    }
}
