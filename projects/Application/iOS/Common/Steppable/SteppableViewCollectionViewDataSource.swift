//
//  SteppableViewCollectionViewDataSource.swift
//  iOS
//
//  Created by Anton Spivak on 10.04.2022.
//

import UIKit
import HuetonUI

struct SteppableSection {
    
    enum Kind {
        
        case simple
        case words
    }
    
    let kind: Kind
    let rawValue: String
    
    init(kind: Kind) {
        self.kind = kind
        self.rawValue = UUID().uuidString
    }
}

enum SteppableItem {
    
    typealias SynchronousButtonAction = (_ viewController: SteppableViewController) throws -> ()
    typealias AsynchronousButtonAction = (_ viewController: SteppableViewController) async throws -> ()
    
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
    case importAccountTextField(uuid: UUID, action: (_ result: SteppableImportAccountCollectionCell.Result) -> Void)
    case textField(title: String, placeholder: String, action: TextFieldAction)
    
    case synchronousButton(title: String, kind: ButtonKind, action: SynchronousButtonAction)
    case asynchronousButton(title: String, kind: ButtonKind, action: AsynchronousButtonAction)
}

class SteppableViewCollectionViewDataSource: CollectionViewDiffableDataSource<SteppableSection, SteppableItem> {

    override init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView)
        
        collectionView.register(reusableCellClass: SteppableImageViewCell.self)
        collectionView.register(reusableCellClass: SteppableLabelCell.self)
        collectionView.register(reusableCellClass: SteppableButtonCell.self)
        collectionView.register(reusableCellClass: SteppableWordCell.self)
        collectionView.register(reusableCellClass: SteppableTextFieldCell.self)
        collectionView.register(reusableCellClass: SteppableImportAccountCollectionCell.self)
        collectionView.collectionViewLayout.register(reusableDecorationViewOfKind: SteppableWordsDecorationView.self)
    }
    
    override func cell(
        with collectionView: UICollectionView,
        indexPath: IndexPath,
        item: SteppableItem
    ) -> UICollectionViewCell? {
        switch item {
        case let .image(image):
            let cell = collectionView.dequeue(reusableCellClass: SteppableImageViewCell.self, for: indexPath)
            cell.image = image
            return cell
        case let .label(text, kind):
            let cell = collectionView.dequeue(reusableCellClass: SteppableLabelCell.self, for: indexPath)
            cell.model = .init(text: text, kind: kind)
            return cell
        case let .synchronousButton(title, kind, _), let .asynchronousButton(title, kind, _): // action handled in controller
            let cell = collectionView.dequeue(reusableCellClass: SteppableButtonCell.self, for: indexPath)
            cell.model = .init(title: title, kind: kind)
            return cell
        case let .word(index, word):
            let cell = collectionView.dequeue(reusableCellClass: SteppableWordCell.self, for: indexPath)
            cell.model = .init(index: index, word: word)
            return cell
        case let .textField(title, placeholder, action):
            let cell = collectionView.dequeue(reusableCellClass: SteppableTextFieldCell.self, for: indexPath)
            cell.title = title
            cell.placeholder = placeholder
            cell.change = { textField in
                action(textField)
            }
            return cell
        case let .importAccountTextField(_, action):
            let cell = collectionView.dequeue(reusableCellClass: SteppableImportAccountCollectionCell.self, for: indexPath)
            cell.done = action
            return cell
        }
    }
}

extension SteppableSection: Hashable {
    
    static func == (lhs: SteppableSection, rhs: SteppableSection) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
        
    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

extension SteppableItem: Hashable {
    
    static func == (lhs: SteppableItem, rhs: SteppableItem) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .image(image):
            hasher.combine(image)
        case let .label(text, kind):
            hasher.combine(text)
            hasher.combine(kind)
        case let .synchronousButton(title, _, _), let .asynchronousButton(title, _, _):
            hasher.combine(title)
        case let .word(index, word):
            hasher.combine(index)
            hasher.combine(word)
        case let .textField(title, placeholder, _):
            hasher.combine(title)
            hasher.combine(placeholder)
        case let .importAccountTextField(uuid, _):
            hasher.combine(uuid)
        }
    }
}
