//
//  Created by Anton Spivak
//

import UIKit

internal protocol TripleViewDelegate: AnyObject {
    
    func tripleView(
        _ view: TripleView,
        didChangeBounds bounds: CGRect
    )
    
    func tripleView(
        _ view: TripleView,
        didChangePresentation presentation: TriplePresentation
    )
    
    func tripleView(
        _view: TripleView,
        heightForCompactMiddleViewWithPositioning positioning: TripleCompactPositioning
    ) -> CGFloat
}

internal final class TripleView: UIView {
    
    struct UserInteractionSession {
        
        let initialOriginalBounds: CGPoint
    }
    
    struct WrapperViewConfiguration {
        
        let pinnedPosition: TripleViewWrapperView.PinnedPosition
        let frame: CGRect
    }
    
    private var userInteractionSession: UserInteractionSession? = nil
    private var animator: UIViewPropertyAnimator? = nil
    private let views: (TripleViewWrapperView, TripleViewWrapperView, TripleViewWrapperView)
    
    private var contentSize: CGSize {
        CGSize(
            width: bounds.width,
            height: bounds.height * 3
        )
    }
    
    private lazy var panGestureRecognizer = TriplePanGestureRecognizer().with({
        $0.maximumNumberOfTouches = 1
        $0.minimumNumberOfTouches = 1
        $0.delegate = self
    })
    
    override var bounds: CGRect {
        get { super.bounds }
        set {
            guard newValue != super.bounds
            else {
                return
            }
            
            super.bounds = newValue
            
            layoutSubviewsWithBounds(
                bounds: newValue
            )
            
            delegate?.tripleView(
                self,
                didChangeBounds: newValue
            )
        }
    }
    
    var presentation: TriplePresentation = .top {
        didSet {
            guard presentation != oldValue
            else {
                return
            }
            
            delegate?.tripleView(
                self,
                didChangePresentation: presentation
            )
        }
    }
    
    weak var delegate: TripleViewDelegate?
    
    init(
        views: (UIView, UIView, UIView)
    ) {
        self.views = (
            TripleViewWrapperView(views.0),
            TripleViewWrapperView(views.1),
            TripleViewWrapperView(views.2)
        )
        
        super.init(frame: .zero)
        
        [self.views.0, self.views.1, self.views.2].forEach({ addSubview($0) })
        bringSubviewToFront(views.1)
        
        addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.addTarget(
            self,
            action: #selector(handlePan(_:))
        )
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard userInteractionSession == nil
        else {
            return
        }
        
        layoutSubviewsWithBounds(
            bounds: bounds
        )
    }
    
    func update(
        presentation: TriplePresentation,
        animated: Bool
    ) {
        if animated {
            setSubviewActive(
                atIndex: presentation.rawValue,
                velocity: .zero
            )
        } else {
            bounds = CGRect(
                origin: CGPoint(
                    x: 0,
                    y: CGFloat(presentation.rawValue) * bounds.height
                ),
                size: bounds.size
            )
        }
    }
    
    // MARK: Actions
    
    @objc
    private func handlePan(_ gestureRecognizer: TriplePanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began, .possible:
            flushDecelerationAnimator()
            userInteractionSession = UserInteractionSession(
                initialOriginalBounds: bounds.origin
            )
        case .changed:
            guard let userInteractionSession = userInteractionSession
            else {
                return
            }
            
            gestureRecognizer.view?.endEditing(true)

            var translation = gestureRecognizer.translation(in: gestureRecognizer.view)
            translation.x = 0
            
            var targetOrigin = userInteractionSession.initialOriginalBounds - translation
            let maximumOrigin = contentSize.height - bounds.height
            
            if targetOrigin.y < 0 {
                targetOrigin.y = -pow(-targetOrigin.y, 0.7)
            } else if targetOrigin.y > maximumOrigin {
                targetOrigin.y = maximumOrigin + pow(targetOrigin.y - maximumOrigin, 0.7)
            }
            
            bounds = CGRect(
                origin: targetOrigin,
                size: bounds.size
            )
        case .cancelled, .failed, .ended:
            guard let userInteractionSession = userInteractionSession
            else {
                return
            }
            
            var translation = gestureRecognizer.translation(in: gestureRecognizer.view)
            translation.x = 0
            
            let targetOrigin = userInteractionSession.initialOriginalBounds - translation
            
            var velocity = gestureRecognizer.velocity(in: gestureRecognizer.view)
            velocity.x = 0
            velocity.y = -velocity.y
            
            var projectionOrigin = gestureRecognizer.project(velocity, onto: targetOrigin)
            projectionOrigin.x = 0
            
            if projectionOrigin.y < 0 {
                projectionOrigin.y = 0
            } else if projectionOrigin.y > contentSize.height - bounds.height {
                projectionOrigin.y = contentSize.height - bounds.height
            }
            
            setSubviewActive(
                atIndex: activeSubviewIndexWithBounds(
                    bounds: CGRect(
                        origin: projectionOrigin,
                        size: bounds.size
                    )
                ),
                velocity: velocity
            )
            
            self.userInteractionSession = nil
        @unknown default:
            break
        }
    }
    
    // MARK: Private
    
    private func flushDecelerationAnimator() {
        animator?.stopAnimation(true)
        animator?.finishAnimation(at: .current)
        
        animator = nil
    }
    
    private func setSubviewActive(
        atIndex index: Int,
        velocity: CGPoint
    ) {
        animator = UIViewPropertyAnimator(
            duration: 0.21,
            timingParameters: UISpringTimingParameters(
                damping: 0.98,
                response: 0.32
            )
        )
        
        animator?.addAnimations({
            self.bounds = CGRect(
                origin: CGPoint(
                    x: 0,
                    y: CGFloat(index) * self.bounds.height
                ),
                size: self.bounds.size
            )
        })
        
        animator?.startAnimation()
    }
    
    func layoutSubviewsWithBounds(
        bounds: CGRect
    ) {
        let configuration = layoutSubviewsConfigurationWithBounds(
            bounds: bounds
        )
        
        views.0.frame = configuration.0.frame
        views.0.pinnedPosition = configuration.0.pinnedPosition
        views.0.layoutIfNeeded()
        
        views.1.frame = configuration.1.frame
        views.1.pinnedPosition = configuration.1.pinnedPosition
        views.1.layoutIfNeeded()
        
        views.2.frame = configuration.2.frame
        views.2.pinnedPosition = configuration.2.pinnedPosition
        views.2.layoutIfNeeded()
        
        let activeSubviewIndex = activeSubviewIndexWithBounds(
            bounds: bounds
        )
        
        switch activeSubviewIndex {
        case 0:
            presentation = .top
        case 1:
            presentation = .middle
        case 2:
            presentation = .bottom
        default:
            fatalError("[TripleView]: Unsupported active subview index")
        }
    }
    
    func activeSubviewIndexWithBounds(
        bounds: CGRect
    ) -> Int {
        let targetActiveSubviewIndex: Int
        let layoutConfiguration = layoutSubviewsConfigurationWithBounds(
            bounds: bounds
        )
        
        if layoutConfiguration.1.frame.height >= bounds.height * 0.6 {
            targetActiveSubviewIndex = 1
        } else if bounds.origin.y < (contentSize.height - bounds.height) / 2 {
            targetActiveSubviewIndex = 0
        } else {
            targetActiveSubviewIndex = 2
        }
        
        return targetActiveSubviewIndex
    }
    
    func layoutSubviewsConfigurationWithBounds(
        bounds: CGRect
    ) -> (WrapperViewConfiguration, WrapperViewConfiguration, WrapperViewConfiguration) {
        let progress: Double = {
            let progress = max(min(bounds.origin.y / (bounds.height * 2), 1), 0)
            return Double(round(1000 * progress) / 1000)
        }()
        
        let minimumY: CGFloat
        let maximumY: CGFloat
        
        let minimumHeight: CGFloat
        let maximumHeight: CGFloat
        
        let hprogress: CGFloat
        
        let centerViewPinnedPosition: TripleViewWrapperView.PinnedPosition
        
        let compactViewHeightIfTop: CGFloat = {
            let height = delegate?.tripleView(_view: self, heightForCompactMiddleViewWithPositioning: .top)
            return (height ?? 0) + safeAreaInsets.bottom
        }()
        
        let compactViewHeightIfBottom: CGFloat = {
            let height = delegate?.tripleView(_view: self, heightForCompactMiddleViewWithPositioning: .bottom)
            return (height ?? 0) + safeAreaInsets.top
        }()
        
        if progress < 0.5 {
            centerViewPinnedPosition = .top(
                size: bounds.size
            )
            
            hprogress = progress * 2
            
            minimumY = bounds.height - compactViewHeightIfTop
            maximumY = bounds.height
            
            minimumHeight = compactViewHeightIfTop
            maximumHeight = bounds.height
        } else {
            centerViewPinnedPosition = .bottom(
                size: bounds.size
            )
            
            hprogress = (progress - 0.5) * 2
            
            minimumY = bounds.height
            maximumY = bounds.height * 2
            
            minimumHeight = bounds.height
            maximumHeight = compactViewHeightIfBottom
        }
        
        let centerViewFrame = CGRect(
            x: 0,
            y: minimumY + (maximumY - minimumY) * hprogress,
            width: bounds.width,
            height: minimumHeight + (maximumHeight - minimumHeight) * hprogress
        )
        
        return (
            WrapperViewConfiguration(
                pinnedPosition: .bottom(
                    size: CGSize(
                        width: bounds.width,
                        height: bounds.height - compactViewHeightIfTop
                    )
                ),
                frame: CGRect(
                    x: 0,
                    y: 0,
                    width: bounds.width,
                    height: bounds.height - compactViewHeightIfTop
                )
            ),
            WrapperViewConfiguration(
                pinnedPosition: centerViewPinnedPosition,
                frame: centerViewFrame
            ),
            WrapperViewConfiguration(
                pinnedPosition: .top(
                    size: CGSize(
                        width: bounds.width,
                        height: bounds.height - compactViewHeightIfBottom
                    )
                ),
                frame: CGRect(
                    x: 0,
                    y: bounds.height * 2 + compactViewHeightIfBottom,
                    width: bounds.width,
                    height: bounds.height - compactViewHeightIfBottom
                )
            )
        )
    }
}

extension TripleView: UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(
        _ gestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if let _ = gestureRecognizer as? UITapGestureRecognizer {
            guard let hitTest = hitTest(gestureRecognizer.location(in: self), with: nil)
            else {
                return true
            }
            
            return !hitTest.isKind(of: UIControl.self)
        }
        
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGestureRecognizer.velocity(in: gestureRecognizer.view)
            return abs(velocity.y) * 1.42 > abs(velocity.x)
        }
        
        return true
    }
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        guard !(gestureRecognizer is UIPanGestureRecognizer)
        else {
            return false
        }
        
        return true
    }
}

private extension CGPoint {
    
    static func + (_ lhs: CGPoint, _ rhs: CGPoint) -> CGPoint {
        CGPoint(
            x: lhs.x + rhs.x,
            y: lhs.y + rhs.y
        )
    }
    
    static func - (_ lhs: CGPoint, _ rhs: CGPoint) -> CGPoint {
        CGPoint(
            x: lhs.x - rhs.x,
            y: lhs.y - rhs.y
        )
    }
    
    static func * (_ lhs: CGPoint, _ rhs: CGFloat) -> CGPoint {
        CGPoint(
            x: lhs.x * rhs,
            y: lhs.y * rhs
        )
    }
}
