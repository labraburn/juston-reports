//
//  Created by Anton Spivak
//

import Lottie
import UIKit

open class LottieAnimationView: UIView {
    
    public let animationView: AnimationView
    
    public var hidesWhenStopped = true
    public var isAnimationPlaying: Bool { animationView.isAnimationPlaying }
    
    public var loopAnimation: Bool {
        get { animationView.loopMode == .loop }
        set { animationView.loopMode = newValue ? .loop : .playOnce }
    }

    public init(name: String, in bundle: Bundle = .main) {
        let url = bundle.url(forResource: name, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let animation = try! JSONDecoder().decode(Animation.self, from: data)
        animationView = AnimationView(animation: animation)
        
        super.init(frame: .zero)
        
        animationView.loopMode = .loop
        animationView.shouldRasterizeWhenIdle = true
        animationView.contentMode = .scaleAspectFit
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func setProgressWithFrame(_ progress: Float) {
        animationView.currentProgress = AnimationProgressTime(progress)
    }

    open func startAnimating() {
        isHidden = false
        animationView.play(completion: nil)
    }

    open func stopAnimating() {
        if hidesWhenStopped {
            isHidden = true
        }
        animationView.stop()
    }
}
