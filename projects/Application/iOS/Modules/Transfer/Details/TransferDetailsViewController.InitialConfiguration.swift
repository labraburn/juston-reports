//
//  TransferViewController.InitialConfiguration.swift
//  iOS
//
//  Created by Anton Spivak on 16.05.2022.
//

import Foundation
import SwiftyTON

extension TransferDetailsViewController {
    
    struct InitialConfiguration {
        
        let fromAddress: Address
        let toAddress: Address?
        
        let key: Key
        
        let amount: Balance?
        let message: String?
    }
}
