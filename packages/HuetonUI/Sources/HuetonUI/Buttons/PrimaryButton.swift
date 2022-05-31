//
//  Created by Anton Spivak.
//

import UIKit

public final class PrimaryButton: HuetonButton {
    
    private let gradientView = GradientView(colors: [UIColor(rgb: 0x4776E6), UIColor(rgb: 0x8E54E9)], angle: 45).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
    })
    
    private let textLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.font = .monospacedSystemFont(ofSize: 16, weight: .medium)
        $0.textAlignment = .center
        $0.textColor = .white
    })
    
    public override var title: String? {
        didSet {
            textLabel.text = title
        }
    }
    
    public init(title: String? = nil) {
        super.init(frame: .zero)
        textLabel.text = title
        _initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _initialize()
    }
    
    override func _initialize() {
        super._initialize()
        
        clipsToBounds = true
        
        layer.cornerRadius = 12
        layer.cornerCurve = .continuous
        layer.masksToBounds = true
        
        addSubview(gradientView)
        addSubview(textLabel)
        
        NSLayoutConstraint.activate({
            gradientView.pin(edges: self)
            textLabel.pin(edges: self)
        })
        
        insertFeedbackGenerator(style: .heavy)
    }
}
