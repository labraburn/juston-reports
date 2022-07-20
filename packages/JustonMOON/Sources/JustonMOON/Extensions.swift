//
//  Created by Anton Spivak.
//

import Foundation

internal extension Dictionary {
    
    func merging(with dictionary: [Key : Value]) -> [Key : Value] {
        var copy = self
        for (key, value) in dictionary {
            copy.updateValue(value, forKey: key)
        }
        return copy
    }
}

internal extension Encodable {
    
    func encode(with encoder: JSONEncoder) throws -> Data {
        try encoder.encode(self)
    }
}

extension URLSession {
    
    internal func _data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if #available(iOS 15, macOS 12, *) {
            return try await data(for: request)
        } else {
            return try await _data_ios_14_and_lower(for: request)
        }
    }

    private func _data_ios_14_and_lower(for request: URLRequest) async throws -> (Data, URLResponse) {
        var task: URLSessionDataTask?
        let cancellation = { [weak task] in
            task?.cancel()
        }
        
        return try await withTaskCancellationHandler(
            handler: {
                cancellation()
            },
            operation: {
                try await withCheckedThrowingContinuation { [weak self] continuation in
                    task = self?.dataTask(with: request) { data, response, error in
                        guard let data = data,
                              let response = response
                        else {
                            let error = error ?? URLError(.badServerResponse)
                            return continuation.resume(throwing: error)
                        }
                        continuation.resume(returning: (data, response))
                    }
                    task?.resume()
                }
            }
        )
    }
}
