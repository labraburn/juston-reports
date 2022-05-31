//
//  Created by Anton Spivak
//

import UIKit
import DeclarativeUI

public class BorderedTextView: UIView {
    
    private let captionLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        $0.textAlignment = .left
        $0.textColor = UIColor(rgb: 0xA6A0BB)
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
    
    public var caption: String = "" {
        didSet {
            captionLabel.text = caption
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
        
        NSLayoutConstraint.activate({
            borderView.pin(edges: self)
            
            captionLabel.topAnchor.pin(to: topAnchor, constant: 12)
            captionLabel.pin(horizontally: self, left: 16, right: 16)
            captionLabel.heightAnchor.pin(to: 16)

            textView.topAnchor.pin(to: captionLabel.bottomAnchor, constant: 4)
            textView.pin(horizontally: self, left: 10, right: 10)
            textView.heightAnchor.pin(greaterThan: 17)
            bottomAnchor.pin(to: textView.bottomAnchor, constant: 12)
        })
        
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
            return hitTest.isDescendant(of: self) || hitTest == self ? textView : hitTest
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
            self.borderView.gradientColors = flag ? [UIColor(rgb: 0x85FFC4), UIColor(rgb: 0xBC85FF)] : [.hui_textSecondary, .hui_textSecondary]
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
}
