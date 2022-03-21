//
//  AccountAddingViewController.swift
//  iOS
//
//  Created by Anton Spivak on 20.03.2022.
//

import UIKit
import BilftUI

protocol AccountAddingViewControllerDelegate: AnyObject {
    
    func accountAddingViewController(
        _ viewController: AccountAddingViewController,
        didAddSaveAccount account: Account,
        into accounts: [Account]
    )
}

class AccountAddingViewController: UIViewController {
    
    private lazy var collectionDataSource = AccountAddingDataSource(collectionView: collectionView)
    private lazy var collectionViewLayout = AccountAddingViewCollectionViewLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    
    private var task: Task<Void, Never>?
    
    weak var delegate: AccountAddingViewControllerDelegate? = nil
    
    var locked: Bool = false {
        didSet {
            view.isUserInteractionEnabled = locked
        }
    }
    
    let model: AccountAddingModel
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)
    
    init(model: AccountAddingModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isModalInPresentation = model.isModalInPresentation
        navigationController?.isModalInPresentation = model.isModalInPresentation
        
        title = model.title
        navigationItem.backButtonTitle = ""
        
        collectionViewLayout.delegate = self
        
        collectionView.keyboardDismissMode = .onDrag
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .bui_backgroundPrimary
        view.addSubview(collectionView)
        collectionView.pinned(edges: view)
        
        load(model: model)
    }
    
    // MARK: API
    
    func next(_ model: AccountAddingModel) {
        let nextViewController = AccountAddingViewController(model: model)
        nextViewController.delegate = delegate
        
        navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func finish(with account: Account) {
        guard task == nil
        else {
            return
        }
        
        task = Task { [weak self] in
            guard let self = self
            else {
                return
            }
            
            var accounts = await CodableStorage.group.methods.accounts()
            accounts.append(account)
            
            CodableStorage.group.methods.save(accounts: accounts)
            self.task = nil
            
            delegate?.accountAddingViewController(self, didAddSaveAccount: account, into: accounts)
            navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: Private
    
    private func load(model: AccountAddingModel) {
        var snapshot = NSDiffableDataSourceSnapshot<AccountAddingSection, AccountAddingItem>()
        
        switch model.kind {
        case let .default(image, text):
            snapshot.appendSection(.simple(id: 0), items: [.image(image: image)])
            snapshot.appendSection(.simple(id: 1), items: [.label(text: text)])
        case let .words(array, text):
            snapshot.appendSection(.simple(id: 1), items: [.label(text: text)])
            
            var index = 1
            let first = AccountAddingSection.words
            snapshot.appendSections([first])
            array.forEach({
                snapshot.appendItems([.word(index: index, word: $0)], toSection: first)
                index += 1
            })
            
        case let .import(text):
            snapshot.appendSection(.simple(id: 1), items: [.label(text: text)])
        case .appearance:
            break
        }
        
        snapshot.appendSection(.simple(id: 3), items: model.fields.map({
            .textField(title: $0.title, placeholder: $0.placeholder, action: $0.action)
        }))
        
        snapshot.appendSection(.simple(id: 4), items: model.actions.map({
            .button(title: $0.title, kind: $0.kind, action: $0.block)
        }))
        
        let animatingDifferences = view.window != nil && !collectionDataSource.snapshot().itemIdentifiers.isEmpty
        collectionDataSource.apply(
            snapshot,
            animatingDifferences: animatingDifferences
        )
    }
}

extension AccountAddingViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let itemIdentifier = collectionDataSource.itemIdentifier(for: indexPath)
        else {
            return
        }
        
        switch itemIdentifier {
        case let .button(_, _, action):
            action(self)
        default:
            break
        }
    }
}

extension AccountAddingViewController: AccountAddingViewCollectionViewLayoutDelegate {
    
    func accountAddingViewCollectionViewLayout(
        _ layout: AccountAddingViewCollectionViewLayout,
        sectionIdentifierFor sectionIndex: Int
    ) -> AccountAddingSection? {
        collectionDataSource.sectionIdentifier(forSectionIndex: sectionIndex)
    }
}
