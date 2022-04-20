//
//  PushIdentificator.swift
//  iOS
//
//  Created by Anton Spivak on 20.04.2022.
//

import Foundation
import HuetonCORE

@MainActor
final class PushIdentificator {
    
    static let shared = PushIdentificator()
    
    private let storage = CodableStorage.target
    private(set) var APNSToken: String?
    
    private init() {
        restore()
    }
    
    func update(withData data: Data) {
        let parts = data.map { data in String(format: "%02.2hhx", data) }
        let token = parts.joined()
        
        APNSToken = token
        save()
    }
    
    private func restore() {
        Task {
            APNSToken = try? await storage.value(of: String.self, forKey: .pushIdentificatorAPNSToken)
        }
    }
    
    private func save() {
        Task {
            try? await storage.save(value: APNSToken, forKey: .pushIdentificatorAPNSToken)
        }
    }
}

private extension CodableStorage.Key {
    
    static let pushIdentificatorAPNSToken = CodableStorage.Key(rawValue: "PushIdentificatorAPNSToken")
}
