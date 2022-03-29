//
//  Created by Anton Spivak
//

import Foundation
import SwiftyTON

/// Default storages
extension CodableStorage {
    
    private static var targetDirectoryURL: URL = {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent("CodableStorage")
    }()
    
    private static var groupDirectoryURL: URL = {
        let fileManager = FileManager.default
        guard let url = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.hueton")
        else {
            fatalError("[CodableStorage]: Could not resolve url for Application Group.")
        }
        return url.appendingPathComponent("CodableStorage")
    }()
    
    static let target: CodableStorage = CodableStorage(directoryURL: targetDirectoryURL)
    static let group: CodableStorage = CodableStorage(directoryURL: groupDirectoryURL)
}

/// Storage that stores data unsecured in filesystem
public struct CodableStorage {
    
    /// The key that will be used as filename
    struct Key: RawRepresentable {
        
        var rawValue: String
        
        init(rawValue: String) {
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
    
    func save<T: Encodable>(value: T?, forKey key: Key) async throws {
        try checkDirecoryExistsAndCreateIfNeccessary()
        
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
    
    func value<T: Decodable>(of type: T.Type, forKey key: Key) async throws -> T? {
        try checkDirecoryExistsAndCreateIfNeccessary()
        
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
    
    private func checkDirecoryExistsAndCreateIfNeccessary() throws {
        var bool = ObjCBool(false)
        if fileManager.fileExists(atPath: url.relativePath, isDirectory: &bool) {
            if !bool.boolValue {
                throw URLError(.cannotWriteToFile)
            }
        } else {
            try fileManager.createDirectory(
                at: url,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
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
/// try await CodableStorage.group.value()
/// ```
extension CodableStorage {
    
    struct Methods {
        
        let storage: CodableStorage
    }
    
    var methods: Methods {
        Methods(storage: self)
    }
}
