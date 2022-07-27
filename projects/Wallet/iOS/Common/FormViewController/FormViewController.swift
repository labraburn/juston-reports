//
//  FormViewController.swift
//  iOS
//
//  Created by Anton Spivak on 27.07.2022.
//

import UIKit
import JustonUI

class FormViewController: UIViewController {
    
    private lazy var collectionViewDataSource = FormCollectionViewDataSource(collectionView: collectionView).with({
        $0.formInputCellDelegate = self
    })
    
    private lazy var collectionViewLayout = FormCollectionViewCompositionalLayout().with({
        $0.delegate = self
    })
    
    private lazy var collectionView = FormCollectionView(frame: .zero, collectionViewLayout: collectionViewLayout).with({
        $0.keyboardDismissMode = .onDrag
        $0.delegate = self
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .jus_backgroundPrimary
        $0.delaysContentTouches = false
    })
    
    private var activeEditingInputCell: FormTextCollectionViewCell? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        collectionView.pinned(edges: view)
    }
    
    func formInput(
        at indexPath: IndexPath
    ) -> FormInput? {
        guard indexPath.item < collectionViewDataSource.collectionView(collectionView, numberOfItemsInSection: 0)
        else {
            return nil
        }
        
        return collectionView.cellForItem(at: indexPath) as? FormInput
    }
    
    func apply(
        _ items: [FormCollectionViewItem],
        in section: FormCollectionViewSection,
        animatingDifferences: Bool = true
    ) {
        var snapshot = NSDiffableDataSourceSnapshot<FormCollectionViewSection, FormCollectionViewItem>()
        snapshot.appendSection(section, items: items)
        collectionViewDataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

extension FormViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        view.endEditing(true)
    }
}

extension FormViewController: FormInputCollectionViewCellDelegate {
    
    func formInputCollectionViewCellDidStartEditing(
        _ cell: FormInputCollectionViewCell
    ) {
        guard let indexPath = collectionView.indexPath(for: cell)
        else {
            return
        }
        
        collectionView.scrollToItem(
            at: indexPath,
            at: .centeredVertically,
            animated: true
        )
    }
    
    func formInputCollectionViewCellDidRequestNext(
        _ cell: FormInputCollectionViewCell
    ) {
        guard let indexPath = collectionView.indexPath(for: cell),
              indexPath.item + 1 < collectionViewDataSource.collectionView(collectionView, numberOfItemsInSection: 0)
        else {
            return
        }
        
        let cell = collectionView.cellForItem(at: IndexPath(item: indexPath.item + 1, section: 0))
        cell?.becomeFirstResponder()
    }
    
    func formInputCollectionViewCellDidEndEditing(
        _ cell: FormTextCollectionViewCell
    ) {
        
    }
}

extension FormViewController: FormCollectionViewCompositionalLayoutDelegate {
    
    func collectionViewLayout(
        _ layout: FormCollectionViewCompositionalLayout,
        sectionIdentifierFor sectionIndex: Int
    ) -> FormCollectionViewSection? {
        collectionViewDataSource.sectionIdentifier(
            forSectionIndex: sectionIndex
        )
    }
}

private class FormCollectionView: DiffableCollectionView {
    
    override func touchesShouldBegin(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) -> Bool {
        guard view is JustonButton
        else {
            return super.touchesShouldBegin(touches, with: event, in: view)
        }
        
        return true
    }
}
