//
//  WKWeb3SignEvent.swift
//  iOS
//
//  Created by Anton Spivak on 27.06.2022.
//

import Foundation

struct WKWeb3SignEvent: WKWeb3Event {
    
    struct Body: Decodable {
        
        let value: String
    }
    
    struct Response: Encodable {
        
        let value2: Int
    }
    
    typealias B = Body
    typealias R = Response
    
    static let name = "sign"
    
    func process(
        _ body: Body
    ) async throws -> Response {
        throw WKWeb3Error(.chainDisconnected)
//        Response(value2: 56)
    }
}
