//
//  Created by Anton Spivak.
//

import UIKit

open class HuetonView: SignboardView {
    
    public init() {
        super.init(
            letters: [
                .init(character: "H", color: .hui_letter_red, tumbler: .on),
                .init(character: "U", color: .hui_letter_yellow, tumbler: .on),
                .init(character: "E", color: .hui_letter_green, tumbler: .on),
                .init(character: "T", color: .hui_letter_blue, tumbler: .on),
                .init(character: "O", color: .hui_letter_violet, tumbler: .on),
                .init(character: "N", color: .hui_letter_purple, tumbler: .on),
            ]
        )
    }
    
    // MARK: API
    
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
    }
}
