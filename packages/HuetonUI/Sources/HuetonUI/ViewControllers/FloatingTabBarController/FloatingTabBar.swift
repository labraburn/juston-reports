//
//  Created by Anton Spivak
//

import UIKit

public final class FloatingTabBar: UITabBar {

    private let containerView = FloatingTabBarContainerView()
    private var cachedLayoutSize = CGSize.zero

    private let gradientView = GradientView(colors: [.clear, UIColor(rgb: 0x10080E)], angle: 315)
    private var isFloatingHidden: Bool = false

    public override var backgroundImage: UIImage? {
        set { super.backgroundImage = newValue }
        get { super.backgroundImage }
    }

    public override var selectedItem: UITabBarItem? {
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

    public override func layoutSubviews() {
        if gradientView.superview == nil {
            addSubview(gradientView)
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

        layoutContainerViews()
    }
    
    private func layoutContainerViews() {
        let containerViewSize = containerView.sizeWithItems(items ?? [])
        let offset = isFloatingHidden ? bounds.height : 0
        let containerViewFrame = CGRect(
            x: (bounds.width - containerViewSize.width) / 2,
            y: 12 + offset,
            width: containerViewSize.width,
            height: containerViewSize.height
        )

        containerView.frame = containerViewFrame
        containerView.layoutItemsIfNeeded(items ?? [])

        gradientView.locations = [0, 0.8]
        gradientView.frame = CGRect(x: 0, y: -12, width: bounds.width, height: bounds.height + 12)
    }
    
    public func setFloatingHidden(_ flag: Bool, animated: Bool) {
        isFloatingHidden = flag
        let animations = {
            self.layoutContainerViews()
        }
        
        if animated {
            UIView.animate(
                withDuration: 0.32,
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0,
                options: [.beginFromCurrentState, .curveEaseOut, .allowUserInteraction],
                animations: animations,
                completion: { _ in }
            )
        } else {
            animations()
        }
    }

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
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

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
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
