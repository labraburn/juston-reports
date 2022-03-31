//
//  Created by Anton Spivak.
//

import UIKit

public final class HuetonView: SignboardView {
    
    private let textLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .hui_textSecondary
        $0.font = .font(for: .caption2)
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.alpha = 0
        $0.isHidden = true
    })
    
    public var text: String? {
        get { textLabel.attributedText?.string }
        set { textLabel.attributedText = .string(newValue, with: .caption2, kern: .default, lineHeight: 11) }
    }
    
    public init() {
        super.init(
            letters: [
                .init(character: "H", color: .hui_letter_red, tumbler: .off),
                .init(character: "U", color: .hui_letter_yellow, tumbler: .off),
                .init(character: "E", color: .hui_letter_green, tumbler: .off),
                .init(character: "T", color: .hui_letter_blue, tumbler: .off),
                .init(character: "O", color: .hui_letter_violet, tumbler: .off),
                .init(character: "N", color: .hui_letter_purple, tumbler: .off),
            ]
        )
        
        clipsToBounds = false
        addSubview(textLabel)
        
        NSLayoutConstraint.activate {
            textLabel.centerXAnchor.pin(to: centerXAnchor)
            textLabel.topAnchor.pin(to: bottomAnchor, constant: 12)
        }
    }
    
    // MARK: API
    
    public func startInfinityAnimation() {
        textLabel.layer.removeAllAnimations()
        endUpdates()
        
        performUpdatesWithLetters({ $0.infinity() })
    }
    
    public func stopInfinityAnimation() {
        textLabel.layer.removeAllAnimations()
        endUpdates()
        
        UIView.animate(
            withDuration: 0.24,
            animations: {
                self.textLabel.alpha = 0
            },
            completion: { _ in
                self.textLabel.isHidden = true
            }
        )
        
        DispatchQueue.main.async(execute: {
            self.performUpdatesWithLetters({ $0.on() })
        })
    }
    
    public func set(progress: Double) {
        let _progress = max(min(progress, 1), 0)
        
        if _progress >= 1 {
            performUpdatesWithLetters { $0.just([.off, .off, .off, .off, .off, .off]) }
        } else if _progress >= 0.94 {
            performUpdatesWithLetters { $0.just([.on, .off, .off, .off, .off, .off]) }
        } else if _progress >= 0.7 {
            performUpdatesWithLetters { $0.just([.on, .on, .off, .off, .off, .off]) }
        } else if _progress >= 0.56 {
            performUpdatesWithLetters { $0.just([.on, .on, .on, .off, .off, .off]) }
        } else if _progress >= 0.35 {
            performUpdatesWithLetters { $0.just([.on, .on, .on, .on, .off, .off]) }
        } else if _progress >= 0.14 {
            performUpdatesWithLetters { $0.just([.on, .on, .on, .on, .on, .off]) }
        } else {
            performUpdatesWithLetters { $0.just([.on, .on, .on, .on, .on, .on]) }
        }
        
        if textLabel.isHidden {
            textLabel.alpha = 0
            textLabel.isHidden = false
        }
        
        UIView.animate(
            withDuration: 0.12,
            animations: {
                self.textLabel.alpha = min(_progress * 0.7, 0.7)
            }
        )
    }
}
