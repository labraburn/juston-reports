//
//  Created by Anton Spivak
//

import Foundation
import SwiftyTON
import CoreData

@SynchronizationActor
public struct Synchronization {
    
    public enum TransactionReceiveOptions {
        
        case none
        case afterLastSaved
        case full
    }
    
    nonisolated public init() {}
    
    public func perform(
        rawAddress: Address.RawAddress,
        transactionReceiveOptions: TransactionReceiveOptions
    ) async throws {
        let context = SynchronizationActor.shared.managedObjectContext
            
        let wallet = try await Wallet(rawAddress: rawAddress)
        try Task.checkCancellation()
        
        let persistenceAccount = try account(for: rawAddress, in: context)
        persistenceAccount.balance = NSDecimalNumber(decimal: wallet.contract.info.balance.value)
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
            guard transaction.in != nil || !transaction.out.isEmpty
            else {
                return
            }

            let persistenceTransaction = PersistenceTransaction(context: context)
            persistenceTransaction.id = transaction.id
            persistenceTransaction.account = persistenceAccount
            persistenceTransaction.date = transaction.date
            persistenceTransaction.fees = NSDecimalNumber(
                decimal: transaction.storageFee.value + transaction.otherFee.value
            )

            if let message = transaction.in,
               let sourceAccountAddress = message.sourceAccountAddress
            {
                // received
                persistenceTransaction.value = NSDecimalNumber(decimal: message.value.value)
                persistenceTransaction.fromAddress = sourceAccountAddress
                persistenceTransaction.toAddresses = [persistenceAccount.rawAddress]
            }
            else if !transaction.out.isEmpty {
                // sended

                var value: Decimal = 0
                var toAddresses: [Address.RawAddress] = []

                transaction.out.forEach({ message in
                    guard let destinationAccountAddress = message.destinationAccountAddress
                    else {
                        return
                    }

                    value += message.value.value
                    toAddresses.append(destinationAccountAddress)
                })

                persistenceTransaction.value = NSDecimalNumber(decimal: value)
                persistenceTransaction.fromAddress = persistenceAccount.rawAddress
                persistenceTransaction.toAddresses = toAddresses
            }
            else {
                // can't being happend
                // i hope
            }
        })

        persistenceAccount.dateLastSynchronization = Date()
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    // MARK: Helpers
    
    private func account(
        for rawAddress: Address.RawAddress,
        in context: NSManagedObjectContext
    ) throws -> PersistenceAccount {
        let persistenceAccountsRequest = PersistenceAccount.fetchRequest(rawAddress: rawAddress)
        let persistenceAccounts = try context.fetch(persistenceAccountsRequest)
        
        guard persistenceAccounts.count == 1
        else {
            throw SynchronizationError.accountDoesNotExists(rawAddress: rawAddress)
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
