//
//  File.swift
//  
//
//  Created by Anton Spivak on 27.06.2022.
//

import Foundation

public extension Configurations.Action {
    
    enum InApp: String {
        
        case web3promo
    }
}

extension Configurations.Action.InApp: Decodable {}
extension Configurations.Action.InApp: Hashable {}
