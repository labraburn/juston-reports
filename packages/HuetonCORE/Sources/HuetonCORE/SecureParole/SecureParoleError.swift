//
//  Created by Anton Spivak
//

import Foundation

public enum SecureParoleError: Error {
    
    case userPasswordIsEmpty
    case wrongApplicationPassword
    case applicationIsSet
    
    case cantVerifySignature
    case cantEvaluateDeviceOwnerAuthenticationWithBiometrics
    
    case underlyingCFError(error: Unmanaged<CFError>?)
    case underlyingKeychainError(status: OSStatus)
}
