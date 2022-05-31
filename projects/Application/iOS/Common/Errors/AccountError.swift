//
//  AccountError.swift
//  iOS
//
//  Created by Anton Spivak on 01.06.2022.
//

import Foundation

enum AccountError {
    
    case accountExists(name: String)
}

extension AccountError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case let .accountExists(name):
            return String(format: "AccountErrorAccountExists".asLocalizedKey, name)
        }
    }
}
