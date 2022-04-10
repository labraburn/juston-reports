//
//  Created by Anton Spivak
//

import Foundation
import LocalAuthentication
import CryptoKit

@SecureParoleActor
internal enum SecureParoleAccessControl {
    
    enum Options {
        
        case secureEnclaveIfAvailable
    }
    
    case password(value: Data)
    case biometry
    
    var secAttrAccount: String {
        switch self {
        case .password:
            return "%@hcppp%@"
        case .biometry:
            return "%@hcpbb%@"
        }
    }
    
    var context: LAContext {
        let context = LAContext()
        context.touchIDAuthenticationAllowableReuseDuration = 5
        
        switch self {
        case let .password(value):
            let digest = SHA256.hash(data: value)
            context.setCredential(digest.data, type: .applicationPassword)
        case .biometry:
            break
        }
        
        return context
    }
    
    func secAccessControl(with options: [Options]) throws -> SecAccessControl {
        var flags = secAccessControlCreateFlags
        if options.contains(.secureEnclaveIfAvailable) && SecureEnclave.isDeviceAvailable {
            flags.insert(.privateKeyUsage)
        }
        return try _accessControlWithFlags(secAccessControlCreateFlags)
    }
    
    private var secAccessControlCreateFlags: SecAccessControlCreateFlags {
        var flags: SecAccessControlCreateFlags = []
        switch self {
        case .password:
            flags.insert(.applicationPassword)
        case .biometry:
            flags.insert(.biometryCurrentSet)
        }
        return flags
    }
    
    private func _accessControlWithFlags(
        _ flags: SecAccessControlCreateFlags
    ) throws -> SecAccessControl {
        var error: Unmanaged<CFError>?
        let secAccessControl = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            flags,
            &error
        )
        
        guard let secAccessControl = secAccessControl
        else {
            throw SecureParoleError.underlyingCFError(error: error)
        }
        
        return secAccessControl
    }
}

@SecureParoleActor
private extension Digest {
    
    var bytes: [UInt8] { Array(makeIterator()) }
    var data: Data { Data(bytes) }

    var hexStr: String {
        bytes.map { String(format: "%02X", $0) }.joined()
    }
}
