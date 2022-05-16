//
//  TransferDetailsViewController.InitialConfiguration.swift
//  iOS
//
//  Created by Anton Spivak on 16.05.2022.
//

import Foundation
import SwiftyTON

extension TransferConfirmationViewController {
    
    struct InitialConfiguration {
        
        let fromAddress: Address
        let toAddress: Address
        let amount: Balance
        var message: Message
    }
}
