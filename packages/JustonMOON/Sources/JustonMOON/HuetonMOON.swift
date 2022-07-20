//
//  Created by Anton Spivak
//

import Foundation

public protocol JustonMOON {
    
    var endpoint: URL { get }
    
    var middlewares: [Middleware] { get }
    var headers: [String : String] { get }
}

public extension JustonMOON {
    
    var middlewares: [Middleware] { [] }
    var headers: [String : String] { [:] }
}

public extension JustonMOON {
    
    func `do`<T>(_ request: T) async throws -> T.R where T: Request {
        try await Agent.shared.perform(request, moon: self)
    }
}
