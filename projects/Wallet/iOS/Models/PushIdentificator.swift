//
//  PushIdentificator.swift
//  iOS
//
//  Created by Anton Spivak on 20.04.2022.
//

import Foundation
import JustonCORE

@MainActor
final class PushIdentificator {
    
    static let shared = PushIdentificator()
    private let storage = CodableStorage.target
    
    var value: String? {
        get async {
            return try? await storage.value(of: String.self, forKey: .pushIdentificatorAPNSToken)
        }
    }
    
    func update(_ value: Data) {
        update(value.toHexString())
    }
    
    func update(_ value: String) {
        Task {
            try? await storage.save(value: value, forKey: .pushIdentificatorAPNSToken)
        }
    }
}

private extension CodableStorage.Key {
    
    static let pushIdentificatorAPNSToken = CodableStorage.Key(rawValue: "PushIdentificatorAPNSToken")
}
