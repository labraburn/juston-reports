//
//  Created by Anton Spivak
//

import Foundation
import CoreData
import SwiftyTON

@objc(PersistenceAccount)
public class PersistenceAccount: PersistenceObject {
    
    @PersistenceWritableActor
    public init(
        keyPublic: String?,
        keySecretEncrypted: String?,
        selectedContract: AccountContract,
        name: String,
        appearance: AccountAppearance,
        flags: Flags = []
    ) {
        let context = PersistenceWritableActor.shared.managedObjectContext
        super.init(context: context)
        
        self.keyPublic = keyPublic
        self.keySecretEncrypted = keySecretEncrypted
        
        self.selectedContract = selectedContract
        self.contractKind = nil
        self.name = name
        self.appearance = appearance
        self.flags = flags
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.dateCreated = Date()
    }
    
    @PersistenceWritableActor
    public func saveAsLastSorting() throws {
        let context = PersistenceWritableActor.shared.managedObjectContext
        guard context == managedObjectContext
        else {
            fatalError("Can't save \(self) from another context.")
        }
        
        let request = Self.fetchRequest()
        let count = (try managedObjectContext?.count(for: request)) ?? 0
        
        self.sortingUserValue = Int64(count) + 1
        
        try context.save()
    }
    
    @PersistenceWritableActor
    public func saveAsLastUsage() throws {
        let context = PersistenceWritableActor.shared.managedObjectContext
        guard context == managedObjectContext
        else {
            fatalError("Can't save \(self) from another context.")
        }
        
        let request = Self.fetchRequestSortingUser()
        let accounts = try context.fetch(request)

        guard accounts.count > 0,
              let indexOfSelf = accounts.firstIndex(of: self)
        else {
            return
        }

        var value = Int64(0)
        for i in indexOfSelf ..< accounts.count {
            accounts[i].sortingLastUsageValue = value
            value += 1
        }

        for i in 0 ..< indexOfSelf {
            accounts[i].sortingLastUsageValue = value
            value += 1
        }
        
        guard context.hasChanges
        else {
            return
        }

        try context.save()
    }
}

// MARK: - CoreData Properties

public extension PersistenceAccount {
    
    struct Flags: OptionSet {
        
        public let rawValue: Int64
        
        public static let isNotificationsEnabled = Flags(rawValue: 1 << 0)
        
        public init(rawValue: Int64) {
            self.rawValue = rawValue
        }
    }
    
    var appearance: AccountAppearance {
        set { raw_appearance = newValue }
        get {
            guard let appearance = raw_appearance as? AccountAppearance
            else {
                fatalError("Looks like data is fault.")
            }
            return appearance
        }
    }
    
    var selectedContract: AccountContract {
        set {
            raw_selected_address = newValue.address.rawValue
            raw_selected_contract_kind = newValue.kind?.rawValue.rawValue
        }
        get {
            guard let address = Address.RawAddress(rawValue: raw_selected_address)
            else {
                fatalError("Looks like data is fault.")
            }
            
            var kind: Contract.Kind? = nil
            if let raw_selected_contract_kind = raw_selected_contract_kind {
                let boc = BOC(rawValue: raw_selected_contract_kind)
                kind = Contract.Kind(rawValue: boc)
            }
            
            return AccountContract(
                address: address,
                kind: kind
            )
        }
    }
    
    internal(set) var contractKind: Contract.Kind? {
        set {
            raw_contract_kind = newValue?.rawValue.rawValue
        }
        get {
            var kind: Contract.Kind? = nil
            if let raw_contract_kind = raw_contract_kind {
                let boc = BOC(rawValue: raw_contract_kind)
                kind = Contract.Kind(rawValue: boc)
            }
            return kind
        }
    }
    
    var balance: Currency {
        get { Currency(value: raw_balance) }
        set { raw_balance = newValue.value }
    }
    
    var flags: Flags {
        set { raw_flags = newValue.rawValue }
        get { Flags(rawValue: raw_flags) }
    }
    
    var keyIfAvailable: Key? {
        guard let publicKey = keyPublic,
              let encryptedSecretKey = keySecretEncrypted,
              let key = try? Key(publicKey: publicKey, encryptedSecretKey: Data(hex: encryptedSecretKey))
        else {
            return nil
        }
        
        return key
    }
    
    var isPublicKey: Bool { keyPublic != nil }
    var isReadonly: Bool { keySecretEncrypted == nil }
    
    /// 32-byte public key (HEX)
    @NSManaged
    var keyPublic: String?
    
    @NSManaged
    var keySecretEncrypted: String?
    
    @NSManaged
    var name: String
    
    @NSManaged
    var dateCreated: Date
    
    @NSManaged
    var dateLastSynchronization: Date?
    
    @NSManaged
    var sortingUserValue: Int64
    
    @NSManaged
    var sortingLastUsageValue: Int64
    
    @NSManaged
    var isSynchronizing: Bool
    
    // MARK: Internal
    
    /// nanotons
    @NSManaged
    private var raw_balance: Int64
    
    /// OptionSet
    @NSManaged
    private var raw_flags: Int64
    
    /// raw address (`workchain:hex`)
    @NSManaged
    private var raw_selected_address: String
    
    /// BOC hex string, used for usee choice
    @NSManaged
    private var raw_selected_contract_kind: String?
    
    /// BOC hex string, used for network info
    @NSManaged
    private var raw_contract_kind: String?
    
    /// AccountAppearanceTransformer
    @NSManaged
    private var raw_appearance: Any
}

// MARK: - CoreData Methods

public extension PersistenceAccount {
    
    @nonobjc
    class func fetchRequest() -> NSFetchRequest<PersistenceAccount> {
        return NSFetchRequest<PersistenceAccount>(entityName: "Account")
    }
    
    @nonobjc
    class func fetchRequestSortingLastUsage() -> NSFetchRequest<PersistenceAccount> {
        let fetchRequest = NSFetchRequest<PersistenceAccount>(entityName: "Account")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "sortingLastUsageValue", ascending: true)
        ]
        return fetchRequest
    }
    
    @nonobjc
    class func fetchRequestSortingUser() -> NSFetchRequest<PersistenceAccount> {
        let fetchRequest = NSFetchRequest<PersistenceAccount>(entityName: "Account")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "sortingUserValue", ascending: true)
        ]
        return fetchRequest
    }
    
    @nonobjc
    class func fetchRequest(
        selectedAddress: Address
    ) -> NSFetchRequest<PersistenceAccount> {
        let request = NSFetchRequest<PersistenceAccount>(entityName: "Account")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "raw_selected_address == %@", selectedAddress.rawValue.rawValue),
        ])
        return request
    }
    
    @nonobjc
    class func fetchRequest(
        keyPublic: String
    ) -> NSFetchRequest<PersistenceAccount> {
        let request = NSFetchRequest<PersistenceAccount>(entityName: "Account")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "keyPublic == %@", keyPublic),
        ])
        return request
    }
    
    @PersistenceReadableActor
    @nonobjc
    class func fetchedResultsController(
        request: NSFetchRequest<PersistenceAccount>
    ) -> NSFetchedResultsController<PersistenceAccount> {
        let context = PersistenceReadableActor.shared.managedObjectContext
        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
}

// MARK: - Convience Methods

extension PersistenceAccount {
    
    /// returns bouncable if contract inititalized, else - nonbouncable
    public var convienceSelectedAddress: Address {
        var address = Address(rawValue: selectedContract.address)
        switch contractKind {
        case .uninitialized:
            address.flags = []
        default:
            address.flags = [.bounceable]
        }
        return address
    }
}

// MARK: - SwiftyTON Methods

extension PersistenceAccount {
    
    public func transfer(
        to destination: Address,
        amount: Currency,
        message: String?,
        passcode: Data
    ) async throws -> Message {
        try await transfer(
            to: destination,
            amount: amount,
            payload: message?.data(using: .utf8),
            passcode: passcode
        )
    }
    
    public func transfer(
        to destination: Address,
        amount: Currency,
        payload: Data?,
        passcode: Data
    ) async throws -> Message {
        guard let key = keyIfAvailable
        else {
            throw ContractError.unknownContractType
        }
        
        let fromAddress = selectedContract.address
        let selectedContractKind = selectedContract.kind
        
        var contract = try await Contract(rawAddress: fromAddress)
        let selectedContractInfo = contract.info
        
        switch contract.kind {
        case .none:
            throw ContractError.unknownContractType
        case .uninitialized:
            switch selectedContractKind {
            case .none, .uninitialized, .walletV1R1, .walletV1R2, .walletV1R3:
                throw ContractError.unknownContractType
            default:
                contract = Contract(
                    rawAddress: fromAddress,
                    info: selectedContractInfo,
                    kind: selectedContractKind,
                    data: .zero
                )
            }
        default:
            break
        }
        
        guard let wallet = AnyWallet(contract: contract)
        else {
            throw ContractError.unknownContractType
        }
        
        return try await wallet.transfer(
            to: destination,
            amount: amount,
            payload: payload,
            key: key,
            passcode: passcode
        )
    }
}
