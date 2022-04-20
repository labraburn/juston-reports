//
//  Created by Anton Spivak
//

import UIKit

internal final class FloatingTabBar: UITabBar {
    
    private let containerView = FloatingTabBarContainerView()
    private var cachedLayoutSize = CGSize.zero
    
    private let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(radius: 6, scale: 0.5))
    private let visualEffectViewMaskView = GradientView()
    
    override var backgroundImage: UIImage? {
        set { super.backgroundImage = newValue }
        get { super.backgroundImage }
    }

    override var selectedItem: UITabBarItem? {
        get {
            super.selectedItem
        }
        set {
            super.selectedItem = newValue

            var selectedIndex = -1
            if let selectedItem = newValue, let index = items?.firstIndex(of: selectedItem) {
                selectedIndex = index
            }

            containerView.selectedIndex = selectedIndex
        }
    }

    override func layoutSubviews() {
        if visualEffectView.superview == nil {
            addSubview(visualEffectView)
        }
        
        if containerView.superview == nil {
            containerView.delegate = self
            addSubview(containerView)
        }
        
        super.layoutSubviews()
        systemButtons().forEach({
            $0.isHidden = true
        })
        
        guard cachedLayoutSize != bounds.size || containerView.buttons.count != items?.count
        else {
            return
        }
        
        shadowImage = UIImage()
        cachedLayoutSize = bounds.size
        
        let containerViewSize = containerView.sizeWithItems(items ?? [])
        let containerViewFrame = CGRect(
            x: (bounds.width - containerViewSize.width) / 2,
            y: 12,
            width: containerViewSize.width,
            height: containerViewSize.height
        )
        
        containerView.frame = containerViewFrame
        containerView.layoutItemsIfNeeded(items ?? [])
        
        visualEffectViewMaskView.frame = bounds
        visualEffectViewMaskView.colors = [.clear, .black]
        visualEffectViewMaskView.angle = 0
        visualEffectViewMaskView.locations = [0, 0.3, 1]
        
        visualEffectView.frame = bounds
        visualEffectView.mask = visualEffectViewMaskView
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitTest = super.hitTest(point, with: event),
              (hitTest.isDescendant(of: containerView) || hitTest == containerView)
        else {
            return nil
        }
        return hitTest
    }

    private func systemButtons() -> [UIView] {
        subviews.filter { String(describing: $0.self).contains("TabBarButton") }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        let safeAreaInsets = superview?.safeAreaInsets ?? .zero
        let containerViewSize = containerView.sizeWithItems(items ?? [])
        sizeThatFits.height = containerViewSize.height + 18 + safeAreaInsets.bottom
        return sizeThatFits
    }
}

extension FloatingTabBar: FloatingTabBarContainerViewDelegate {
    
    func floatingTabBarContainerView(
        _ view: FloatingTabBarContainerView,
        didSelectItemAtIndex index: Int
    ) {
        perform(
            NSSelectorFromString("_buttonUp:"),
            with: systemButtons()[index]
        )
    }
}
