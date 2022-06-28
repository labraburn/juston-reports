//
//  BrowserBannerAction.InApp.swift
//  iOS
//
//  Created by Anton Spivak on 27.06.2022.
//

import Foundation
import HuetonCORE
import UIKit

extension BrowserBannerAction.InApp {
    
    func viewController(
        viewer account: PersistenceAccount
    ) -> UIViewController? {
        switch self {
        case .web3promo:
            let viewController = PromoViewController(
                title: "Web3PromoTitle".asLocalizedKey,
                description: "Web3PromoDescription".asLocalizedKey,
                image: .hui_placeholderV4512,
                completion: { @MainActor in
                    let accountID = account.objectID
                    let request = PersistenceBrowserFavourite.fetchRequest(
                        account: account
                    )
                    
                    let result = (try? PersistenceBrowserFavourite.readableExecute(request)) ?? []
                    guard result.isEmpty
                    else {
                        return
                    }
                    
                    Task { @PersistenceWritableActor in
                        let account = PersistenceAccount.writeableObject(id: accountID)
                        let _ = [
                            PersistenceBrowserFavourite(
                                title: "Disintar",
                                subtitle: nil,
                                url: URL(string: "https://disintar.io")!,
                                account: account
                            ),
                            PersistenceBrowserFavourite(
                                title: "BITON",
                                subtitle: nil,
                                url: URL(string: "https://dex.biton.app")!,
                                account: account
                            ),
                            PersistenceBrowserFavourite(
                                title: "Getgems",
                                subtitle: nil,
                                url: URL(string: "https://getgems.io")!,
                                account: account
                            ),
                            PersistenceBrowserFavourite(
                                title: "Jetton deployer",
                                subtitle: nil,
                                url: URL(string: "https://jetton.live")!,
                                account: account
                            ),
                            PersistenceBrowserFavourite(
                                title: "Scaleton",
                                subtitle: nil,
                                url: URL(string: "https://scaleton.io")!,
                                account: account
                            ),
                        ]
                        
                        try? PersistenceWritableActor.shared.managedObjectContext.save()
                    }
                }
            )
            
            return C42NavigationController(
                rootViewController: viewController
            )
        }
    }
}
