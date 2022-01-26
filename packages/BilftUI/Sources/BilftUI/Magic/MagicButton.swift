//
//  Created by Anton Spivak.
//  

import UIKit

public class MagicButton: UIControl {
    
    public enum CornerRadius {
        
        case circle
        case concrette(value: CGFloat)
    }
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    private let label = UILabel()//MagicLabel(effect: .default)
    private let substrateView = UIView()
    private let backgroundView = MagicBackgroundView(effect: .default)
    
    public override var isHighlighted: Bool {
        get { super.isHighlighted }
        set {
            if super.isHighlighted != newValue && newValue {
                feedbackGenerator.impactOccurred()
            }
            
            UIView.animate(
                withDuration: 0.24,
                delay: 0.0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 0.0,
                options: [.beginFromCurrentState, .curveEaseOut],
                animations: {
                    self.transform = newValue ? .highlighted : .default
                },
                completion: nil
            )
            
            super.isHighlighted = newValue
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        backgroundColor = .clear
        layer.masksToBounds = true
        
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.isUserInteractionEnabled = false
        
        substrateView.isUserInteractionEnabled = false
        substrateView.backgroundColor = .oui_backgroundPrimaryInverted
        substrateView.layer.masksToBounds = true
        
        backgroundView.isUserInteractionEnabled = false
        backgroundView.backgroundColor = .clear
        backgroundView.layer.masksToBounds = true
        
        addSubview(backgroundView)
        addSubview(substrateView)
        addSubview(label)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        label.textColor = .oui_textPrimaryInverted
        label.sizeToFit()
        label.center = CGPoint(
            x: bounds.width / 2,
            y: bounds.height / 2 - 1
        )
        
        substrateView.frame = CGRect(
            x: borderWidth,
            y: borderWidth,
            width: bounds.width - borderWidth * 2,
            height: bounds.height - borderWidth * 2
        )
        
        backgroundView.frame = bounds
        
        switch cornerRadius {
        case .circle:
            backgroundView.layer.cornerRadius = backgroundView.bounds.height / 2
            substrateView.layer.cornerRadius = substrateView.bounds.height / 2
        case let .concrette(value):
            backgroundView.layer.cornerRadius = value
            substrateView.layer.cornerRadius = max(value - 1, 0)
        }
        
        backgroundView.layer.cornerCurve = cornerRadius.cornerCurve
        substrateView.layer.cornerCurve = cornerRadius.cornerCurve
    }
    
    // MARK: API
    
    open var effect: UIVisualEffect? = nil {
        didSet {
//            label.effect = effect
            backgroundView.effect = effect
        }
    }
    
    open var cornerRadius: CornerRadius = .concrette(value: 12) {
        didSet {
            setNeedsLayout()
        }
    }
    
    open var borderWidth: CGFloat = 3 {
        didSet {
            setNeedsLayout()
        }
    }
    
    open func setTitle(_ title: String) {
        label.text = title
        setNeedsLayout()
    }
}

fileprivate extension MagicButton.CornerRadius {
    
    var cornerCurve: CALayerCornerCurve {
        switch self {
        case .circle:
            return .circular
        case .concrette:
            return .continuous
        }
    }
}

fileprivate extension CGAffineTransform {
    
    static let `default`: CGAffineTransform = .identity
    static let highlighted: CGAffineTransform = .identity.scaledBy(x: 0.92, y: 0.92)
}

fileprivate extension UIVisualEffect {
    
    static let `default`: UIVisualEffect? = nil
}
