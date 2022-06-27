//
//  WKWeb3EventBox.swift
//  iOS
//
//  Created by Anton Spivak on 27.06.2022.
//

import Foundation

struct WKWeb3EventBox {
    
    let name: String
    let process: (
        _ value: Data,
        _ decoder: JSONDecoder,
        _ encoder: JSONEncoder
    ) async throws -> Data
    
    init<T>(
        _ value: T.Type
    ) where T: WKWeb3Event, T.B: Decodable, T.R: Encodable {
        name = T.name
        process = { value, decoder, encoder in
            let decoded = try decoder.decode(T.B.self, from: value)
            let result = try await T.init().process(decoded)
            let encoded = try encoder.encode(result)
            return encoded
        }
    }
}
