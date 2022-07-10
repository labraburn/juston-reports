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
        logging: .debug,
        keystoreURL: FileManager.default.directoryURL(with: .group(), with: .persistent, pathComponent: .glossyTONKeystore)
    )
    
    static let main = Configuration(
        network: .main,
        logging: Configuration.defaultLogging,
        keystoreURL: FileManager.default.directoryURL(with: .group(), with: .persistent, pathComponent: .glossyTONKeystore)
    )
    
    private static var defaultLogging: Logging {
        #if DEBUG
        return .info
        #else
        return .never
        #endif
    }
}

public struct HuetonCORE {
    
    /// Initialize HuetonCORE and it's dependencies
    public static func initialize() {
        AccountAppearanceTransformer.register()
        BrowserBannerActionTransformer.register()
        
        SwiftyTON.configurate(with: .test)
        ManagedObjectContextObjectsDidChangeObserver.startObservingIfNeccessary()
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            Task {
                guard let address = await DNSAddress(string: "hueton.ton")
                else {
                    return
                }
                
                print(address)
            }
        })
    }
}
