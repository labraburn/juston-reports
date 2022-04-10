//
//  AnyObject.swift
//  iOS
//
//  Created by Anton Spivak on 10.04.2022.
//

import Foundation

extension NSObjectProtocol {
    
    func removeFromNotificationCenter() {
        NotificationCenter.default.removeObserver(self)
    }
}
