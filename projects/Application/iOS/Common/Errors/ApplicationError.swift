//
//  ApplicationError.swift
//  iOS
//
//  Created by Anton Spivak on 10.04.2022.
//

import Foundation

enum ApplicationError {
    
    case noApplicationPassword
    case userCancelled
}

extension ApplicationError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .noApplicationPassword:
            return "ApplicationErrorPasscodeNotSet".asLocalizedKey
        case .userCancelled:
            return ""
        }
    }
}
