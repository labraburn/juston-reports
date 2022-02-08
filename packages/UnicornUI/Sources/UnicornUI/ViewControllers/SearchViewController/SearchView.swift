//
//  Created by Anton Spivak
//

import UIKit

internal final class SearchView: UIView {
    var resultsView: UIView? {
        didSet {
            guard resultsView != oldValue
            else {
                return
            }

            oldValue?.removeFromSuperview()

            guard let resultsView = resultsView
            else {
                return
            }

            addSubview(resultsView)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        resultsView?.frame = bounds
    }
}
