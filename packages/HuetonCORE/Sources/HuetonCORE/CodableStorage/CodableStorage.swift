//
//  Created by Anton Spivak
//

import Foundation

/// Default storages
extension CodableStorage {
    
    public static let target: CodableStorage = CodableStorage(
        directoryURL: FileManager.default.directoryURL(with: .target, with: .persistent, pathComponent: "CodableStorage")
    )
    
    public static let group: CodableStorage = CodableStorage(
        directoryURL: FileManager.default.directoryURL(with: .group(), with: .persistent, pathComponent: "CodableStorage")
    )
}

/// Storage that stores data unsecured in filesystem
public struct CodableStorage {
    
    /// The key that will be used as filename
    public struct Key: RawRepresentable {
        
        public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    private let queue = DispatchQueue(label: "com.hueton.cs", qos: .userInitiated)
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private let fileManager = FileManager.default
    private let url: URL
    
    fileprivate init(directoryURL: URL) {
        url = directoryURL
    }
    
    public func save<T: Encodable>(value: T?, forKey key: Key) async throws {
        let queue = self.queue
        let url = self.url.appendingPathComponent(key.rawValue).appendingPathExtension("json")
        let fileManager = self.fileManager
        let encoder = self.encoder
        
        try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<(), Error>) in
            queue.async(execute: {
                do {
                    if let value = value {
                        let data = try encoder.encode(value)
                        try data.write(to: url)
                    } else {
                        try? fileManager.removeItem(at: url)
                    }
                    continuation.resume(returning: ())
                } catch {
                    continuation.resume(throwing: error)
                }
            })
        })
    }
    
    public func value<T: Decodable>(of type: T.Type, forKey key: Key) async throws -> T? {
        let queue = self.queue
        let url = self.url.appendingPathComponent(key.rawValue).appendingPathExtension("json")
        let decoder = self.decoder
        
        return try await withCheckedThrowingContinuation({ continuation in
            queue.async(execute: {
                do {
                    if let data = try? Data(contentsOf: url) {
                        let value = try decoder.decode(type, from: data)
                        continuation.resume(returning: value)
                    } else {
                        continuation.resume(returning: nil)
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            })
        })
    }
}

/// Simplified extension for getter/setter extensions
///
/// ```
/// extensinon CodableStorage.Methods {
///
///     func value() async throws -> [Value] {
///         return try await storage.value(Value.self for: .key)
///     }
/// }
///
/// try await CodableStorage.group.methods.value()
/// ```
extension CodableStorage {
    
    struct Methods {
        
        let storage: CodableStorage
    }
    
    var methods: Methods {
        Methods(storage: self)
    }
}
