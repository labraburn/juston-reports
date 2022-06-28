//
//  Created by Anton Spivak
//

import Foundation

public struct FailableDecodable<T : Decodable> : Decodable {

    public let value: T?

    public init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.singleValueContainer()
        value = try? container.decode(T.self)
    }
}
