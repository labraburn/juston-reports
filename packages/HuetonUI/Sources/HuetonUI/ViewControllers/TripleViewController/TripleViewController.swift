//
//  Created by Anton Spivak
//

import UIKit

public protocol TripleViewControllerDelegate: AnyObject {
    
    func tripleViewController(
        _ viewController: TripleViewController,
        didChangeOffset offset: CGPoint
    )
    
    func tripleViewController(
        _ viewController: TripleViewController,
        didChangePresentation presentation: TriplePresentation
    )
}

open class TripleViewController: UIViewController {
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(
        style: .medium
    )
    
    private var tripleView: TripleView {
        view as! TripleView
    }
    
    public var presentation: TriplePresentation {
        tripleView.presentation
    }
    
    public let viewControlles: (UIViewController, UIViewController, UIViewController)
    public let compactHeight: CGFloat
    
    public weak var delegate: TripleViewControllerDelegate?
    
    public init(
        _ viewControllers: (UIViewController, UIViewController, UIViewController),
        compactHeight: CGFloat = 128
    ) {
        self.viewControlles = viewControllers
        self.compactHeight = compactHeight
        
        super.init(
            nibName: nil,
            bundle: nil
        )
    }
    
    @available(*, unavailable)
    required public init?(
        coder: NSCoder
    ) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func loadView() {
        addChild(viewControlles.0)
        addChild(viewControlles.1)
        addChild(viewControlles.2)
        
        let tripleView = TripleView(
            centerViewCompactHeight: compactHeight,
            views: (
                viewControlles.0.view,
                viewControlles.1.view,
                viewControlles.2.view
            )
        )
        
        tripleView.delegate = self
        view = tripleView
        
        viewControlles.0.didMove(toParent: self)
        viewControlles.1.didMove(toParent: self)
        viewControlles.2.didMove(toParent: self)
    }
    
    open func update(
        presentation: TriplePresentation,
        animated: Bool
    ) {
        tripleView.update(
            presentation: presentation,
            animated: animated
        )
    }
}

extension TripleViewController: TripleViewDelegate {
    
    func tripleView(
        _ view: TripleView,
        didChangePresentation presentation: TriplePresentation
    ) {
        feedbackGenerator.impactOccurred()
        delegate?.tripleViewController(
            self,
            didChangePresentation: presentation
        )
    }
    
    func tripleView(
        _ view: TripleView,
        didChangeBounds bounds: CGRect
    ) {
        delegate?.tripleViewController(
            self,
            didChangeOffset: bounds.origin
        )
    }
}
