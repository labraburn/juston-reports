//
//  WKWeb3SignEvent.swift
//  iOS
//
//  Created by Anton Spivak on 27.06.2022.
//

import UIKit
import HuetonCORE

struct WKWeb3SignEvent: WKWeb3Event {
    
    struct Body: Decodable {
        
        let data: String
    }
    
    static let names = ["ton_rawSign"]
    
    func process(
        account: PersistenceAccount?,
        context: UIViewController,
        url: URL,
        _ body: Body
    ) async throws -> String {
        guard let account = account,
              let key = account.keyIfAvailable
        else {
            throw WKWeb3Error(.unauthorized)
        }
        
        let confirmation = UserConfirmation(
            .sign(host: url.host ?? url.absoluteString),
            presentationContext: context
        )
        
        try await confirmation.confirm()
        let boc = BOC(rawValue: body.data)
        
        let authentication = PasscodeAuthentication(inside: context)
        let passcode = try await authentication.key()
        
        let signature = try await boc.signature(
            with: key,
            localUserPassword: passcode
        )
        
        return signature.toHexString()
    }
}
