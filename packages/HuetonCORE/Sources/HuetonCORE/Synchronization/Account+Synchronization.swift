//
//  Created by Anton Spivak
//

import Foundation
import SwiftyTON
import CoreData

extension Account {
    
    public func resynchronize() async throws {
        let wallet = try await Wallet(rawAddress: rawAddress)
        
        guard !Task.isCancelled
        else {
            return
        }
        
        self.balance = NSDecimalNumber(decimal: wallet.contract.info.balance.value)
        try save()
        
        guard !Task.isCancelled
        else {
            return
        }
        
        let transactions = try await wallet.contract.transactions()
        
        guard !Task.isCancelled
        else {
            return
        }
        
        let currentTransactionsRequest = Transaction.fetchRequest()
        currentTransactionsRequest.predicate = NSPredicate(format: "account = %@", self)
        let currentTransactions = try PersistenceObject.fetch(currentTransactionsRequest)
        
        try PersistenceObject.perform { viewContext in
            currentTransactions.forEach({ viewContext.delete($0) })
            try viewContext.save()
        }
        
        try PersistenceObject.perform { viewContext in
            transactions.forEach({
                let _ = Transaction(
                    shouldInsertIntoViewContext: true,
                    date: $0.date,
                    account: self
                )
            })
            
            try viewContext.save()
        }
    }
}
