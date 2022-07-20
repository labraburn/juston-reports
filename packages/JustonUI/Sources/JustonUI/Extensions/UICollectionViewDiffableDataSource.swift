//
//  Created by Anton Spivak.
//

import UIKit

public extension UICollectionViewDiffableDataSource {
    
    func sectionIdentifier(forSectionIndex sectionIndex: Int) -> SectionIdentifierType? {
        if #available(iOS 15, *) {
            return sectionIdentifier(for: sectionIndex)
        }
        else {
            let sectionIdentifiers = snapshot().sectionIdentifiers
            guard sectionIdentifiers.count > sectionIndex
            else {
                return nil
            }
            return sectionIdentifiers[sectionIndex]
        }
    }
}
