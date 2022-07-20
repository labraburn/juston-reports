//
//  FloatingTabBarContainerView.swift
//  
//
//  Created by Anton Spivak on 19.04.2022.
//

import UIKit

internal protocol FloatingTabBarContainerViewDelegate: AnyObject {
    
    func floatingTabBarContainerView(
        _ view: FloatingTabBarContainerView,
        didSelectItemAtIndex index: Int
    )
}

internal final class FloatingTabBarContainerView: UIView {
    
    private let buttonSize: CGSize = CGSize.init(width: 56, height: 56)
    private let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
    
    weak var delegate: FloatingTabBarContainerViewDelegate?
    
    var buttons: [FloatingTabBarItemButton] {
        subviews.compactMap({ $0 as? FloatingTabBarItemButton })
    }
    
    var selectedIndex: Int = -1 {
        didSet {
            buttons.forEach { view in
                view.isHighlighted = false
                view.isSelected = view.tag == selectedIndex
            }
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        clipsToBounds = true
        backgroundColor = .clear
        
        addSubview(visualEffectView)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        visualEffectView.frame = bounds
        
        layer.cornerRadius = min(UIScreen.main.displayCornerRadius, bounds.height / 2)
        layer.cornerCurve = .continuous
        layer.borderColor = UIColor(rgb: 0x353535).cgColor
        layer.borderWidth = 1
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        highlightIfNeeded(withTouches: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        highlightIfNeeded(withTouches: touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        highlightIfNeeded(withTouches: touches)

        guard let touch = touches.first
        else {
            return
        }

        let location = touch.location(in: self)
        let hit = buttons.first(where: { view in
            view.frame.contains(location)
        })

        guard let view = hit
        else {
            return
        }
        
        delegate?.floatingTabBarContainerView(
            self,
            didSelectItemAtIndex: view.tag
        )
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        highlightIfNeeded(withTouches: touches)
    }
    
    private func highlightIfNeeded(withTouches touches: Set<UITouch>) {
        guard let touch = touches.first
        else {
            buttons.forEach({ $0.isHighlighted = false })
            return
        }

        let location = touch.location(in: self)
        buttons.forEach({
            $0.isHighlighted = $0.frame.contains(location)
        })
    }
    
    // MARK: Internal API
    
    func sizeWithItems(_ items: [UITabBarItem]) -> CGSize {
        CGSize(
            width: buttonSize.width * CGFloat(items.count) + 24,
            height: buttonSize.height
        )
    }
    
    func layoutItemsIfNeeded(_ items: [UITabBarItem]) {
        buttons.forEach({ $0.removeFromSuperview() })
        
        var index = 0
        items.compactMap({ $0 as? FloatingTabBarItem }).forEach({ item in
            let button = FloatingTabBarItemButton()
            button.view = {
                let view = UIButton(type: .custom)
                view.setImage(item.image, for: .normal)
                return view
            }()
            button.selectedTintColor = item.selectedTintColor
            button.deselectedTintColor = item.deselectedTintColor
            button.isSelected = selectedIndex == index
            button.tag = index
            button.isUserInteractionEnabled = false
            button.accessibilityLabel = item.accessibilityLabel
            button.accessibilityValue = item.badgeValue
            button.accessibilityIdentifier = item.accessibilityIdentifier
            addSubview(button)
            
            UIView.performWithoutAnimation({
                button.frame = CGRect(origin: .zero, size: buttonSize)
                button.center = CGPoint(
                    x: 12 + buttonSize.width / 2 + buttonSize.width * CGFloat(index),
                    y: buttonSize.height / 2
                )
            })
            
            index += 1
        })
    }
}
