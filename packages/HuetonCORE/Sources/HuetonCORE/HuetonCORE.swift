//
//  Created by Anton Spivak
//

import Foundation
import CoreData

@_exported import SwiftyTON

public struct HuetonCORE {
    
    public static func initialize() {
        SwiftyTON.configurate(with: .main)
        UInt8ArrayTransformer.register()
    }
    
    public static func KeyCreate() async throws -> (key: Key, words: [String]) {
        let result = try await Key.create(password: Data(), mnemonic: Data())
        
        let storage = SecureStorage()
        try await storage.save(key: result.0)
        
        return result
    }
}


// PROD
//
// Balance: ?
// Address: "EQBKCMGcAoyyG85L3SIakVRLMfwhp7-xA13jTWAYO1jgpb81" // v4r2
// Words: []

// PROD
//
// Balance: ?
// Address: "EQCMfNwPB8TaNqQ9hnXCYcXOz41jfI5PCawHe1ZvwKfKXTXM" // united
// Words: []

// PROD
//
// Balance: 34
// Address: EQCd3ASamrfErTV4K6iG5r0o3O_hl7K_9SghU0oELKF-sxDn // v3r2
// Words: []

// TEST
//
// Balance: 14.9
// Address: EQAVhOY2uT49tcvM6rRJII25bgEqEBWu6ZywXrtaqYtvIlMk
// Address: EQCIJiFJrN8kuwdXEIfmJ-D7qwP-QfLX8YtCAhaY6AoSKxUv ????????????????????????????????
// Words: ["episode", "diary", "tower", "either", "void", "into", "until", "universe", "loan", "answer", "own", "ribbon", "adapt", "step", "tuna", "innocent", "accident", "female", "already", "nasty", "wrist", "tenant", "toast", "post"]
