//
//  SteppableViewController.swift
//  iOS
//
//  Created by Anton Spivak on 10.04.2022.
//

import UIKit
import HuetonUI
import HuetonCORE

class SteppableViewController: UIViewController {
    
    private lazy var collectionDataSource = SteppableViewCollectionViewDataSource(collectionView: collectionView)
    private lazy var collectionViewLayout = SteppableViewCollectionViewLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    
    private var task: Task<(), Never>?
    private var locked: Bool = false {
        didSet {
            view.isUserInteractionEnabled = locked
        }
    }
    
    let model: SteppableViewModel
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)
    
    init(model: SteppableViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = model.title
        navigationItem.backButtonTitle = ""
        navigationItem.setHidesBackButton(!model.isBackActionAvailable, animated: true)
        
        collectionViewLayout.delegate = self
        
        collectionView.keyboardDismissMode = .onDrag
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .hui_backgroundPrimary
        view.addSubview(collectionView)
        collectionView.pinned(edges: view)
        
        load(model: model)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        isModalInPresentation = model.isModalInPresentation
        navigationController?.isModalInPresentation = model.isModalInPresentation
    }
    
    // MARK: API
    
    func next(_ model: SteppableViewModel) {
        let nextViewController = SteppableViewController(model: model)
        navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func finish() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Private
    
    private func load(model: SteppableViewModel) {
        var snapshot = NSDiffableDataSourceSnapshot<SteppableSection, SteppableItem>()

        model.sections.forEach({ sectionViewModel in
            snapshot.appendSection(
                sectionViewModel.section,
                items: sectionViewModel.items
            )
        })

        let animatingDifferences = view.window != nil && !collectionDataSource.snapshot().itemIdentifiers.isEmpty
        collectionDataSource.apply(
            snapshot,
            animatingDifferences: animatingDifferences
        )
    }
}

extension SteppableViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let itemIdentifier = collectionDataSource.itemIdentifier(for: indexPath)
        else {
            return
        }
        
        switch itemIdentifier {
        case let .synchronousButton(_, _, action):
            do {
                try action(self)
            } catch {
                present(error)
            }
        case let .asynchronousButton(_, _, action):
            view.isUserInteractionEnabled = true
            task?.cancel()
            task = Task {
                do {
                    try await action(self)
                } catch {
                    present(error)
                }
                
                view.isUserInteractionEnabled = true
                task = nil
            }
        default:
            break
        }
    }
}

extension SteppableViewController: SteppableViewCollectionViewLayoutDelegate {
    
    func steppableViewCollectionViewLayout(
        _ layout: SteppableViewCollectionViewLayout,
        sectionIdentifierFor sectionIndex: Int
    ) -> SteppableSection? {
        collectionDataSource.sectionIdentifier(forSectionIndex: sectionIndex)
    }
}
