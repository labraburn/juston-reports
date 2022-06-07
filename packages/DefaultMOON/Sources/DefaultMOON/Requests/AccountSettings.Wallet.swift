//
//  File.swift
//  
//
//  Created by Anton Spivak on 06.06.2022.
//

import Foundation

public extension AccountSettings {
    
    struct Wallet {
        
        /// rawAddress: 0:232425762ewfq
        public let address: String
        
        public let notification_settings: NotificationSettings?
        
        /// - parameter address: Raw TON address (workchain:hex)
        public init(
            address: String,
            notification_settings: NotificationSettings?
        ) {
            self.address = address
            self.notification_settings = notification_settings
        }
    }
}

extension AccountSettings.Wallet: Codable {}
