//
//  Created by Anton Spivak
//

import Foundation

/// Storage that stores data secured in Keychain
public struct SecureStorage {
    
    private let queue = DispatchQueue(label: "com.hueton.ss", qos: .userInitiated)
    private let service = "HUETON"
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    /// Returns `Key` key for given address
    ///
    /// - parameter address: The address of key
    /// - returns: Optional `Key` for given `address`
    public func key(for rawAddress: Address.RawAddress) async throws -> Key? {
        let keys = try await keys()
        return keys.first(where: { $0.rawAddress == rawAddress })
    }
    
    /// Returns all stored keys in keychain
    ///
    /// - returns: Set of all stored keys `Key`
    public func keys() async throws -> Set<Key> {
        let account = "keys"
        let queue = self.queue
        let service = self.service
        let decoder = self.decoder
        
        return try await withCheckedThrowingContinuation({ continuation in
            queue.async(execute: {
                do {
                    var keys = Set<Key>()
                    if let data = try KeychainOperation.retreive(service: service, account: account) {
                        keys = try decoder.decode(Set<Key>.self, from: data)
                    }
                    continuation.resume(returning: keys)
                } catch {
                    continuation.resume(throwing: error)
                }
            })
        })
    }
    
    /// Saves key `Key` in keychain
    ///
    /// - parameter key: The key
    public func save(key: Key) async throws {
        let account = "keys"
        var keys = Set<Key>()
        
        if let data = try KeychainOperation.retreive(service: service, account: account) {
            keys = try self.decoder.decode(Set<Key>.self, from: data)
        }
        
        keys.insert(key)
        
        try await save(
            data: try self.encoder.encode(keys),
            account: account
        )
    }
    
    /// Removes stored key `Key` from  keychain
    ///
    /// - parameter key: The key
    public func remove(key: Key) async throws {
        let account = "keys"
        var keys = Set<Key>()
        
        if let data = try KeychainOperation.retreive(service: service, account: account) {
            keys = try self.decoder.decode(Set<Key>.self, from: data)
        }
        
        keys.remove(key)
        try await save(
            data: try self.encoder.encode(keys),
            account: account
        )
    }
    
    /// Removes all stored keys
    public func removeAllKeys() async throws {
        let account = "keys"
        return try await withCheckedThrowingContinuation({ continuation in
            queue.async(execute: {
                do {
                    try KeychainOperation.delete(service: service, account: account)
                    continuation.resume(returning: ())
                } catch {
                    continuation.resume(throwing: error)
                }
            })
        })
    }
    
    private func save(data: Data, account: String) async throws {
        let queue = self.queue
        let service = service
        
        try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<(), Error>) in
            queue.async(execute: {
                do {
                    if try KeychainOperation.exists(service: service, account: account) {
                        try KeychainOperation.update(service: service, value: data, account: account)
                    } else {
                        try KeychainOperation.add(service: service, value: data, account: account)
                    }
                    continuation.resume(returning: ())
                } catch {
                    continuation.resume(throwing: error)
                }
            })
        })
    }
}

fileprivate enum KeychainError: Error {
    
    /// Error with the keychain creting and checking
    case creatingError
    
    /// Error for operation
    case operationError
}

fileprivate class KeychainOperation: NSObject {
    
    /// Add an item to keychain
    ///
    /// - parameter service: The service
    /// - parameter value: Value to save in `data` format (String, Int, Double, Float, etc)
    /// - parameter account: Account name for keychain item
    static func add(
        service: String,
        value: Data,
        account: String
    ) throws {
        
        let status = SecItemAdd([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account,
            kSecAttrService: service,
            // Allow background access:
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock,
            kSecValueData: value,
            ] as NSDictionary, nil
        )
        
        guard status == errSecSuccess
        else {
            throw KeychainError.operationError
        }
    }
    
    /// Update an item to keychain
    ///
    /// - parameter service: The service
    /// - parameter value: Value to replace for
    /// - parameter account: Account name for keychain item
    static func update(
        service: String,
        value: Data,
        account: String
    ) throws {
        
        let status = SecItemUpdate(
            [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: account,
                kSecAttrService: service,
            ] as NSDictionary,
            [
                kSecValueData: value,
            ] as NSDictionary
        )
        
        guard status == errSecSuccess
        else {
            throw KeychainError.operationError
        }
    }
    
    /// Retrieve an item to keychain
    ///
    /// - parameter service: The service
    /// - parameter account: Account name for keychain item
    ///
    /// - returns: Data
    static func retreive(
        service: String,
        account: String
    ) throws -> Data? {
        
        var result: AnyObject?
        let status = SecItemCopyMatching(
            [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: account,
                kSecAttrService: service,
                kSecReturnData: true,
            ] as NSDictionary,
            &result
        )
        
        switch status {
        case errSecSuccess:
            return result as? Data
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainError.operationError
        }
    }
    
    /// Function to delete a single item
    ///
    /// - parameter service: The service
    /// - parameter account: Account name for keychain item
    static func delete(
        service: String,
        account: String
    ) throws {
        
        let status = SecItemDelete(
            [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: account,
                kSecAttrService: service,
            ] as NSDictionary
        )
        
        guard status == errSecSuccess
        else {
            throw KeychainError.operationError
        }
    }
    
    /// Delete all items for all services
    static func deleteAll() throws {
        
        let status = SecItemDelete(
            [
                kSecClass: kSecClassGenericPassword,
            ] as NSDictionary
        )
        
        guard status == errSecSuccess
        else {
            throw KeychainError.operationError
        }
    }
    
    /// Function to check if we've an existing a keychain `item`
    ///
    /// - parameter service: The service
    /// - parameter account: String type with the name of the item to check
    ///
    /// - returns: Boolean type with the answer if the keychain item exists
    static func exists(
        service: String,
        account: String
    ) throws -> Bool {
        
        let status = SecItemCopyMatching(
            [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: account,
                kSecAttrService: service,
                kSecReturnData: false,
            ] as NSDictionary,
            nil
        )
        
        switch status {
        case errSecSuccess:
            return true
        case errSecItemNotFound:
            return false
        default:
            throw KeychainError.creatingError
        }
    }
}
