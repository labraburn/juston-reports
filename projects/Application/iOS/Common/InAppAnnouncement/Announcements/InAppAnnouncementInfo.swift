//
//  InAppAnnouncementInfo.swift
//  iOS
//
//  Created by Anton Spivak on 29.04.2022.
//

import Foundation
import UIKit

struct InAppAnnouncementInfo: InAppAnnouncement {
    
    typealias AnnouncementContent = Content
    
    struct Content {
        
        enum Icon {
            
            case info
            case success
            case copying
        }
        
        let text: String
        let icon: Icon
        let tintColor: UIColor
    }
}

extension InAppAnnouncementInfo.Content.Icon {
    
    var image: UIImage? {
        switch self {
        case .info: return .hui_info24
        case .success: return .hui_done24
        case .copying: return .hui_copy24
        }
    }
}

extension InAppAnnouncementInfo.Content {
    
    static let addressCopied = InAppAnnouncementInfo.Content(
        text: "AnnouncementAddressCopied".asLocalizedKey,
        icon: .copying,
        tintColor: .hui_letter_blue
    )
    
    static let wordsCopied = InAppAnnouncementInfo.Content(
        text: "AnnouncementWordsCopied".asLocalizedKey,
        icon: .copying,
        tintColor: .hui_letter_blue
    )
    
    static let transactionLinkCopied = InAppAnnouncementInfo.Content(
        text: "AnnouncementTransactionLinkCopied".asLocalizedKey,
        icon: .copying,
        tintColor: .hui_letter_blue
    )
}
