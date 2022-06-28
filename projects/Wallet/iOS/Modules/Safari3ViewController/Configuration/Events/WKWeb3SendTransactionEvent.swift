//
//  .swift
//  iOS
//
//  Created by Anton Spivak on 28.06.2022.
//

// https://github.com/toncenter/ton-wallet/blob/3ef80a23ce120f3eeabaca06955cb8f767525104/src/js/Controller.js#L1130

import UIKit
import HuetonCORE

struct WKWeb3SendTransactionEvent: WKWeb3Event {
    
    struct Body: Decodable {
        
        enum DataType: String, Decodable {
            
            case text
            case hex
            case base64
            case boc
        }
        
        let to: String
        let value: String
        let dataType: DataType
        let data: String
    }
    
    static let names = ["ton_sendTransaction"]
    
    func process(
        account: PersistenceAccount?,
        context: UIViewController,
        url: URL,
        _ body: Body
    ) async throws -> Bool {
        guard let account = account
        else {
            throw WKWeb3Error(.unauthorized)
        }
        
        guard let _amount = Int64(body.value),
              let address = Address(string: body.to)
        else {
            throw WKWeb3Error(.internal)
        }
        
        let amount = Currency(_amount)
        let confirmation = Safari3Confirmation(
            .transaction(
                host: url.host ?? url.absoluteString,
                destination: body.to,
                value: amount
            ),
            presentationContext: context
        )
        
        let authentication = PasscodeAuthentication(
            inside: context
        )
        
        try await confirmation.confirm()
        let passcode = try await authentication.key()
        
        var data: Data? = nil
        switch body.dataType {
        case .text:
            data = body.data.data(using: .utf8, allowLossyConversion: true)
        case .hex:
            data = Data(hex: body.data)
        case .base64, .boc:
            data = Data(base64Encoded: body.data)
        }
        
        let message = try await account.transfer(
            to: address,
            amount: amount,
            payload: data,
            passcode: passcode
        )
        
        try await message.send()
        return true
    }
}
