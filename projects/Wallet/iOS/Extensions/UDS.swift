//
//  UDS.swift
//  iOS
//
//  Created by Anton Spivak on 01.06.2022.
//

import UIKit
import HuetonCORE

extension UDS {
    
    static var isWelcomeScreenViewed: Bool {
        get { shared.value(forKey: .isWelcomeScreenViewed, fallback: false) }
        set { shared.set(newValue, forKey: .isWelcomeScreenViewed) }
    }
    
    static var isAgreementsAccepted: Bool {
        get { shared.value(forKey: .isAgreementsAccepted, fallback: false) }
        set { shared.set(newValue, forKey: .isAgreementsAccepted) }
    }
}

extension UDS.Key {
    
    static let isWelcomeScreenViewed: UDS.Key = .init(rawValue: "isWelcomeScreenViewed")
    static let isAgreementsAccepted: UDS.Key = .init(rawValue: "isAgreementsAccepted")
}
