//
//  Created by Anton Spivak
//

import Foundation

public protocol HuetonMOON {
    
    var endpoint: URL { get }
    
    var middlewares: [Middleware] { get }
    var headers: [String : String] { get }
}

public extension HuetonMOON {
    
    var middlewares: [Middleware] { [] }
    var headers: [String : String] { [:] }
}

public extension HuetonMOON {
    
    func `do`<T>(_ request: T) async throws -> T.R where T: Request {
        try await Agent.shared.perform(request, moon: self)
    }
}
