//
//  TransactionDetailsViewable.swift
//  iOS
//
//  Created by Anton Spivak on 07.06.2022.
//

import Foundation
import HuetonCORE

protocol TransactionDetailsViewable {
    
    var transactionID: Transaction.ID? { get }
    var value: Currency { get }
    var fees: Currency { get }
    var kind: TransactionViewableKind { get }
    var date: Date { get }
    var to: [Address] { get }
    var from: Address? { get }
    var message: String? { get }
}

enum TransactionViewableKind {
    
    case `in`
    case out
    case pending
}

// MARK: Helpers

extension PersistenceProcessedTransaction: TransactionDetailsViewable {
    
    var transactionID: Transaction.ID? { id }
    
    var value: Currency {
        if !out.isEmpty {
            return out.reduce(into: Currency(value: 0), { $0 += $1.value })
        } else if let action = self.in {
            return action.value
        } else {
            return Currency(value: 0)
        }
    }
    
    var kind: TransactionViewableKind {
        if !out.isEmpty {
            return .out
        } else if let _ = self.in {
            return .in
        } else {
            return .out
        }
    }
    
    var to: [Address] {
        if !out.isEmpty {
            return out.compactMap({ $0.destinationAddress })
        } else if let action = self.in {
            return [action].compactMap({ $0.destinationAddress })
        } else {
            return [account.convienceSelectedAddress]
        }
    }
    
    var from: Address? {
        if !out.isEmpty {
            return account.convienceSelectedAddress
        } else if let action = self.in {
            return action.sourceAddress
        } else {
            return account.convienceSelectedAddress
        }
    }
    
    var message: String? {
        let body: Data?
        if !out.isEmpty {
            body = out.first?.body
        } else if let action = self.in {
            body = action.body
        } else {
            body = nil
        }
        
        guard let body = body,
              let string = String(data: body, encoding: .utf8)
        else {
            return nil
        }
        
        return string
    }
}

extension PersistencePendingTransaction: TransactionDetailsViewable {
    
    var transactionID: Transaction.ID? { nil }
    var kind: TransactionViewableKind { .pending }
    var fees: Currency { estimatedFees }
    var date: Date { dateCreated }
    var to: [Address] { [destinationAddress] }
    var from: Address? { nil }
    var message: String? { nil }
}
