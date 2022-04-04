//
//  Created by Anton Spivak
//

import Foundation
import SwiftyTON
import CoreData

public struct Synchronization {
    
    enum Error {
        
        case accountDoesNotExists(rawAddress: Address.RawAddress)
    }
    
    public enum TransactionReceiveOptions {
        
        case none
        case afterLastSaved
        case full
    }
    
    public init() {}
    
    /// All changes will be pushed into CoreData stack
    public func perform(
        rawAddress: Address.RawAddress,
        transactionReceiveOptions: TransactionReceiveOptions
    ) async throws {
        let context = PersistenceController.shared.container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        let wallet = try await Wallet(rawAddress: rawAddress)
        try Task.checkCancellation()
        
        let persistenceAccount = try account(for: rawAddress, in: context)
        persistenceAccount.balance = NSDecimalNumber(decimal: wallet.contract.info.balance.value)
        persistenceAccount.synchronizationDate = Date()
        try context.save()
        
        var transactions: [Transaction] = []
        
        switch transactionReceiveOptions {
        case .none:
            return
        case .afterLastSaved:
            let lastPersistance = try lastPersistanceTransaction(for: persistenceAccount, in: context)
            transactions = try await wallet.contract.transactions(after: lastPersistance?.id)
        case .full:
            transactions = try await wallet.contract.transactions(after: nil)
        }
        
        try Task.checkCancellation()
        
        transactions.forEach({ transaction in
            let persistenceTransaction = PersistenceTransaction(context: context)
            persistenceTransaction.id = transaction.id
            persistenceTransaction.account = persistenceAccount
            persistenceTransaction.date = transaction.date
        })
        
        try context.save()
    }
    
    // Helpers
    
    private func account(
        for rawAddress: Address.RawAddress,
        in context: NSManagedObjectContext
    ) throws -> PersistenceAccount {
        let persistenceAccountsRequest = PersistenceAccount.fetchRequest(rawAddress: rawAddress)
        let persistenceAccounts = try context.fetch(persistenceAccountsRequest)
        
        guard persistenceAccounts.count == 1
        else {
            throw Error.accountDoesNotExists(rawAddress: rawAddress)
        }
        
        return persistenceAccounts[0]
    }
    
    private func lastPersistanceTransaction(
        for account: PersistenceAccount,
        in context: NSManagedObjectContext
    ) throws -> PersistenceTransaction? {
        let persistenceTransactionsRequest = PersistenceTransaction.fetchRequest(account: account)
        persistenceTransactionsRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        let persistenceTransactions = try context.fetch(persistenceTransactionsRequest)
        return persistenceTransactions.last
    }
}

extension Synchronization.TransactionReceiveOptions: Hashable {}

extension Synchronization.Error: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case let .accountDoesNotExists(rawAddress):
            return "Can't locate PersistanceAccount for synchronization with address: \(rawAddress.rawValue)."
        }
    }
}
