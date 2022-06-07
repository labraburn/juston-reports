//
//  File.swift
//  
//
//  Created by Anton Spivak on 06.06.2022.
//

import Foundation

public extension AccountSettings.Wallet {
    
    struct NotificationSettings {
        
        public let transactions: Bool
        
        public init(
            transactions: Bool
        ) {
            self.transactions = transactions
        }
    }
}

extension AccountSettings.Wallet.NotificationSettings: Codable {}
