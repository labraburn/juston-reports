//
//  Created by Anton Spivak.
//

import UIKit

public class TeritaryButton: HuetonButton {
    
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
        
        addSubview(textLabel)
        
        NSLayoutConstraint.activate({
            textLabel.pin(edges: self)
        })
        
        insertFeedbackGenerator(style: .light)
    }
}
