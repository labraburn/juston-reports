//
//  Created by Anton Spivak.
//  

import UIKit

public class MagicBackgroundView: UIView {
    
    #if !targetEnvironment(simulator)
    private let backgroundView: MagicOpenGLView = MagicOpenGLView()
    #endif
    private let visualEffectView: UIVisualEffectView = UIVisualEffectView(effect: nil)
    
    public override var tintColor: UIColor! {
        set { visualEffectView.backgroundColor = newValue }
        get { visualEffectView.backgroundColor }
    }
    
    public var color: UIColor {
        set { backgroundView.color = newValue }
        get { backgroundView.color }
    }
    
    public var effect: UIVisualEffect? {
        didSet {
            visualEffectView.effect = effect
        }
    }
    
    public init(effect: UIVisualEffect?) {
        super.init(frame: .zero)
        #if !targetEnvironment(simulator)
        addSubview(backgroundView)
        addSubview(visualEffectView)
        visualEffectView.effect = effect
        visualEffectView.isUserInteractionEnabled = false
        backgroundView.isUserInteractionEnabled = false
        tintColor = .clear
        #endif
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        #if !targetEnvironment(simulator)
        backgroundView.frame = bounds
        #endif
        visualEffectView.frame = bounds
    }
}
