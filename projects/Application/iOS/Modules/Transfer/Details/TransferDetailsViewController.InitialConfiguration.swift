//
//  TransferViewController.InitialConfiguration.swift
//  iOS
//
//  Created by Anton Spivak on 16.05.2022.
//

import Foundation
import HuetonCORE
import SwiftyTON

extension TransferDetailsViewController {
    
    struct InitialConfiguration {
        
        let fromAccount: PersistenceAccount
        let toAddress: Address?
        
        let key: Key
        
        let amount: Currency?
        let message: String?
    }
}
