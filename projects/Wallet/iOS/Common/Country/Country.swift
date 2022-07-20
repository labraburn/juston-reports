//
//  Country.swift
//  iOS
//
//  Created by Anton Spivak on 20.07.2022.
//

import Foundation
import CoreTelephony
import StoreKit

struct Country {
    
    enum ISO: String {
        
        case ru
        
        init?(rawValue: String) {
            switch rawValue {
            case "RU", "RUS", "ru", "ru-RU", "rus":
                self = .ru
            default:
                return nil
            }
        }
    }
    
    static let shared = Country()
    
    private let _telephone: [ISO]
    private let _store: [ISO]
    
    private init() {
        _telephone = Country.countryWithTelephonyNetworkInfo()
        _store = Country.countryWithSKPaymentQueue()
    }
    
    func probably(
        in iso: ISO
    ) -> Bool {
        _telephone.contains(iso) || _store.contains(iso)
    }
    
    private static func countryWithTelephonyNetworkInfo() -> [ISO] {
        let networkInfo = CTTelephonyNetworkInfo()
        let providers = networkInfo.serviceSubscriberCellularProviders
        var countries: [ISO] = []
        
        providers?.forEach({ _, carrier in
            guard let isoCountryCode = carrier.isoCountryCode,
                  let iso = ISO(rawValue: isoCountryCode)
            else {
                return
            }
            
            countries.append(iso)
        })
        
        return countries
    }
    
    private static func countryWithSKPaymentQueue() -> [ISO] {
        guard let code = SKPaymentQueue.default().storefront?.countryCode,
              let iso = ISO(rawValue: code)
        else {
            return []
        }
        
        return [iso]
    }
}
