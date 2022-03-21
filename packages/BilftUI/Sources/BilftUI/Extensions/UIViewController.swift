//
//  Created by Anton Spivak.
//

import UIKit

extension UIViewController {
    
    public func bui_present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        viewControllerToPresent.loadViewIfNeeded()
        viewControllerToPresent.view.layer.speed = 1.6
        self.present(viewControllerToPresent, animated: flag, completion: {
            viewControllerToPresent.view.layer.speed = 1
            completion?()
        })
    }
}
