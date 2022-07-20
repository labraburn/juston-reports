//
//  TransferDetailsViewController.InitialConfiguration.swift
//  iOS
//
//  Created by Anton Spivak on 16.05.2022.
//

import Foundation
import JustonCORE
import SwiftyTON

extension TransferConfirmationViewController {
    
    struct InitialConfiguration {
        
        let fromAccount: PersistenceAccount
        let toAddress: DisplayableAddress
        let amount: Currency
        var message: Message
        var estimatedFees: Currency
    }
}
