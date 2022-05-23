//
//  TransferDetailsViewController.InitialConfiguration.swift
//  iOS
//
//  Created by Anton Spivak on 16.05.2022.
//

import Foundation
import HuetonCORE
import SwiftyTON

extension TransferConfirmationViewController {
    
    struct InitialConfiguration {
        
        let fromAccount: PersistenceAccount
        let toAddress: Address
        let amount: Currency
        var message: Message
    }
}
