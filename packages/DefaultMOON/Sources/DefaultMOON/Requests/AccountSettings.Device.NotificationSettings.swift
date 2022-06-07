//
//  File.swift
//  
//
//  Created by Anton Spivak on 06.06.2022.
//

import Foundation

public extension AccountSettings.Device {
    
    struct NotificationSettings {
        
        public let currency_change: Bool
        
        public init(
            currency_change: Bool
        ) {
            self.currency_change = currency_change
        }
    }
}


extension AccountSettings.Device.NotificationSettings: Codable {}
