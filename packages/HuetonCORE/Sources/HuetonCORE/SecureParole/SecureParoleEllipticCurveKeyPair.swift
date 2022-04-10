//
//  Created by Anton Spivak
//  Inspired by https://github.com/agens-no/EllipticCurveKeyPair
//

import Foundation
import Security
import LocalAuthentication
import CryptoKit

@SecureParoleActor
internal struct SecureParoleEllipticCurveKeyPair {
    
    let context: LAContext
    
    init(context: LAContext) {
        self.context = context
    }
    
    // MARK: Create & Removing
    
    public func exists() throws -> Bool {
        do {
            let pbexists = try Query.public.exists()
            let prexists = try Query.private(context: context).exists()
            return pbexists && prexists
        } catch {
            return false
        }
    }
    
    public func generateKeyEllipticCurveKeyPair() throws {
        guard !(try exists())
        else {
            return
        }
        
        let query = try Query.generate(context: context).query()
        
        var pbkey, prkey: SecKey?
        let status = SecKeyGeneratePair(query, &pbkey, &prkey)
        
        guard status == errSecSuccess, let pbkey = pbkey
        else {
            throw SecureParoleError.underlyingKeychainError(status: status)
        }
        
        try Query.updatePublicKeyForcibly(key: pbkey)
    }
    
    public func delete() throws {
        try Query.public.delete()
        try Query.private(context: context).delete()
    }
    
    // MARK: Operations
    
    public func sign(_ digest: Data, hash: Hash = .sha256) throws -> Data {
        let privateKey = try Query.retrivePrivateKey(context: context)
        
        var error : Unmanaged<CFError>?
        let result = SecKeyCreateSignature(privateKey, hash.signatureMessage, digest as CFData, &error)
        
        guard let signature = result
        else {
            throw SecureParoleError.underlyingCFError(error: error)
        }
        
        return signature as Data
    }
    
    public func verify(signature: Data, digest: Data, hash: Hash = .sha256) throws {
        let publicKey = try Query.retrivePublicKey()
        
        var error : Unmanaged<CFError>?
        let valid = SecKeyVerifySignature(publicKey, hash.signatureMessage, digest as CFData, signature as CFData, &error)
        
        if let error = error {
            throw SecureParoleError.underlyingCFError(error: error)
        }
        
        guard valid == true
        else {
            throw SecureParoleError.cantVerifySignature
        }
    }
    
    public func encrypt(_ digest: Data, hash: Hash = .sha256) throws -> Data {
        let publicKey = try Query.retrivePublicKey()
        
        var error : Unmanaged<CFError>?
        let result = SecKeyCreateEncryptedData(publicKey, hash.encryptionEciesEcdh, digest as CFData, &error)
        
        guard let data = result
        else {
            throw SecureParoleError.underlyingCFError(error: error)
        }
        
        return data as Data
    }
    
    public func decrypt(_ encrypted: Data, hash: Hash = .sha256) throws -> Data {
        let privateKey = try Query.retrivePrivateKey(context: context)
        
        var error : Unmanaged<CFError>?
        let result = SecKeyCreateDecryptedData(privateKey, hash.encryptionEciesEcdh, encrypted as CFData, &error)
        
        guard let data = result
        else {
            throw SecureParoleError.underlyingCFError(error: error)
        }
        
        return data as Data
    }
    
    private enum Query {
        
        private enum Label {
            
            case `public`
            case `private`
            
            var label: String {
                let prefix = "com.hueton.secure-enclave"
                switch self {
                case .public:
                    return "\(prefix).public"
                case .private:
                    return "\(prefix).private"
                }
            }
        }
        
        case `public`
        case `private`(context: LAContext)
        case generate(context: LAContext)
        case updatePublicKey(key: SecKey)
        
        // MARK: API
        
        static func retrivePublicKey() throws -> SecKey {
            try Query.public.get()
        }
        
        static func retrivePrivateKey(context: LAContext) throws -> SecKey {
            try Query.private(context: context).get()
        }
        
        static func updatePublicKeyForcibly(key: SecKey) throws {
            let query = try Query.updatePublicKey(key: key).query()
            
            var raw: CFTypeRef?
            var status = SecItemAdd(query, &raw)
            
            if status == errSecDuplicateItem {
                status = SecItemDelete(query)
                status = SecItemAdd(query, &raw)
            }
            
            guard status == errSecSuccess
            else {
                throw SecureParoleError.underlyingKeychainError(status: status)
            }
        }
        
        func delete() throws {
            let query = try query()
            let status = SecItemDelete(query)
            
            guard status == errSecSuccess || status == errSecItemNotFound
            else {
                throw SecureParoleError.underlyingKeychainError(status: status)
            }
        }
        
        func get() throws -> SecKey {
            var result: CFTypeRef?
            let status = SecItemCopyMatching(try query(), &result)
            
            guard status == errSecSuccess, let result = result
            else {
                throw SecureParoleError.underlyingKeychainError(status: status)
            }
            
            return result as! SecKey
        }
        
        func exists() throws -> Bool {
            var result: CFTypeRef?
            let status = SecItemCopyMatching(try query(), &result)
            return status == noErr || status == errSecInteractionNotAllowed || status == errSecAuthFailed
        }
        
        func query() throws -> NSDictionary {
            switch self {
            case .public:
                return [
                    kSecClass : kSecClassKey,
                    kSecAttrKeyClass : kSecAttrKeyClassPublic,
                    kSecAttrLabel : Label.public.label,
                    kSecReturnRef : true,
                    kSecAttrAccessGroup : KeychainAccessGroup.shared.label,
                    kSecAttrSynchronizable : false,
                ]
            case let .private(context):
                return [
                    kSecClass : kSecClassKey,
                    kSecAttrKeyClass : kSecAttrKeyClassPrivate,
                    kSecAttrLabel : Label.private.label,
                    kSecReturnRef : true,
                    kSecAttrAccessGroup : KeychainAccessGroup.shared.label,
                    kSecUseAuthenticationContext : context,
                    kSecAttrSynchronizable : false,
                ]
            case let .generate(context):
                let pbquery = [
                    kSecAttrLabel : Label.public.label,
                    kSecAttrAccessGroup : KeychainAccessGroup.shared.label,
                    kSecAttrAccessControl : try AccessControl(
                        protection: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
                        flags: []
                    ).underlying(),
                    kSecAttrSynchronizable : false,
                ] as NSDictionary
                
                let prquery = [
                    kSecAttrLabel : Label.private.label,
                    kSecAttrIsPermanent : true,
                    kSecAttrAccessGroup : KeychainAccessGroup.shared.label,
                    kSecUseAuthenticationContext : context,
                    kSecAttrAccessControl : try AccessControl(
                        protection: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
                        flags: SecureEnclave.isDeviceAvailable ? .privateKeyUsage : []
                    ).underlying(),
                    kSecAttrSynchronizable : false,
                ] as NSDictionary
                
                let query = [
                    kSecAttrKeyType : kSecAttrKeyTypeECSECPrimeRandom,
                    kSecPublicKeyAttrs : pbquery,
                    kSecPrivateKeyAttrs : prquery,
                    kSecAttrKeySizeInBits : 256,
                    kSecAttrAccessGroup : KeychainAccessGroup.shared.label,
                    kSecAttrSynchronizable : false,
                ] as NSMutableDictionary
                
                if SecureEnclave.isDeviceAvailable {
                    query[kSecAttrTokenID] = kSecAttrTokenIDSecureEnclave
                }
                
                return query
            case let .updatePublicKey(key):
                return [
                    kSecClass : kSecClassKey,
                    kSecAttrLabel : Label.public.label,
                    kSecAttrAccessGroup : KeychainAccessGroup.shared.label,
                    kSecValueRef : key,
                    kSecAttrSynchronizable : false,
                ]
            }
        }
    }
    
    private final class AccessControl {
        
        public let protection: CFTypeRef
        public let flags: SecAccessControlCreateFlags
        
        public init(protection: CFTypeRef, flags: SecAccessControlCreateFlags) {
            self.protection = protection
            self.flags = flags
        }
        
        public func underlying() throws -> SecAccessControl {
            var error: Unmanaged<CFError>?
            let result = SecAccessControlCreateWithFlags(kCFAllocatorDefault, protection, flags, &error)
            
            guard let result = result
            else {
                throw SecureParoleError.underlyingCFError(error: error)
            }
            
            return result
        }
    }
    
    public enum Hash: String {
        
        case sha1
        case sha224
        case sha256
        case sha384
        case sha512
        
        var signatureMessage: SecKeyAlgorithm {
            switch self {
            case .sha1:
                return SecKeyAlgorithm.ecdsaSignatureMessageX962SHA1
            case .sha224:
                return SecKeyAlgorithm.ecdsaSignatureMessageX962SHA224
            case .sha256:
                return SecKeyAlgorithm.ecdsaSignatureMessageX962SHA256
            case .sha384:
                return SecKeyAlgorithm.ecdsaSignatureMessageX962SHA384
            case .sha512:
                return SecKeyAlgorithm.ecdsaSignatureMessageX962SHA512
            }
        }
        
        var encryptionEciesEcdh: SecKeyAlgorithm {
            switch self {
            case .sha1:
                return SecKeyAlgorithm.eciesEncryptionStandardX963SHA1AESGCM
            case .sha224:
                return SecKeyAlgorithm.eciesEncryptionStandardX963SHA224AESGCM
            case .sha256:
                return SecKeyAlgorithm.eciesEncryptionStandardX963SHA256AESGCM
            case .sha384:
                return SecKeyAlgorithm.eciesEncryptionStandardX963SHA384AESGCM
            case .sha512:
                return SecKeyAlgorithm.eciesEncryptionStandardX963SHA512AESGCM
            }
        }
    }
}
