//
//  Created by Anton Spivak.
//

import UIKit

open class CollectionViewCompositionalLayout: UICollectionViewCompositionalLayout {

    public init() {
        weak var welf: CollectionViewCompositionalLayout? = nil
        super.init(sectionProvider: { welf?.section(forIndex: $0, withEnvironmant: $1) })
        welf = self
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func section(
        forIndex index: Int,
        withEnvironmant environmnet: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection? {
        nil
    }
}
