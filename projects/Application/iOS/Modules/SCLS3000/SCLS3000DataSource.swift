//
//  SCLS3000DataSource.swift
//  iOS
//
//  Created by Anton Spivak on 20.04.2022.
//

import UIKit
import HuetonUI

protocol SCLS3000DataSourceDelegate: AnyObject {}

struct SCLS3000Section {
    
    enum Header {
        
        case none
        case title(value: String)
        case logo
        case applicationVersion
    }
    
    enum Kind {
        
        case list
        case simple
    }
    
    let kind: Kind
    let header: Header
    let rawValue: String
    
    init(kind: Kind, header: Header = .none) {
        self.kind = kind
        self.header = header
        self.rawValue = UUID().uuidString
    }
}

struct SCLS3000Item {
    
    typealias SynchronousAction = @MainActor () throws -> ()
    typealias AsynchronousAction = () async throws -> ()
    
    enum Kind {
        
        case text(value: String)
        case bookmark(value: UserBookmark)
    }
    
    let kind: Kind
    
    let synchronousAction: SynchronousAction?
    let asynchronousAction: AsynchronousAction?
    
    init(kind: Kind, synchronousAction: @escaping SynchronousAction) {
        self.kind = kind
        self.synchronousAction = synchronousAction
        self.asynchronousAction = nil
    }
    
    init(kind: Kind, asynchronousAction: @escaping AsynchronousAction) {
        self.kind = kind
        self.synchronousAction = nil
        self.asynchronousAction = asynchronousAction
    }
}

class SCLS3000DataSource: CollectionViewDiffableDataSource<SCLS3000Section, SCLS3000Item> {
    
    weak var delegate: SCLS3000DataSourceDelegate?
    
    override init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView)
        
        collectionView.register(reusableCellClass: SCLS3000AccessoryCollectionViewCell.self)
        collectionView.register(reusableCellClass: SCLS3000BookmarkCollectionViewCell.self)
        
        collectionView.register(reusableSupplementaryViewClass: SCLS3000ListGroupHeaderView.self)
        collectionView.register(reusableSupplementaryViewClass: SCLS3000LogoHeaderView.self)
        collectionView.register(reusableSupplementaryViewClass: SCLS3000ApplicationVersionHeaderView.self)
    }
    
    override func cell(
        with collectionView: UICollectionView,
        indexPath: IndexPath,
        item: SCLS3000Item
    ) -> UICollectionViewCell? {
        switch item.kind {
        case let .text(value):
            let cell = collectionView.dequeue(
                reusableCellClass: SCLS3000AccessoryCollectionViewCell.self,
                for: indexPath
            )
            cell.text = value
            return cell
        case let .bookmark(value):
            let cell = collectionView.dequeue(
                reusableCellClass: SCLS3000BookmarkCollectionViewCell.self,
                for: indexPath
            )
            cell.model = .init(
                text: value.name,
                url: value.url,
                image: value.image
            )
            return cell
        }
    }
    
    override func view(
        with collectionView: UICollectionView,
        elementKind: String,
        indexPath: IndexPath
    ) -> UICollectionReusableView? {
        guard let section = sectionIdentifier(forSectionIndex: indexPath.section)
        else {
            return nil
        }
        
        switch elementKind {
        case String(describing: SCLS3000ListGroupHeaderView.self):
            let view = collectionView.dequeue(
                reusableSupplementaryViewClass: SCLS3000ListGroupHeaderView.self,
                for: indexPath
            )
            
            switch section.header {
            case let .title(value):
                view.title = value
            case .logo, .applicationVersion, .none:
                view.title = ""
            }
            
            return view
        case String(describing: SCLS3000LogoHeaderView.self):
            let view = collectionView.dequeue(
                reusableSupplementaryViewClass: SCLS3000LogoHeaderView.self,
                for: indexPath
            )
            return view
        case String(describing: SCLS3000ApplicationVersionHeaderView.self):
            let view = collectionView.dequeue(
                reusableSupplementaryViewClass: SCLS3000ApplicationVersionHeaderView.self,
                for: indexPath
            )
            return view
        default:
            return nil
        }
    }
}

extension SCLS3000Section: Hashable {
    
    static func == (lhs: SCLS3000Section, rhs: SCLS3000Section) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
        
    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

extension SCLS3000Item: Hashable {
    
    static func == (lhs: SCLS3000Item, rhs: SCLS3000Item) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        switch kind {
        case let .text(value):
            hasher.combine(value)
        case let .bookmark(value):
            hasher.combine(value)
        }
    }
}
