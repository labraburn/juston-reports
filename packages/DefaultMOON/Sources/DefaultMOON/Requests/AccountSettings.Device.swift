//
//  File.swift
//  
//
//  Created by Anton Spivak on 06.06.2022.
//

import Foundation

public extension AccountSettings {
    
    struct Device {
        
        public let installation_id: String
        
        public let device_token: String?
        public let device_type: String?
        public let notification_settings: NotificationSettings?
        
        public init(
            installation_id: String,
            device_token: String?,
            device_type: String?,
            notification_settings: NotificationSettings?
        ) {
            self.installation_id = installation_id
            self.device_token = device_token
            self.device_type = device_type
            self.notification_settings = notification_settings
        }
    }
}

extension AccountSettings.Device: Codable {}
