//
//  WKWeb3AuthenticateEvent.swift
//  iOS
//
//  Created by Anton Spivak on 27.06.2022.
//

import Foundation

struct WKWeb3AuthenticateEvent: WKWeb3Event {
    
    struct Body: Decodable {
        
        let value: String
    }
    
    struct Response: Encodable {
        
        let value2: Int
    }
    
    typealias B = Body
    typealias R = Response
    
    static let name = "authenticate"
    
    func process(
        _ body: Body
    ) async throws -> Response {
        Response(value2: 56)
    }
}
