//
//  UIApplication.swift
//  iOS
//
//  Created by Anton Spivak on 20.04.2022.
//

import UIKit
import UserNotifications

extension UIApplication {
    
    func requestNotificationsPermissionIfNeeded() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings(completionHandler: { settings in
            let request = {
                center.requestAuthorization(options: [.alert, .announcement, .badge], completionHandler: { _, _ in
                    self.requestRegisterForRemoteNotificationsIfNeeded()
                })
            }
            if settings.authorizationStatus == .notDetermined {
                DispatchQueue.main.async(execute: request)
            }
        })
    }
    
    func requestRegisterForRemoteNotificationsIfNeeded() {
        DispatchQueue.main.async(execute: {
            UIApplication.shared.registerForRemoteNotifications()
        })
    }
}
