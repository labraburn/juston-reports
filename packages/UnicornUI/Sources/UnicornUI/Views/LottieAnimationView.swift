//
//  Created by Anton Spivak
//

import Lottie
import UIKit

open class LottieAnimationView: LOTAnimationView {
    public var hidesWhenStopped = true

    public init(name: String, in bundle: Bundle = .main) {
        let composition = LOTComposition(name: name, bundle: bundle)
        super.init(model: composition, in: bundle)
        loopAnimation = true
        shouldRasterizeWhenIdle = true
        contentMode = .scaleAspectFit
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func startAnimating() {
        isHidden = false
        super.play()
    }

    open func stopAnimating() {
        if hidesWhenStopped {
            isHidden = true
        }
        super.stop()
    }

    @available(*, deprecated, renamed: "startAnimating")
    override open func play() {
        super.play()
    }

    @available(*, deprecated, renamed: "stopAnimating")
    override open func stop() {
        super.stop()
    }
}
