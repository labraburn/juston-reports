//
//  DashboardStackView.swift
//  iOS
//
//  Created by Anton Spivak on 12.03.2022.
//

import UIKit
import BilftUI

protocol DashboardStackViewDelegate: AnyObject {
    
    func dashboardStackView(
        _ view: DashboardStackView,
        didChangeSelectedModel model: DashboardStackView.Model
    )
}

final class DashboardStackView: UIView {
    
    struct Model {
        
        struct Style {
            
            let textColorPrimary: UIColor
            let textColorSecondary: UIColor
            let borderColor: UIColor
            
            let backgroundImage: UIImage?
            let backgroundColor: UIColor
        }
        
        let name: String
        let address: String
        
        let balanceBeforeDot: String
        let balanceAfterDot: String
        
        let style: Style
    }
    
    enum Presentation {
        
        case large
        case compact
    }
    
    private struct UserInteractionSession {
        
        let viewInitialCenter: CGPoint
    }
    
    private var didInitialized: Bool = false
    private var userInteractionSession: UserInteractionSession? = nil
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    private var containerView: UIView = UIView().with({
        $0.backgroundColor = .clear
    })
    
    private var containerViewSubviews: [DashboardStackCardView] {
        containerView.subviews.compactMap({ $0 as? DashboardStackCardView })
    }
    
    private var isUserInteracting: Bool {
        userInteractionSession != nil
    }
    
    var cornerRadius: CGFloat = 0 {
        didSet {
            containerViewSubviews.forEach({ $0.cornerRadius = cornerRadius })
        }
    }
    
    var presentation: Presentation = .large {
        didSet {
            foregroundAnimator.removeAllBehaviors()
            backgroundAnimator.removeAllBehaviors()
            setNeedsLayout()
        }
    }
    
    private(set) var data: [Model] = []
    private(set) var selected: Model? = nil {
        didSet {
            guard let selected = selected
            else {
                return
            }
            
            feedbackGenerator.impactOccurred()
            delegate?.dashboardStackView(self, didChangeSelectedModel: selected)
        }
    }
    
    private lazy var backgroundAnimator: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: containerView)
        return animator
    }()
    
    private lazy var foregroundAnimator: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: containerView)
        return animator
    }()
    
    weak var delegate: DashboardStackViewDelegate?
    
    init() {
        super.init(frame: .zero)
        
        clipsToBounds = false
        backgroundColor = .bui_backgroundPrimary
        
        addSubview(containerView)
        
        let panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.addTarget(self, action: #selector(gestureRecongnizerDidUpdate(_:)))
        panGestureRecognizer.delegate = self
        panGestureRecognizer.delaysTouchesBegan = false
        panGestureRecognizer.delaysTouchesEnded = false
        addGestureRecognizer(panGestureRecognizer)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard !isUserInteracting
        else {
            return
        }
        
        containerView.frame = bounds
        
        var index = 0
        containerViewSubviews.reversed().forEach({ view in
            view.bounds = containerSubviewViewBounds(at: index)
            view.center = containerSubviewViewPosition(at: index)
            if window != nil {
                view.layoutIfNeeded()
            }
            index += 1
        })
        
        layoutContainerViewSubviews(
            excludePositiongOfView: nil,
            animated: true
        )
    }
    
    func update(data: [Model], selected: Model? = nil, animated: Bool) {
        guard !isUserInteracting
        else {
            return
        }
        
        var updated = data.sorted(by: { $0.name > $1.name })
        let _selected = selected ?? self.selected
        
        if let _selected = _selected, let index = updated.firstIndex(of: _selected) {
            updated = Array(updated[index ..< updated.count]) + Array(updated[0 ..< index])
        }
        
        if self.selected == nil {
            self.selected = updated.first
        }
        
        self.data = updated
        reloadData(animated)
    }
    
    private func reloadData(_ animated: Bool) {
        containerViewSubviews.forEach({ $0.removeFromSuperview() })
        
        var index = 0
        data.reversed().forEach({ model in
            let view = DashboardStackCardView(model: model)
            view.bounds = containerSubviewViewBounds(at: index)
            view.center = containerSubviewViewPosition(at: index)
            view.cornerRadius = cornerRadius
            
            if window != nil {
                view.layoutIfNeeded()
            }
            
            containerView.addSubview(view)
            index += 1
        })
        
        layoutContainerViewSubviews(
            excludePositiongOfView: nil,
            animated: true
        )
    }
    
    private func layoutContainerViewSubviews(excludePositiongOfView: UIView? = nil, animated: Bool) {
        // If all in initial state
        let shouldSpeedUpDuration = containerViewSubviews.filter({ $0.state != .hidden }).count == containerViewSubviews.count
        
        var index = 0
        containerViewSubviews.reversed().forEach({ view in
            let animations = {
                view.bounds = self.containerSubviewViewBounds(at: index)
                if view != excludePositiongOfView {
                    view.center = self.containerSubviewViewPosition(at: index)
                }
                view.alpha = max(1 - 0.36 * CGFloat(index), 0)
                view.isHidden = view.alpha == 0
                view.transform = .identity
                view.update(
                    state: index == 0 ? self.presentation.cardViewState : .hidden,
                    animated: true
                )
            }
            
            if animated && !shouldSpeedUpDuration {
                UIView.performWithDefaultAnimation(
                    duration: index == 0 ? 0.86 : 0.42,
                    block: animations
                )
            } else {
                animations()
            }
            
            index += 1
        })
    }
    
    private func containerSubviewViewPosition(at index: Int) -> CGPoint {
        let bounds = containerSubviewViewBounds(at: index)
        return CGPoint(
            x: bounds.midX + (self.bounds.width - bounds.width) / 2,
            y: bounds.midY + CGFloat(index) * -2 - (self.bounds.height - bounds.height) / 2
        )
    }
    
    private func containerSubviewViewBounds(at index: Int) -> CGRect {
        let offset = CGFloat(index) * 6
        return CGRect(
            x: 0,
            y: 0,
            width: max(bounds.width - offset, 90), // minimum size for constraints errors
            height: max(bounds.height - offset, 90) // minimum size for constraints errors
        )
    }
    
    private func popLastAndLayoutContainerViewSubviews(velocity: CGPoint) {
        backgroundAnimator.removeAllBehaviors()
        
        guard let card = containerViewSubviews.last
        else {
            return
        }
        
        let snapBehaviour = UISnapBehavior(
            item: card,
            snapTo: containerSubviewViewPosition(at: containerViewSubviews.count - 1)
        )
        
        let itemBehaviour = UIDynamicItemBehavior(items: [card])
        itemBehaviour.addLinearVelocity(velocity, for: card)
        
        backgroundAnimator.addBehavior(snapBehaviour)
        backgroundAnimator.addBehavior(itemBehaviour)
        
        let popped = data[0]
        
        data = Array(data[1 ..< data.count]) + [popped]
        selected = data.first
        
        containerView.sendSubviewToBack(card)
        
        layoutContainerViewSubviews(
            excludePositiongOfView: card,
            animated: true
        )
    }
    
    private func returnLastToTop(velocity: CGPoint) {
        guard let card = containerViewSubviews.last
        else {
            return
        }
        
        let itemBehaviour = UIDynamicItemBehavior(items: [card])
        itemBehaviour.addLinearVelocity(velocity, for: card)
        
        let snapBehaviour = UISnapBehavior(
            item: card,
            snapTo: containerSubviewViewPosition(at: 0)
        )
        
        foregroundAnimator.addBehavior(snapBehaviour)
        foregroundAnimator.addBehavior(itemBehaviour)
        
        feedbackGenerator.impactOccurred(intensity: 0.42)
    }
    
    private func removeAllDynamicAnimations() {
        foregroundAnimator.removeAllBehaviors()
    }
    
    @objc
    private func gestureRecongnizerDidUpdate(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let card = containerViewSubviews.last
        else {
            return
        }
        
        switch gestureRecognizer.state {
        case .began, .possible:
            removeAllDynamicAnimations()
            userInteractionSession = UserInteractionSession(
                viewInitialCenter: CGPoint(x: bounds.midX, y: bounds.midY)
            )
        case .changed:
            guard let userInteractionSession = userInteractionSession
            else {
                return
            }

            let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
            card.center = CGPoint(
                x: userInteractionSession.viewInitialCenter.x + translation.x,
                y: userInteractionSession.viewInitialCenter.y + translation.y
            )
        case .cancelled, .failed, .ended:
            guard let userInteractionSession = userInteractionSession
            else {
                return
            }
            
            self.userInteractionSession = nil
            
            let viewInitialCenter = userInteractionSession.viewInitialCenter
            
            let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
            let projection = gestureRecognizer.projection(from: viewInitialCenter)
            let velocity = gestureRecognizer.velocity(in: gestureRecognizer.view)
            
            if (projection.x < -700 && translation.x < 0) ||
                (projection.x > 700 && translation.x > 0) ||
                (translation.x > bounds.width / 3 * 1.7 && velocity.x > 42) ||
                (translation.x < -bounds.width / 3 * 1.7 && velocity.x < -42)
            {
                popLastAndLayoutContainerViewSubviews(velocity: velocity)
            } else {
                returnLastToTop(velocity: velocity)
            }
        @unknown default:
            break
        }
    }
}

extension DashboardStackView.Model: Hashable {}
extension DashboardStackView.Model.Style: Hashable {}

extension DashboardStackView: UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer
        else {
            return true
        }
        
        let velocity = panGestureRecognizer.velocity(in: gestureRecognizer.view)
        return abs(velocity.x) * 1.42 > abs(velocity.y)
    }
}



// Inspired via
// https://github.com/jenox/UIKit-Playground/tree/master/02-Gestures-In-Fluid-Interfaces/
extension UIPanGestureRecognizer {
    
    func projection(from currentPosition: CGPoint) -> CGPoint {
        var _velocity = velocity(in: view)
        
        if _velocity.x != 0 || _velocity.y != 0 {
            let max = max(abs(_velocity.x), abs(_velocity.y))
            _velocity.x *= abs(_velocity.x / max)
            _velocity.y *= abs(_velocity.y / max)
        }

        return project(_velocity, onto: currentPosition)
    }
    
    func project(
        _ velocity: CGPoint,
        onto position: CGPoint,
        decelerationRate: UIScrollView.DecelerationRate = .normal
    ) -> CGPoint {
        let factor = -1 / (1000 * log(decelerationRate.rawValue))
        return CGPoint(
            x: position.x + factor * velocity.x,
            y: position.y + factor * velocity.y
        )
    }
}

private extension UIView {
    
    static func performWithDefaultAnimation(
        duration: TimeInterval = 0.21,
        block: @escaping () -> (),
        completion: (() -> ())? = nil)
    {
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0,
            options: [.beginFromCurrentState, .curveEaseOut, .allowUserInteraction],
            animations: block,
            completion: { _ in
                completion?()
            }
        )
    }
}

private extension DashboardStackView.Presentation {
    
    var cardViewState: DashboardStackCardView.State {
        switch self {
        case .large:
            return .large
        case .compact:
            return .compact
        }
    }
}
