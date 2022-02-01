//
//  TON.swift
//  iOS
//
//  Created by Anton Spivak on 02.02.2022.
//

import Foundation
import SwiftyTON

extension TON {
    
    private static let configurationURL = URL(string: "https://newton-blockchain.github.io/global.config.json")!
    static let shared = TON(configuration: .url(network: .main, value: TON.configurationURL))
}
