//
//  Created by Anton Spivak
//

import Foundation

public enum SecureParoleError {
    
    case userPasswordIsEmpty
    case wrongApplicationPassword
    case applicationIsSet
    
    case cantVerifySignature
    case cantEvaluateDeviceOwnerAuthenticationWithBiometrics
    
    case underlyingCFError(error: Unmanaged<CFError>?)
    case underlyingKeychainError(status: OSStatus)
}

extension SecureParoleError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .userPasswordIsEmpty:
            return "User password is empty"
        case .wrongApplicationPassword:
            return "Wrong application password"
        case .applicationIsSet:
            return "Application password already set"
        case .cantVerifySignature:
            return "Can't verify signature"
        case .cantEvaluateDeviceOwnerAuthenticationWithBiometrics:
            return "Can't evaluate device owner authentication with biometrics"
        case let .underlyingCFError(error):
            return error?.takeUnretainedValue().localizedDescription
        case let .underlyingKeychainError(status):
            return "Error with OSStatus: \(status)"
        }
    }
}
