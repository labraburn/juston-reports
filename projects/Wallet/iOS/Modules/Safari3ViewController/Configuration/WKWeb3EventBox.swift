//
//  WKWeb3EventBox.swift
//  iOS
//
//  Created by Anton Spivak on 27.06.2022.
//

import UIKit
import HuetonCORE

struct WKWeb3EventBox {
    
    let names: [String]
    let process: (
        _ account: PersistenceAccount?,
        _ context: UIViewController,
        _ url: URL,
        _ value: Data,
        _ decoder: JSONDecoder,
        _ encoder: JSONEncoder
    ) async throws -> Data
    
    init<T>(
        _ value: T.Type
    ) where T: WKWeb3Event, T.B: Decodable, T.R: Encodable {
        names = T.names
        process = { account, context, url, value, decoder, encoder in
            let decoded = try decoder.decode(T.B.self, from: value)
            let result = try await T.init().process(
                account: account,
                context: context,
                url: url,
                decoded
            )
            
            return try encoder.encode(
                result
            )
        }
    }
}
