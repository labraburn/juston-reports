//
//  Created by Anton Spivak.
//

import UIKit

public final class PrimaryButton: MagicButton {
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
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
                    self.transform = newValue ? .identity.scaledBy(x: 0.92, y: 0.92) : .identity
                },
                completion: nil
            )
            
            super.isHighlighted = newValue
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 2
        layer.cornerCurve = .continuous
        
        backgroundColor = .accent
    }
}
