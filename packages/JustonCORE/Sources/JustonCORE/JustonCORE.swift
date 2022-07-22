//
//  Created by Anton Spivak
//

import Foundation
import CoreData
import Objective42

@_exported import SwiftyTON

public extension Configuration {
    
    static let test = Configuration(
        network: .test,
        logging: .debug,
        keystoreURL: FileManager.default.directoryURL(with: .group(), with: .persistent, pathComponent: .glossyTONKeystore)
    )
    
    static let main = Configuration(
        network: .main,
        logging: .warning,
        keystoreURL: FileManager.default.directoryURL(with: .group(), with: .persistent, pathComponent: .glossyTONKeystore)
    )
}

public struct JustonCORE {
    
    /// Initialize JustonCORE and it's dependencies
    public static func initialize() {
        AccountAppearanceTransformer.register()
        BrowserBannerActionTransformer.register()
        
        SwiftyTON.configurate(with: .main)
        ManagedObjectContextObjectsDidChangeObserver.startObservingIfNeccessary()
    }
}
