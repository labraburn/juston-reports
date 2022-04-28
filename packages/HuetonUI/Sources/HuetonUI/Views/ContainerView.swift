//
//  Created by Anton Spivak.
//

import UIKit

public class ContainerView<T>: UIView where T: UIView {
    
    private var size: CGSize = .zero
    
    public var enclosingView: T? {
        didSet {
            oldValue?.removeFromSuperview()
            setNeedsLayout()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let enclosingView = enclosingView
        else {
            return
        }

        if enclosingView.superview != self {
            addSubview(enclosingView)
        }
        
        guard bounds.size != size
        else {
            return
        }
        
        size = bounds.size
        enclosingView.frame = bounds
    }
}
