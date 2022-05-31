//
//  Created by Anton Spivak.
//

import UIKit

public class SecondaryButton: HuetonButton {
    
    private let borderView = GradientBorderedView(colors: [UIColor(rgb: 0x4876E6), UIColor(rgb: 0x8D55E9)]).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.cornerRadius = 12
    })
    
    private let textLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.font = .monospacedSystemFont(ofSize: 16, weight: .medium)
        $0.textAlignment = .center
        $0.textColor = UIColor(rgb: 0x7B66FF)
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
        
        addSubview(borderView)
        addSubview(textLabel)
        
        NSLayoutConstraint.activate({
            borderView.pin(edges: self)
            textLabel.pin(edges: self)
        })
        
        insertFeedbackGenerator(style: .medium)
    }
}
