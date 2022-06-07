//
//  Created by Anton Spivak
//

import Foundation

public typealias Middleware = (_ response: HTTPURLResponse) throws -> Void
