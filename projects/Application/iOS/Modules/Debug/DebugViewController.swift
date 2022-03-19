//
//  DebugViewController.swift
//  iOS
//
//  Created by Anton Spivak on 15.02.2022.
//

import UIKit
import SwiftyTON

class DebugViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        

    }
}

extension String {
    
    func toHexEncodedString(uppercase: Bool = true, prefix: String = "", separator: String = "") -> String {
        return unicodeScalars.map { prefix + .init($0.value, radix: 16, uppercase: uppercase) } .joined(separator: separator)
    }
}
