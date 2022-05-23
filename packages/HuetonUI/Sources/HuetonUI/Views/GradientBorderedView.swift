//
//  Created by Anton Spivak.
//

import UIKit

public class GradientBorderedView: UIView {
    
    private var _bounds = CGRect.zero
    
    private let _gradientView: GradientView
    private let _maskingView: UIView = .init()
    
    public var borderWidth: CGFloat = 1 {
        didSet {
            setNeedsBorderLayout()
        }
    }
    
    public var cornerRadius: CGFloat = 12 {
        didSet {
            setNeedsBorderLayout()
        }
    }
    
    public var gradientColors: [UIColor] {
        set { _gradientView.colors = newValue }
        get { _gradientView.colors }
    }
    
    public var gradientAngle: Double {
        set { _gradientView.angle = newValue }
        get { _gradientView.angle }
    }
    
    init(colors: [UIColor]) {
        _gradientView = GradientView(colors: colors, angle: 45)
        super.init(frame: .zero)
        _init()
    }
    
    required init?(coder: NSCoder) {
        _gradientView = GradientView(colors: [.cyan, .magenta], angle: 45)
        super.init(coder: coder)
        _init()
    }
    
    private func _init() {
        _maskingView.layer.backgroundColor = UIColor.clear.cgColor
        _maskingView.layer.borderColor = UIColor.red.cgColor
        _maskingView.layer.borderWidth = borderWidth
        
        addSubview(_gradientView)
        _gradientView.mask = _maskingView
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        guard _bounds != bounds
        else {
            return
        }

        _bounds = bounds
        
        _gradientView.frame = bounds
        _maskingView.frame = CGRect(
            x: 0,
            y: 0,
            width: bounds.width - borderWidth * 2,
            height: bounds.height - borderWidth * 2
        )
        
        _maskingView.layer.shadowPath = path()
        _maskingView.layer.cornerRadius = cornerRadius
        _maskingView.layer.cornerCurve = .continuous
    }
    
    public func setNeedsBorderLayout() {
        _bounds = .zero
        setNeedsLayout()
    }
    
    private func path() -> CGPath {
        let outerPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: cornerRadius
        )
        
        let innerPath = UIBezierPath(
            roundedRect: CGRect(
                x: borderWidth,
                y: borderWidth,
                width: bounds.width - borderWidth * 2,
                height: bounds.height - borderWidth * 2
            ),
            cornerRadius: cornerRadius
        ).reversing()
        
        outerPath.usesEvenOddFillRule = true
        outerPath.append(innerPath)
        
        return outerPath.cgPath
    }
}
