//
//  Created by Anton Spivak
//

import Foundation

internal struct Agent {
    
    internal static let shared = Agent()
    
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    private init() {}
    
    public func perform<T>(_ request: T, moon: HuetonMOON) async throws -> T.R where T: Request {
        guard let absolute = moon.endpoint.appendingPathComponent(request.endpoint).absoluteString.removingPercentEncoding,
              let url = URL(string: absolute)
        else {
            throw Error.url(URLError(.badURL))
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.kind.rawValue
        urlRequest.allHTTPHeaderFields = request.headers.merging(with: moon.headers)
        
        switch request.headers["Content-Type"] {
        case "application/json":
            let httpBody = try request.parameters.encode(with: encoder)
            guard httpBody.count > 2
            else {
                break
            }
            // TODO: fix 2 is 'empty' body like '{}' string
            urlRequest.httpBody = httpBody
        default:
            throw Error.unsupportedContentType
        }
        
        let (data, response) = try await session._data(for: urlRequest)
        guard let response = response as? HTTPURLResponse
        else {
            throw Error.http(nil)
        }
        
        guard response.statusCode < 400
        else {
            throw Error.http(response)
        }
        
        let decoded: T.R
        do {
            decoded = try decoder.decode(T.R.self, from: data)
        } catch {
            throw Error.decoding(error)
        }
        
        return decoded
    }
}
