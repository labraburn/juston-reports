//
//  Created by Anton Spivak.
//  

import UIKit

open class LevelViewController: UIViewController {
    
    private var transitionView: TransitionView { view as! TransitionView }
    
    open override var childForStatusBarStyle: UIViewController? { viewControllers.last }
    open override var childForHomeIndicatorAutoHidden: UIViewController? { viewControllers.last }
    open override var childForStatusBarHidden: UIViewController? { viewControllers.last }
    open override var childViewControllerForPointerLock: UIViewController? { viewControllers.last }
    open override var childForScreenEdgesDeferringSystemGestures: UIViewController? { viewControllers.last }
    
    public private(set) var viewControllers: [UIViewController] = []
    
    open override func loadView() {
        view = TransitionView()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateAppearance(animated: animated)
    }
}

extension LevelViewController {
    
    public struct Level: RawRepresentable {
        
        public static let application = Level(rawValue: 0)
        public static let error = Level(rawValue: 999)
        
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    public final class TransitionContext {
        
        public let fromViewController: UIViewController?
        public let toViewController: UIViewController?
        public let containerView: UIView

        public let transitionDuration: TimeInterval
        public let transitionDidFinish: () -> Void

        fileprivate init(
            fromViewController: UIViewController?,
            toViewController: UIViewController?,
            containerView: UIView,
            transitionDuration: TimeInterval,
            transitionDidFinish: @escaping () -> Void
        ) {
            self.fromViewController = fromViewController
            self.toViewController = toViewController
            self.containerView = containerView
            self.transitionDuration = transitionDuration
            self.transitionDidFinish = transitionDidFinish
        }
    }

    public final class Transition {
        
        public let animationDuration: TimeInterval
        public let animationDeclaration: (_ context: TransitionContext) -> Void
        
        public init(animationDuration: TimeInterval, animationDeclaration: @escaping (_ context: TransitionContext) -> Void) {
            self.animationDuration = animationDuration
            self.animationDeclaration = animationDeclaration
        }
    }

    ///
    /// If some view controller currently presented at given level, it will be exhchanged with `viewControllerToPresent`
    ///
    /// - Parameter viewControllerToPresent: a viewController than will be presented
    /// - Parameter animated: should animation be used
    /// - Parameter level: future position of viewController in view hierarhy
    /// - Parameter completion: called when animation did finish
    ///
    /// - Warning: If some view controller currently presented at given level,
    /// it will be exhchanged with `viewControllerToPresent`
    ///
    public final func exchange(_ viewControllerToPresent: UIViewController?, at level: Level, animated: Bool, completion: (() -> Void)? = nil) {
        let transition = Transition(animationDuration: 0.21, animationDeclaration: { context in
            context.toViewController?.loadViewIfNeeded()
            context.toViewController?.view.alpha = 0

            if let viewControllerToPresent = context.toViewController {
                context.containerView.addSubview(viewControllerToPresent.view)
                viewControllerToPresent.view.frame = context.containerView.bounds
            }
            
            if animated {
                UIView.animate(
                    withDuration: context.transitionDuration,
                    delay: 0.0,
                    options: [.curveEaseInOut],
                    animations: {
                        context.fromViewController?.view.alpha = 0
                        context.toViewController?.view.alpha = 1
                    }, completion: { _ in
                        context.fromViewController?.view.removeFromSuperview()

                        context.transitionDidFinish()
                        completion?()
                    }
                )
            } else {
                context.fromViewController?.view.removeFromSuperview()
                context.toViewController?.view.alpha = 1

                context.transitionDidFinish()
                completion?()
            }
        })
        
        exchange(viewControllerToPresent, at: level, animated: animated, with: transition)
    }

    ///
    /// If some view controller currently presented at given level, it will be exhchanged with `viewControllerToPresent`
    ///
    /// - Parameter viewControllerToPresent: a viewController than will be presented
    /// - Parameter animated: should animation be used
    /// - Parameter level: future position of viewController in view hierarhy
    /// - Parameter transition: custom transition for transition
    ///
    /// - Warning: If some view controller currently presented at given level,
    ///  it will be exhchanged with `viewControllerToPresent`
    ///
    public final func exchange(_ viewControllerToPresent: UIViewController?, at level: Level, animated: Bool, with transition: Transition) {
        var calculatedLevel = level.rawValue
        if viewControllers.isEmpty {
            calculatedLevel = 0
        } else if viewControllers.count < level.rawValue {
            calculatedLevel = viewControllers.count
        }
        
        viewControllerToPresent?.definesPresentationContext = true

        let previousViewController = viewControllers.count > calculatedLevel ? viewControllers[calculatedLevel] : nil
        previousViewController?.willMove(toParent: nil)
        
        if previousViewController != nil {
            viewControllers.remove(at: calculatedLevel)
        }
        
        updateAppearance(animated: animated, duration: transition.animationDuration)
        
        if let viewControllerToPresent = viewControllerToPresent {
            viewControllers.insert(viewControllerToPresent, at: calculatedLevel)
            addChild(viewControllerToPresent)
        }
        
        let containerView = transitionView.containerView(for: calculatedLevel)
        containerView.setLockedWhileTransitionInprogress(true)
        
        let finishTransitionBlock = { [weak self] in
            guard let self = self
            else {
                return
            }

            previousViewController?.view.removeFromSuperview()
            previousViewController?.removeFromParent()

            viewControllerToPresent?.didMove(toParent: self)

            self.updateAppearance(animated: true)
            self.transitionView.removeContainerViewsIfNeccessary()

            containerView.setLockedWhileTransitionInprogress(false)
        }

        let context = TransitionContext(
            fromViewController: previousViewController,
            toViewController: viewControllerToPresent,
            containerView: transitionView.containerView(for: calculatedLevel),
            transitionDuration: transition.animationDuration,
            transitionDidFinish: finishTransitionBlock
        )

        transition.animationDeclaration(context)
    }

    private func updateAppearance(animated: Bool, duration: TimeInterval = 0.21) {
        let animations = {
            self.setNeedsStatusBarAppearanceUpdate()
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
            self.setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
            if #available(iOS 14.0, *) {
                self.setNeedsUpdateOfPrefersPointerLocked()
            }
        }
        
        if animated {
            UIView.animate(withDuration: duration, animations: animations)
        } else {
            animations()
        }
    }
}

///
/// View that maintain view hierarhy for transitions
/// Each leveled viewController contained in it's own ContainerView
/// When level transition did start it's run in ContainerView
///
private class TransitionView: UIView {
    
    class ContainerView: UIView {
    
        private var isLocked = false

        override func layoutSubviews() {
            super.layoutSubviews()
         
            guard !isLocked
            else {
                return
            }

            subviews.forEach { $0.frame = bounds }
        }

        func setLockedWhileTransitionInprogress(_ flag: Bool) {
            isLocked = flag
        }

        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            let view = super.hitTest(point, with: event)
            return view == self ? nil : view
        }
    }

    private let substrateView = UIView()
    private(set) var containerViews: [ContainerView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        substrateView.backgroundColor = .clear
        addSubview(substrateView)
    }
    
    func containerView(for level: Int) -> ContainerView {
        var calculatedLevel = level
        if containerViews.isEmpty {
            calculatedLevel = 0
        } else if containerViews.count < level {
            calculatedLevel = containerViews.count
        }

        let result: ContainerView
        if containerViews.count > calculatedLevel {
            result = containerViews[calculatedLevel]
        } else {
            let containerView = ContainerView()
            containerView.frame = bounds
            
            substrateView.insertSubview(containerView, at: level)
            containerViews.insert(containerView, at: level)
            
            result = containerView
        }

        return result
    }

    func removeContainerViewsIfNeccessary() {
        containerViews.filter(\.subviews.isEmpty).forEach {
            $0.removeFromSuperview()
            guard let index = containerViews.firstIndex(of: $0)
            else {
                fatalError("Can't locate container view to remove.")
            }
            containerViews.remove(at: index)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        substrateView.frame = bounds
        containerViews.forEach { $0.frame = bounds }
    }
}
