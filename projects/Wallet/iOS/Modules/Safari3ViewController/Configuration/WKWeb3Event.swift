//
//  WKWeb3Event.swift
//  iOS
//
//  Created by Anton Spivak on 27.06.2022.
//

import Foundation

protocol WKWeb3Event {
    
    associatedtype B = Decodable
    associatedtype R = Encodable
    
    static var name: String { get }
    
    init()
    
    func process(
        _ body: B
    ) async throws -> R
}
