//
//  PushIdentificator.swift
//  iOS
//
//  Created by Anton Spivak on 20.04.2022.
//

import Foundation
import HuetonCORE
import DefaultMOON

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
            let installationID = await InstallationIdentifier.shared.value
            let request = AccountSettings.updateDeviceToken(installation_id: installationID.uuidString, token: value)
            
            do {
                let _ = try await DefaultMOON.shared.do(request)
            } catch {
                print(error)
            }
            
            try? await storage.save(value: value, forKey: .pushIdentificatorAPNSToken)
        }
    }
}

private extension CodableStorage.Key {
    
    static let pushIdentificatorAPNSToken = CodableStorage.Key(rawValue: "PushIdentificatorAPNSToken")
}
