//
//  InstallationIdentifier.swift
//  iOS
//
//  Created by Anton Spivak on 06.06.2022.
//

import Foundation

import Foundation
import JustonCORE

@MainActor
final class InstallationIdentifier {
    
    static let shared = InstallationIdentifier()
    private let storage = CodableStorage.group
    
    var value: UUID {
        get async {
            guard let value = try? await storage.value(of: UUID.self, forKey: .installationIdentifier)
            else {
                let new = UUID()
                try? await storage.save(value: new, forKey: .installationIdentifier)
                return new
            }
            return value
        }
    }
}

private extension CodableStorage.Key {
    
    static let installationIdentifier = CodableStorage.Key(rawValue: "installationIdentifier")
}
