//
//  TransferConfiguration.swift
//  iOS
//
//  Created by Anton Spivak on 27.07.2022.
//

import Foundation
import SwiftyTON

struct TransferConfiguration {
    
    let destination: DisplayableAddress
    let amount: Currency?
    let message: String?
    let payload: Data?
    let initial: Data?
    
    init(
        destination: DisplayableAddress,
        amount: Currency? = nil,
        message: String? = nil,
        payload: Data? = nil,
        initial: Data? = nil
    ) {
        self.destination = destination
        self.amount = amount
        self.message = message
        self.payload = payload
        self.initial = initial
    }
}
