//
//  Created by Anton Spivak
//

import Foundation
import UIKit

public extension NSCollectionLayoutSection {
    
    static var zero: NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .zero)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .zero, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }
}
