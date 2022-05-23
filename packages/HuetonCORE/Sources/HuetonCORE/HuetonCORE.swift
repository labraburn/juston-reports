//
//  Created by Anton Spivak
//

import Foundation
import CoreData
import Objective42

@_exported import SwiftyTON

private extension Configuration {
    
    static let test = Configuration(
        network: .test,
        configurationFileURL: URL(string: "https://newton-blockchain.github.io/testnet-global.config.json")!,
        keystoreURL: FileManager.default.directoryURL(with: .group(), with: .persistent, pathComponent: .glossyTONKeystore),
        logging: .debug
    )
    
    static let main = Configuration(
        network: .main,
        configurationFileURL: URL(string: "https://newton-blockchain.github.io/global.config.json")!,
        keystoreURL: FileManager.default.directoryURL(with: .group(), with: .persistent, pathComponent: .glossyTONKeystore),
        logging: .debug
    )
}

public struct HuetonCORE {
    
    /// Initialize HuetonCORE and it's dependencies
    public static func initialize() {
        AccountAppearanceTransformer.register()
        SwiftyTON.configurate(with: .main)
        ManagedObjectContextObjectsDidChangeObserver.startObservingIfNeccessary()
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
