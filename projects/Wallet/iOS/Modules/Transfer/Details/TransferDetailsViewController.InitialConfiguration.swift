//
//  TransferViewController.InitialConfiguration.swift
//  iOS
//
//  Created by Anton Spivak on 16.05.2022.
//

import Foundation
import JustonCORE
import SwiftyTON

extension TransferDetailsViewController {
    
    struct InitialConfiguration {
        
        let fromAccount: PersistenceAccount
        let isEditable: Bool
        let configuration: TransferConfiguration?
    }
}
