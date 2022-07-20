//
//  C42CollectionViewDataSource.swift
//  iOS
//
//  Created by Anton Spivak on 10.04.2022.
//

import UIKit
import JustonUI

typealias C42SynchronousButtonAction = (_ viewController: C42ViewController) throws -> ()
typealias C42AsynchronousButtonAction = (_ viewController: C42ViewController) async throws -> ()

struct C42Section {
    
    enum Header {
        
        case none
        
        case title(
            value: String,
            textAligment: NSTextAlignment = .left,
            foregroundColor: UIColor = .jus_textSecondary
        )
        
        case logo(
            secretAction: C42SynchronousButtonAction
        )
        
        case applicationVersion
    }
    
    enum Kind {
        
        case list
        case simple
        case words
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

enum C42Item {
    
    typealias TextFieldAction = (_ textField: UITextField) -> ()
    
    enum LabelKind {
        
        case headline
        case body
    }
    
    enum ButtonKind {
        
        case primary
        case secondary
        case teritary
    }
    
    case image(image: UIImage)
    case label(text: String, kind: LabelKind)
    case word(index: Int, word: String)
    case textField(title: String, placeholder: String, action: TextFieldAction)
    case text(value: String, numberOfLines: Int = 1, textAligment: NSTextAlignment = .left)
    
    case settingsButton(title: String, titleColor: UIColor, action: C42SynchronousButtonAction)
    
    case synchronousButton(title: String, kind: ButtonKind, action: C42SynchronousButtonAction)
    case asynchronousButton(title: String, kind: ButtonKind, action: C42AsynchronousButtonAction)
}

class C42CollectionViewDataSource: CollectionViewDiffableDataSource<C42Section, C42Item> {

    override init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView)
        
        collectionView.register(reusableCellClass: C42ImageViewCell.self)
        collectionView.register(reusableCellClass: C42LabelCell.self)
        collectionView.register(reusableCellClass: C42WordCell.self)
        collectionView.register(reusableCellClass: C42TextFieldCell.self)
        collectionView.register(reusableCellClass: C42AccessoryCollectionViewCell.self)
        
        collectionView.register(reusableCellClass: C42ButtonCell.self)
        collectionView.register(reusableCellClass: C42SettingsButtonCell.self)
        
        collectionView.register(reusableSupplementaryViewClass: C42ListGroupHeaderView.self)
        collectionView.register(reusableSupplementaryViewClass: C42SimpleGroupHeaderView.self)
        collectionView.register(reusableSupplementaryViewClass: C42LogoHeaderView.self)
        collectionView.register(reusableSupplementaryViewClass: C42ApplicationVersionHeaderView.self)
        
        collectionView.collectionViewLayout.register(reusableDecorationViewOfKind: C42WordsDecorationView.self)
        collectionView.collectionViewLayout.register(reusableDecorationViewOfKind: C42ListGroupDecorationView.self)
    }
    
    override func cell(
        with collectionView: UICollectionView,
        indexPath: IndexPath,
        item: C42Item
    ) -> UICollectionViewCell? {
        switch item {
        case let .image(image):
            let cell = collectionView.dequeue(reusableCellClass: C42ImageViewCell.self, for: indexPath)
            cell.image = image
            return cell
        case let .label(text, kind):
            let cell = collectionView.dequeue(reusableCellClass: C42LabelCell.self, for: indexPath)
            cell.model = .init(text: text, kind: kind)
            return cell
        case let .settingsButton(title, titleColor, _):
            let cell = collectionView.dequeue(reusableCellClass: C42SettingsButtonCell.self, for: indexPath)
            cell.model = .init(title: title, titleColor: titleColor)
            return cell
        case let .synchronousButton(title, kind, _), let .asynchronousButton(title, kind, _): // action handled in controller
            let cell = collectionView.dequeue(reusableCellClass: C42ButtonCell.self, for: indexPath)
            cell.model = .init(title: title, kind: kind)
            return cell
        case let .word(index, word):
            let cell = collectionView.dequeue(reusableCellClass: C42WordCell.self, for: indexPath)
            cell.model = .init(index: index, word: word)
            return cell
        case let .textField(title, placeholder, action):
            let cell = collectionView.dequeue(reusableCellClass: C42TextFieldCell.self, for: indexPath)
            cell.title = title
            cell.placeholder = placeholder
            cell.change = { textField in
                action(textField)
            }
            return cell
        case let .text(value, numberOfLines, textAligment):
            let cell = collectionView.dequeue(
                reusableCellClass: C42AccessoryCollectionViewCell.self,
                for: indexPath
            )
            cell.text = value
            cell.numberOfLines = numberOfLines
            cell.textAligment = textAligment
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
        case String(describing: C42ListGroupHeaderView.self):
            let view = collectionView.dequeue(
                reusableSupplementaryViewClass: C42ListGroupHeaderView.self,
                for: indexPath
            )
            
            switch section.header {
            case let .title(value, textAligment, foregroundColor):
                view.title = value
                view.textAligment = textAligment
                view.foregroundColor = foregroundColor
            case .logo, .applicationVersion, .none:
                view.title = ""
            }
            
            return view
        case String(describing: C42SimpleGroupHeaderView.self):
            let view = collectionView.dequeue(
                reusableSupplementaryViewClass: C42SimpleGroupHeaderView.self,
                for: indexPath
            )
            
            switch section.header {
            case let .title(value, textAligment, foregroundColor):
                view.title = value
                view.textAligment = textAligment
                view.foregroundColor = foregroundColor
            case .logo, .applicationVersion, .none:
                view.title = ""
            }
            
            return view
        case String(describing: C42LogoHeaderView.self):
            let view = collectionView.dequeue(
                reusableSupplementaryViewClass: C42LogoHeaderView.self,
                for: indexPath
            )
            
            switch section.header {
            case let .logo(action):
                view.action = { [weak collectionView] in
                    guard let viewController = collectionView?.delegate as? C42ViewController
                    else {
                        fatalError("")
                    }
                    
                    do {
                        try action(viewController)
                    } catch {
                        viewController.present(error)
                    }
                }
            default:
                view.action = nil
            }
            
            return view
        case String(describing: C42ApplicationVersionHeaderView.self):
            let view = collectionView.dequeue(
                reusableSupplementaryViewClass: C42ApplicationVersionHeaderView.self,
                for: indexPath
            )
            return view
        default:
            return nil
        }
    }
}

extension C42Section: Hashable {
    
    static func == (lhs: C42Section, rhs: C42Section) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
        
    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

extension C42Item: Hashable {
    
    static func == (lhs: C42Item, rhs: C42Item) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .image(image):
            hasher.combine(image)
        case let .label(text, kind):
            hasher.combine(text)
            hasher.combine(kind)
        case let .settingsButton(title, _, _):
            hasher.combine(title)
        case let .synchronousButton(title, _, _), let .asynchronousButton(title, _, _):
            hasher.combine(title)
        case let .word(index, word):
            hasher.combine(index)
            hasher.combine(word)
        case let .textField(title, placeholder, _):
            hasher.combine(title)
            hasher.combine(placeholder)
        case let .text(value, _, _):
            hasher.combine(value)
        }
    }
}
