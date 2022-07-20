//
//  WKWeb3Emit.swift
//  iOS
//
//  Created by Anton Spivak on 28.06.2022.
//

import UIKit
import JustonCORE

protocol WKWeb3Emit: Encodable {
    
    static var names: [String] { get }
}
