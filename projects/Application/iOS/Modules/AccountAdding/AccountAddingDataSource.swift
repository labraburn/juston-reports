//
//  AccountAddingDataSource.swift
//  iOS
//
//  Created by Anton Spivak on 21.03.2022.
//

import UIKit
import BilftUI

enum AccountAddingSection {
    
    case words
    case simple(id: Int)
}

enum AccountAddingItem {
    
    typealias ButtonAction = (_ viewController: AccountAddingViewController) -> ()
    typealias TextFieldAction = (_ textField: UITextField) -> ()
    
    enum ButtonKind {
        
        case primary
        case secondary
    }
    
    case image(image: UIImage)
    case label(text: String)
    case button(title: String, kind: ButtonKind, action: ButtonAction)
    case word(index: Int, word: String)
    case textField(title: String, placeholder: String, action: TextFieldAction)
}

final class AccountAddingDataSource: CollectionViewDiffableDataSource<AccountAddingSection, AccountAddingItem> {
    
    override init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView)
        
        collectionView.register(reusableCellClass: AccountAddingImageViewCell.self)
        collectionView.register(reusableCellClass: AccountAddingLabelCell.self)
        collectionView.register(reusableCellClass: AccountAddingButtonCell.self)
        collectionView.register(reusableCellClass: AccountAddingWordCell.self)
        collectionView.register(reusableCellClass: AccountAddingTextFieldCell.self)
        collectionView.collectionViewLayout.register(reusableDecorationViewOfKind: AccountAddingWordsDecorationView.self)
    }
    
    override func cell(
        with collectionView: UICollectionView,
        indexPath: IndexPath,
        item: AccountAddingItem
    ) -> UICollectionViewCell? {
        switch item {
        case let .image(image):
            let cell = collectionView.dequeue(reusableCellClass: AccountAddingImageViewCell.self, for: indexPath)
            cell.image = image
            return cell
        case let .label(text):
            let cell = collectionView.dequeue(reusableCellClass: AccountAddingLabelCell.self, for: indexPath)
            cell.text = text
            return cell
        case let .button(title, kind, _):
            let cell = collectionView.dequeue(reusableCellClass: AccountAddingButtonCell.self, for: indexPath)
            cell.title = title
            cell.kind = kind
            return cell
        case let .word(index, word):
            let cell = collectionView.dequeue(reusableCellClass: AccountAddingWordCell.self, for: indexPath)
            cell.text = "\(index). \(word)"
            return cell
        case let .textField(title, placeholder, action):
            let cell = collectionView.dequeue(reusableCellClass: AccountAddingTextFieldCell.self, for: indexPath)
            cell.title = title
            cell.placeholder = placeholder
            cell.change = { textField in
                action(textField)
            }
            return cell
        }
    }
}

extension AccountAddingSection: Hashable {}
extension AccountAddingItem: Hashable {
    
    static func == (lhs: AccountAddingItem, rhs: AccountAddingItem) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .image(image):
            hasher.combine(image)
        case let .label(text):
            hasher.combine(text)
        case let .button(title, _, _):
            hasher.combine(title)
        case let .word(index, word):
            hasher.combine(index)
            hasher.combine(word)
        case let .textField(title, placeholder, _):
            hasher.combine(title)
            hasher.combine(placeholder)
        }
    }
}
