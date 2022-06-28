//
//  .swift
//  iOS
//
//  Created by Anton Spivak on 28.06.2022.
//

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
        _ body: Body
    ) async throws -> Bool {
        guard let account = account
        else {
            throw WKWeb3Error(.unauthorized)
        }
        
        #warning("TODO")
        throw WKWeb3Error(.unsupportedMethod)
    }
}
