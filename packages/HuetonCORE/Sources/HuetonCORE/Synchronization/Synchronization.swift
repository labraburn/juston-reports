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
        address: Address,
        transactionReceiveOptions: TransactionReceiveOptions
    ) async throws {
        let context = SynchronizationActor.shared.managedObjectContext
            
        let contract = try await Contract(rawAddress: address.rawValue)
        try Task.checkCancellation()
        
        guard let persistenceAccount = try account(forSelectedAddress: address, in: context)
        else {
            return
        }
        
        persistenceAccount.balance = NSDecimalNumber(decimal: contract.info.balance.value)
        try context.save()
        
        var transactions: [Transaction] = []

        switch transactionReceiveOptions {
        case .none:
            return
        case .afterLastSaved:
            let lastPersistance = try lastPersistanceTransaction(for: persistenceAccount, in: context)
            transactions = try await contract.transactions(after: lastPersistance?.id)
        case .full:
            transactions = try await contract.transactions(after: nil)
        }

        try Task.checkCancellation()

        transactions.forEach({ transaction in
            let persistenceTransaction = PersistenceTransaction(context: context)
            persistenceTransaction.id = transaction.id
            persistenceTransaction.account = persistenceAccount
            persistenceTransaction.date = transaction.date
            persistenceTransaction.flags = []
            persistenceTransaction.fees = NSDecimalNumber(
                decimal: transaction.storageFee.value + transaction.otherFee.value
            )

            if let message = transaction.in,
               let sourceAccountAddress = message.sourceAccountAddress
            {
                // received
                persistenceTransaction.value = NSDecimalNumber(decimal: message.value.value)
                persistenceTransaction.fromAddress = sourceAccountAddress
                persistenceTransaction.toAddresses = [persistenceAccount.selectedAddress.rawValue]
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
                persistenceTransaction.fromAddress = persistenceAccount.selectedAddress.rawValue
                persistenceTransaction.toAddresses = toAddresses
            }
            else {
                // Looks like transaction to self (deply or maybe)
                
                persistenceTransaction.value = 0
                persistenceTransaction.fromAddress = persistenceAccount.selectedAddress.rawValue
                persistenceTransaction.toAddresses = [persistenceAccount.selectedAddress.rawValue]
            }
        })

        persistenceAccount.dateLastSynchronization = Date()
        try context.save()
    }
    
    // MARK: Helpers
    
    private func account(
        forSelectedAddress address: Address,
        in context: NSManagedObjectContext
    ) throws -> PersistenceAccount? {
        let persistenceAccountsRequest = PersistenceAccount.fetchRequest(selectedAddress: address)
        let persistenceAccounts = try context.fetch(persistenceAccountsRequest)
        
        return persistenceAccounts.first
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
