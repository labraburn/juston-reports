//
//  UIApplication.swift
//  iOS
//
//  Created by Anton Spivak on 20.04.2022.
//

import UIKit
import UserNotifications
import GithubMOON
import JustonCORE

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
    
    func requestRemoteConfigurations() {
        Task {
            let request = Configurations.GET()
            guard let response = try? await GithubMOON().do(request)
            else {
                return
            }
            
            try? await PersistenceBrowserBanner.removeAllBeforeInserting({
                let unwrapped = response.banners.compactMap({ $0.value })
                var priority = Int64(unwrapped.count)
                
                let result = unwrapped.map({ banner -> PersistenceBrowserBanner in
                    let value = PersistenceBrowserBanner(
                        title: banner.title,
                        subtitle: banner.subtitle,
                        imageURL: banner.imageURL,
                        action: {
                            switch banner.action {
                            case let .url(value):
                                return .url(
                                    value: value
                                )
                            case let .inapp(value):
                                return .inapp(
                                    value: {
                                        switch value {
                                        case .web3promo:
                                            return .web3promo
                                        }
                                    }()
                                )
                            }
                        }(),
                        priority: priority
                    )
                    
                    priority -= 1
                    return value
                })
                
                return result
            })
        }
    }
}
