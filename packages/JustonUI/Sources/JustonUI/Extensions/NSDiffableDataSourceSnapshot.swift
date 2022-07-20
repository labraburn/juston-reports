//
//  Created by Anton Spivak.
//

import UIKit

extension NSDiffableDataSourceSnapshot {
    
    public mutating func appendSection(_ sectionIdentifier: SectionIdentifierType, items: [ItemIdentifierType]) {
        appendSections([sectionIdentifier])
        appendItems(items, toSection: sectionIdentifier)
    }
}
