//
//  Created by Anton Spivak
//

import UIKit
import DeclarativeUI

public class BorderedTextView: UIView {
    
    public struct Action {
        
        public let image: UIImage
        public let block: () -> ()
        
        public init(
            image: UIImage,
            block: @escaping () -> ()
        ) {
            self.image = image
            self.block = block
        }
    }
    
    private let captionLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        $0.textAlignment = .left
        $0.textColor = UIColor(rgb: 0xA6A0BB)
        $0.numberOfLines = 0
        $0.setContentCompressionResistancePriority(.required + 1, for: .vertical)
    })
    
    private let borderView = GradientBorderedView(colors: [UIColor(rgb: 0x85FFC4), UIColor(rgb: 0xBC85FF)]).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.cornerRadius = 12
    })
    
    public let textView = SelfSizingTextView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .monospacedSystemFont(ofSize: 14, weight: .medium)
        $0.textColor = .white
        $0.textContainerInset = .zero
        $0.backgroundColor = .clear
        $0.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
        $0.setContentCompressionResistancePriority(.required + 1, for: .vertical)
    })
    
    private let actionsStackView = UIStackView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.distribution = .equalCentering
        $0.alignment = .top
    })
    
    private var textViewRightConstraint: NSLayoutConstraint? = nil
    private var captionLabelRightConstraint: NSLayoutConstraint? = nil
    
    public var caption: String = "" {
        didSet {
            captionLabel.text = caption
        }
    }
    
    public var actions: [Action] = [] {
        didSet {
            if actions.isEmpty {
                actionsStackView.removeFromSuperview()
                textViewRightConstraint?.constant = 10
                captionLabelRightConstraint?.constant = 16
            } else if actionsStackView.superview == nil {
                addSubview(actionsStackView)
                NSLayoutConstraint.activate({
                    actionsStackView.topAnchor.pin(to: topAnchor, constant: 14)
                    rightAnchor.pin(to: actionsStackView.rightAnchor, constant: 16)
                })
                textViewRightConstraint?.constant = 48
                captionLabelRightConstraint?.constant = 52
            } else {
                textViewRightConstraint?.constant = 48
                captionLabelRightConstraint?.constant = 52
            }
            
            actionsStackView.arrangedSubviews.forEach({
                $0.removeFromSuperview()
            })
            
            setNeedsLayout()
            actions.forEach({ action in
                let button = ActionButton()
                button.widthAnchor.pin(to: 24).isActive = true
                button.heightAnchor.pin(to: 24).isActive = true
                button.tintColor = .jus_textPrimary
                button.setImage(action.image, for: .normal)
                button.action = action.block
                button.addTarget(self, action: #selector(actionButtonDidClick(_:)), for: .touchUpInside)
                actionsStackView.addArrangedSubview(button)
            })
        }
    }
    
    public var containerViewAnchor: UIView? {
        get { textView.layoutContainerView }
        set { textView.layoutContainerView = newValue }
    }
    
    public init(caption: String) {
        super.init(frame: .zero)
        captionLabel.text = caption
        _init()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }
    
    private func _init() {
        layer.cornerRadius = 12
        layer.cornerCurve = .continuous
        layer.masksToBounds = true
        
        backgroundColor = UIColor(rgb: 0x1C1924)
        
        setContentHuggingPriority(.defaultLow - 1, for: .vertical)
        setContentCompressionResistancePriority(.required + 1, for: .vertical)
        
        addSubview(borderView)
        addSubview(captionLabel)
        addSubview(textView)
        
        let textViewRightConstraint = rightAnchor.constraint(equalTo: textView.rightAnchor, constant: 10)
        let captionLabelRightConstraint = rightAnchor.constraint(equalTo: captionLabel.rightAnchor, constant: 16)
        
        NSLayoutConstraint.activate({
            borderView.pin(edges: self)
            
            captionLabel.topAnchor.pin(to: topAnchor, constant: 12)
            captionLabel.leftAnchor.pin(to: leftAnchor, constant: 16)
            captionLabelRightConstraint
            captionLabel.heightAnchor.pin(greaterThan: 16)

            textView.topAnchor.pin(to: captionLabel.bottomAnchor, constant: 4)
            textView.leftAnchor.pin(to: leftAnchor, constant: 10)
            textViewRightConstraint
            textView.heightAnchor.pin(greaterThan: 17)
            bottomAnchor.pin(to: textView.bottomAnchor, constant: 12)
        })
        
        self.textViewRightConstraint = textViewRightConstraint
        self.captionLabelRightConstraint = captionLabelRightConstraint
        
        setFocused(false, animated: false)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if borderView.superview == nil {
            addSubview(borderView)
            borderView.pinned(edges: self)
        }
        
        sendSubviewToBack(borderView)
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitTest = super.hitTest(point, with: event)
        if let hitTest = hitTest {
            if hitTest.isDescendant(of: actionsStackView) {
                return hitTest
            } else if hitTest.isDescendant(of: self) || hitTest == self {
                return textView
            } else {
                return hitTest
            }
        }
        return hitTest
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        guard containerViewAnchor == nil || containerViewAnchor == superview
        else {
            return
        }
        
        textView.layoutContainerView = superview
    }
    
    // MARK: API
    
    public func setFocused(_ flag: Bool, animated: Bool = true) {
        let changes = {
            self.borderView.gradientColors = flag ? [UIColor(rgb: 0x85FFC4), UIColor(rgb: 0xBC85FF)] : [.jus_textSecondary, .jus_textSecondary]
            self.borderView.gradientAngle = flag ? 12 : 68
        }
        
        if animated {
            UIView.animate(
                withDuration: 0.21,
                delay: 0,
                options: [.beginFromCurrentState],
                animations: changes,
                completion: nil
            )
        } else {
            changes()
        }
    }
    
    // MARK: Actions
    
    @objc
    private func actionButtonDidClick(_ sender: ActionButton) {
        sender.action?()
    }
}

private final class ActionButton: UIButton {
    
    var action: (() -> ())?
}
