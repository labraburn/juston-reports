//
//  Created by Anton Spivak.
//

import UIKit

open class CollectionViewDiffableDataSource<S, I>: UICollectionViewDiffableDataSource<S, I> where S : Hashable, I : Hashable {

    public init(collectionView: UICollectionView) {
        weak var welf: CollectionViewDiffableDataSource<S, I>? = nil
        super.init(
            collectionView: collectionView,
            cellProvider: { welf?.cell(with: $0, indexPath: $1, item: $2) }
        )
        supplementaryViewProvider = { welf?.view(with: $0, elementKind: $1, indexPath: $2) }
        welf = self
    }
    
    open func cell(
        with collectionView: UICollectionView,
        indexPath: IndexPath,
        item: I
    ) -> UICollectionViewCell? {
        return nil
    }
    
    open func view(
        with collectionView: UICollectionView,
        elementKind: String,
        indexPath: IndexPath
    ) -> UICollectionReusableView? {
        return nil
    }
}
