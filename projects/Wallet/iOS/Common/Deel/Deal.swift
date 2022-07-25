//
//  Deal.swift
//  iOS
//
//  Created by Anton Spivak on 24.07.2022.
//

import Foundation
import SwiftyTON
import TON3
import JustonCORE
import SwiftyJS

extension PersistenceAccount {
    
    func deel(
        uuid: UUID,
        address: Address,
        amount: Currency,
        royalty: (address: Address, fees: Currency),
        passcode: Data
    ) async throws -> Message {
        let dealContractInitialCode = PersistenceAccount.dealContractCode.data
        let dealContractInitialData = try await _dealContractInitialData(
            uuid: uuid,
            address: address,
            amount: amount,
            royalty: royalty
        )
        
        let initial = (dealContractInitialCode, dealContractInitialData)
        guard let dealContractAddress = await Address(initial: initial)
        else {
            throw ContractError.unknownContractType
        }
        
        return try await transfer(
            to: ConcreteAddress(
                address: dealContractAddress,
                representation: .base64(flags: [])
            ),
            amount: amount + 50_000_000,
            message: (
                body: try await _dealContractMessageBody(),
                initial: try await _dealContractInitial(
                    code: dealContractInitialCode,
                    data: dealContractInitialData
                )
            ),
            passcode: passcode
        )
    }
}

@JSActor
private extension PersistenceAccount {
    
    static let dealContractCode: BOC = "B5EE9C724101030100B9000114FF00F4A413F4BCF2C80B0101A4D3306C12D0D3030171B0915BE0FA40D31F30ED44D0FA40FA00D300D4D43020D0FA40FA003007F823BBF263248209C9C380A019BBF265028E1710565F06708010C8CB0558CF1621FA02CB6AC98306FB00E30E0200AA4640546377708010C8CB055006CF1624FA0215CB6AC971FB00708010C8CB055003CF1603A112FA02CB6AC971FB00708010C8CB0558CF1621FA02CB6AC98306FB0043137102C85005CF165003FA02CB00CCCCC9ED542BADD72F"
    
    private func _dealContractInitialData(
        uuid: UUID,
        address: Address,
        amount: Currency,
        royalty: (address: Address, fees: Currency)
    ) async throws -> Data {
        let builder = try TON3.Builder()
        
        builder.store(address: address.hash, workchain: address.workchain) // deel_author_address
        builder.store(coins: amount.value) // deel_amount
        builder.store(false) // is_completed
        
        let info = { @JSActor () throws -> TON3.Cell in
            let builder = try TON3.Builder()
            builder.store(uuid.uuidString)
            return try builder.cell()
        }
        
        let royalty = { @JSActor () throws -> TON3.Cell in
            let builder = try TON3.Builder()
            builder.store(address: royalty.address.hash, workchain: royalty.address.workchain)
            builder.store(coins: royalty.fees.value)
            return try builder.cell()
        }
        
        builder.store(try info())
        builder.store(try royalty())
        
        let boc = try builder.boc()
        return Data(hex: boc)
    }
    
    private func _dealContractMessageBody() async throws -> Data {
        let builder = try TON3.Builder()
        
        builder.store(UInt32(Date().timeIntervalSince1970 + 60)) // valid_until
        
        let boc = try builder.boc()
        return Data(hex: boc)
    }
    
    private func _dealContractInitial(
        code: Data,
        data: Data
    ) async throws -> Data {
        let value = try await TON3.initial(code: code.bytes, data: data.bytes)
        return Data(hex: value)
    }
}
