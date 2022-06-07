//
//  Created by Anton Spivak
//

import Foundation
import HuetonMOON

public struct AccountSettings {}

/// PUT
public extension AccountSettings {
    
    struct PUT: Request {
        
        public typealias R = Answer
        
        private struct Model: Encodable {
            
            public let device: Device
            public let wallet: Wallet?
            
            public init(
                device: Device,
                wallet: Wallet?
            ) {
                self.device = device
                self.wallet = wallet
            }
        }
        
        public let endpoint: String = "api/device_wallet"
        public let kind: Kind = .PUT
        public let parameters: Encodable
        
        public init(
            device: Device,
            wallet: Wallet?
        ) {
            self.parameters = Model(
                device: device,
                wallet: wallet
            )
        }
    }
    
    // MARK: Convience methods
    
    /// - parameter address: raw TON address (workchain:hex)
    static func subscribeWalletTransactions(
        installation_id: String,
        address: String
    ) -> PUT {
        AccountSettings.PUT(
            device: .init(
                installation_id: installation_id,
                device_token: nil,
                device_type: "ios",
                notification_settings: nil
            ),
            wallet: .init(
                address: address,
                notification_settings: .init(
                    transactions: true
                )
            )
        )
    }
    
    /// - parameter address: raw TON address (workchain:hex)
    static func unsubscribeWalletTransactions(
        installation_id: String,
        address: String
    ) -> PUT {
        AccountSettings.PUT(
            device: .init(
                installation_id: installation_id,
                device_token: nil,
                device_type: "ios",
                notification_settings: nil
            ),
            wallet: .init(
                address: address,
                notification_settings: .init(
                    transactions: false
                )
            )
        )
    }
    
    static func updateDeviceToken(
        installation_id: String,
        token: String
    ) -> PUT {
        AccountSettings.PUT(
            device: .init(
                installation_id: installation_id,
                device_token: token,
                device_type: "ios",
                notification_settings: nil
            ),
            wallet: nil
        )
    }
}
