//
//  WKWeb3Event.swift
//  iOS
//
//  Created by Anton Spivak on 27.06.2022.
//

import UIKit
import HuetonCORE

protocol WKWeb3Event {
    
    associatedtype B = Decodable
    associatedtype R = Encodable
    
    static var names: [String] { get }
    
    init()
    
    func process(
        account: PersistenceAccount?,
        context: UIViewController,
        _ body: B
    ) async throws -> R
}
