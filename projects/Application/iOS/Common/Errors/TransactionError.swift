//
//  TransactionError.swift
//  iOS
//
//  Created by Anton Spivak on 07.06.2022.
//

import Foundation

enum TransactionError {
    
    case isPending
}

extension TransactionError: LocalizedError {
    
    var transactionPending: String? {
        switch self {
        case .isPending:
            return "TransactionErrorIsPending".asLocalizedKey
        }
    }
}
