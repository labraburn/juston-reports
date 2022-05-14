//
//  CardStackCard.swift
//  iOS
//
//  Created by Anton Spivak on 28.04.2022.
//

import Foundation
import HuetonCORE

@MainActor
struct CardStackCard {
    
    let account: PersistenceAccount
}

extension CardStackCard: Hashable {
    
    static func == (lhs: CardStackCard, rhs: CardStackCard) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(account.selectedAddress.rawValue)
    }
}
