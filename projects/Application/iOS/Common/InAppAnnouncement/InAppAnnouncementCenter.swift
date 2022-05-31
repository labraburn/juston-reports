//
//  InAppAnnouncementCenter.swift
//  iOS
//
//  Created by Anton Spivak on 28.04.2022.
//

import UIKit

class InAppAnnouncementCenter {

    private let center = NotificationCenter()
    
    fileprivate init() {}
    
    public func post<T>(
        announcement: T.Type,
        with content: T.AnnouncementContent
    ) where T: InAppAnnouncement {
        center.post(
            name: .init(rawValue: String(describing: announcement)),
            object: nil,
            userInfo: [
                "value" : content
            ]
        )
    }
    
    @discardableResult
    public func observe<T>(
        of announcement: T.Type,
        on queue: OperationQueue? = .main,
        using block: @escaping (T.AnnouncementContent) -> Void
    ) -> NSObjectProtocol where T: InAppAnnouncement {
        center.addObserver(
            forName: .init(rawValue: String(describing: announcement)),
            object: nil,
            queue: queue,
            using: { notification in
                guard let content = notification.userInfo?["value"] as? T.AnnouncementContent
                else {
                    return
                }
                
                block(content)
            }
        )
    }
    
    public func removeObserver(_ observer: NSObjectProtocol) {
        center.removeObserver(observer)
    }
}

extension InAppAnnouncementCenter {
    
    static let shared = InAppAnnouncementCenter()
}
