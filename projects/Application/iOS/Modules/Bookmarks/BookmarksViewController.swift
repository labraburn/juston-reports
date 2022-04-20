//
//  BookmarksViewController.swift
//  iOS
//
//  Created by Anton Spivak on 20.04.2022.
//

import UIKit

class BookmarksViewController: SCLS3000ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        apply(
            snapshot: .bookmarksDefaultSnapshot(withViewController: self)
        )
    }
}

private extension NSDiffableDataSourceSnapshot where SectionIdentifierType == SCLS3000Section, ItemIdentifierType == SCLS3000Item {
    
    static var bookmarks: [UserBookmark] = [
        .init(name: "ton.place", url: URL(string: "https://ton.place")!, image: nil),
        .init(name: "tonch.cc", url: URL(string: "https://tonch.cc")!, image: nil),
    ]
    
    static func bookmarksDefaultSnapshot(
        withViewController viewController: BookmarksViewController
    ) ->NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType> {
        var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>()
        
        // Logo section
        snapshot.appendSection(.init(kind: .simple, header: .logo), items: [])
        
        
        // Predefined bookmarks
        
        snapshot.appendSection(
            .init(kind: .simple, header: .none),
            items: bookmarks.map({ bookmark in
                .init(kind: .bookmark(value: bookmark), synchronousAction: { [weak viewController] in
                    viewController?.open(url: bookmark.url, options: .web3)
                })
            })
        )
        
        return snapshot
    }
}
