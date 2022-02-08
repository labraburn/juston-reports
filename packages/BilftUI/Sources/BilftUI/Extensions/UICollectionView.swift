//
//  Created by Anton Spivak.
//

import UIKit

extension UICollectionView {
    
    public func register(reusableCellClass klass: UICollectionViewCell.Type) {
        register(klass, forCellWithReuseIdentifier: identifier(for: klass))
    }

    public func dequeue<T: UICollectionViewCell>(reusableCellClass klass: T.Type, for indexPath: IndexPath) -> T {
        let identifier = identifier(for: klass)
        guard let view = dequeueReusableCell(
            withReuseIdentifier: identifier,
            for: indexPath
        ) as? T else {
            fatalError("Reusable cell `\(identifier)` did not registered")
        }
        return view
    }

    public func register(
        reusableSupplementaryViewClass klass: UICollectionReusableView.Type,
        elementKind: String? = nil
    ) {
        let identifier = identifier(for: klass)
        register(
            klass,
            forSupplementaryViewOfKind: elementKind ?? identifier,
            withReuseIdentifier: identifier
        )
    }

    public func dequeue<T: UICollectionReusableView>(
        reusableSupplementaryViewClass klass: T.Type,
        elementKind: String? = nil,
        for indexPath: IndexPath
    ) -> T {
        let identifier = identifier(for: klass)
        guard let view = dequeueReusableSupplementaryView(
            ofKind: elementKind ?? identifier,
            withReuseIdentifier: identifier,
            for: indexPath
        ) as? T else {
            fatalError("Reusable supplementary view `\(identifier)` did not registered")
        }
        return view
    }

    private func identifier(for klass: AnyClass) -> String {
        String(describing: klass)
    }
}

extension UICollectionView {
    public func indexPath(
        for supplementaryView: UICollectionReusableView?,
        ofKind kind: String
    ) -> IndexPath? {
        let elements = visibleSupplementaryViews(ofKind: kind)
        let indexPaths = indexPathsForVisibleSupplementaryElements(ofKind: kind)

        for (element, indexPath) in zip(elements, indexPaths) where element === supplementaryView {
            return indexPath
        }

        return nil
    }
}
