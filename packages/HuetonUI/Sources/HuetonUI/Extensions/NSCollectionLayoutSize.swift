//
//  Created by Anton Spivak
//

import UIKit

public extension NSCollectionLayoutSize {
    
    static var parent: NSCollectionLayoutSize {
        NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
    }

    static var zero: NSCollectionLayoutSize {
        NSCollectionLayoutSize(
            widthDimension: .absolute(0),
            heightDimension: .absolute(0)
        )
    }
}
