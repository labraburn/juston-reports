//
//  Created by Anton Spivak
//

import Foundation
import LocalAuthentication
import CryptoKit

@SecureParoleActor
public struct SecureParole {
    
    public var isTouchIDSupported: Bool {
        let context = LAContext()
        let biometricsEnrolled = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType == .touchID && biometricsEnrolled
    }
    
    public var isFaceIDSupported: Bool {
        let context = LAContext()
        let biometricsEnrolled = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType == .faceID && biometricsEnrolled
    }
    
    public var isKeyGenerated: Bool {
        let keyPair = SecureParoleEllipticCurveKeyPair(context: LAContext())
        
        let isKeyPairExists = (try? keyPair.exists()) ?? false
        let isPasswordExists = exists(with: .password(value: Data()))
        let isBiometryExists = exists(with: .biometry)
        
        return isKeyPairExists && isPasswordExists && isBiometryExists
    }
    
    nonisolated public init() {}
    
    public func retrieveKeyWithUserPassword(_ userPassword: String?) async throws -> Data? {
        if let userPassword = userPassword {
            guard let userPasswordData = userPassword.data(using: .utf8)
            else {
                throw SecureParoleError.userPasswordIsEmpty
            }
            
            return try await retrieve(with: .password(value: userPasswordData))
        } else {
            return try await retrieve(with: .biometry)
        }
    }
    
    public func generateKeyWithUserPassword(_ userPassword: String) throws {
        guard !isKeyGenerated
        else {
            throw SecureParoleError.applicationIsSet
        }
        
        let keyPair = SecureParoleEllipticCurveKeyPair(context: LAContext())
        try keyPair.generateKeyEllipticCurveKeyPair()
        
        guard let keyData = NSUUID().uuidString.data(using: .utf8),
              let userPasswordData = userPassword.data(using: .utf8)
        else {
            throw SecureParoleError.userPasswordIsEmpty
        }
        
        let encrypted = try keyPair.encrypt(keyData)
        
        try save(key: encrypted, with: .password(value: userPasswordData))
        try save(key: encrypted, with: .biometry)
    }
    
    public func removeKey() throws {
        try remove(with: .password(value: Data()))
        try remove(with: .biometry)
        
        let keyPair = SecureParoleEllipticCurveKeyPair(context: LAContext())
        try keyPair.delete()
    }
    
    // MARK: Private
    
    private func keychainQuery() -> NSMutableDictionary {
        [
            kSecClass : kSecClassGenericPassword,
            kSecAttrService : "HuetonCORE",
            kSecAttrAccessGroup : KeychainAccessGroup.shared.label,
            kSecUseDataProtectionKeychain : true,
            kSecUseAuthenticationUI : kSecUseAuthenticationUIFail,
            kSecAttrSynchronizable : false
        ]
    }
    
    private func retrieve(with accessControl: SecureParoleAccessControl) async throws -> Data? {
        let secAccessControl = try accessControl.secAccessControl(with: [.secureEnclaveIfAvailable])
        
        let context = accessControl.context
        try await context.evaluate(
            operation: .useItem,
            accessControl: secAccessControl,
            localizedReason: "We should know it's really you"
        )
        
        let query = keychainQuery()
        query[kSecAttrAccount] = accessControl.secAttrAccount
        query[kSecUseAuthenticationContext] = context
        query[kSecAttrAccessControl] = secAccessControl
        query[kSecReturnData] = true
        query[kSecMatchLimit] = kSecMatchLimitOne
        
        var ref: AnyObject? = nil
        let status = SecItemCopyMatching(query, &ref)
        
        let isApplicationPassword: Bool
        switch accessControl {
        case .password:
            isApplicationPassword = true
        case .biometry:
            isApplicationPassword = false
        }
        
        guard status == errSecSuccess || status == errSecItemNotFound
        else {
            if status == errSecInteractionNotAllowed && isApplicationPassword {
                throw SecureParoleError.wrongApplicationPassword
            } else {
                throw SecureParoleError.underlyingKeychainError(status: status)
            }
        }
        
        guard let data = ref as? Data
        else {
            return nil
        }
        
        let keyPair = SecureParoleEllipticCurveKeyPair(context: context)
        return try keyPair.decrypt(data)
    }
    
    private func save(key: Data, with accessControl: SecureParoleAccessControl) throws {
        try remove(with: accessControl)
        
        let query = keychainQuery()
        query[kSecValueData] = key
        query[kSecAttrAccount] = accessControl.secAttrAccount
        query[kSecUseAuthenticationContext] = accessControl.context
        query[kSecAttrAccessControl] = try accessControl.secAccessControl(with: [])
        
        let status = SecItemAdd(query, nil)
        guard status == errSecSuccess
        else {
            throw SecureParoleError.underlyingKeychainError(status: status)
        }
    }
    
    private func remove(with accessControl: SecureParoleAccessControl) throws {
        let query = keychainQuery()
        query[kSecAttrAccount] = accessControl.secAttrAccount
        
        let status = SecItemDelete(query)
        guard status == errSecSuccess || status == errSecItemNotFound
        else {
            throw SecureParoleError.underlyingKeychainError(status: status)
        }
    }
    
    private func exists(with accessControl: SecureParoleAccessControl) -> Bool {
        let query = keychainQuery()
        query[kSecAttrAccount] = accessControl.secAttrAccount
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        
        return status == noErr || status == errSecInteractionNotAllowed || status == errSecAuthFailed
    }
}
