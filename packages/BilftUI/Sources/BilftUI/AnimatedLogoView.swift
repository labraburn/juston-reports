//
//  File.swift
//  
//
//  Created by Anton Spivak on 29.01.2022.
//

import UIKit

public final class AnimatedLogoView: UIView {
    
    public struct Presentation {
        
        public static let off = Presentation(b: .off, l: .off, i: .off, f: .off, t: .off)
        public static let on = Presentation(b: .on, l: .on, i: .on, f: .on, t: .on)
        
        let b: Switch
        let l: Switch
        let i: Switch
        let f: Switch
        let t: Switch
        
        public init(b: Switch, l: Switch, i: Switch, f: Switch, t: Switch) {
            self.b = b
            self.l = l
            self.i = i
            self.f = f
            self.t = t
        }
    }
    
    public enum Switch {
        case on
        case off
        
        internal var name: String {
            switch self {
            case .on: return "On"
            case .off: return "Off"
            }
        }
    }
    
    public private(set) var presentation: Presentation = .off
    
    private let b: UIImageView = AnimatedLogoView.imageView()
    private let l: UIImageView = AnimatedLogoView.imageView()
    private let i: UIImageView = AnimatedLogoView.imageView()
    private let f: UIImageView = AnimatedLogoView.imageView()
    private let t: UIImageView = AnimatedLogoView.imageView()
    
    private let animation = UIView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        backgroundColor = .clear
        
        animation.backgroundColor = .clear
        addSubview(animation)
        
        [b, l, i, f, t].forEach { addSubview($0) }
        updateImageViews()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let spacing = CGFloat(8)
        
        b.bounds.size = CGSize(width: 50, height: 50)
        l.bounds.size = CGSize(width: 15, height: 50)
        i.bounds.size = CGSize(width: 33, height: 50)
        f.bounds.size = CGSize(width: 41, height: 50)
        t.bounds.size = CGSize(width: 43, height: 50)
        
        let views = [b, l, i, f, t]
        let width = views.reduce(into: CGFloat(0), { $0 += $1.bounds.width }) + spacing * 4
        
        var offset = (max(bounds.width, width) - width) / 2
        for i in 0..<views.count {
            let view = views[i]
            view.center = CGPoint(
                x: offset + view.bounds.width / 2,
                y: bounds.height / 2
            )
            offset = view.frame.maxX + spacing
        }
    }
    
    public func update(presentation: Presentation) {
        self.presentation = presentation
        self.updateImageViews()
    }
    
    public func animate(
        with presentations: [Presentation],
        duration: TimeInterval,
        completion: @escaping (Bool) -> Void
    ) {
        guard presentations.count > 0
        else {
            completion(true)
            return
        }
        
        let step = duration / TimeInterval(presentations.count)
        let transition = { [weak self] (_ to: Presentation, _ completion: ((Bool) -> Void)?) in
            guard let self = self
            else {
                return
            }
            
            let views = [self.b, self.l, self.i, self.f, self.t]
            let key = "transition"
            
            let transition = LogoViewTransition()
            transition.completion = completion
            transition.duration = step
            transition.type = .fade
            transition.timingFunction = .init(name: .easeInEaseOut)
            
            views.forEach {
                $0.layer.removeAnimation(forKey: key)
                $0.layer.add(transition, forKey: key)
            }
            
            self.presentation = to
            self.updateImageViews()
        }
        
        guard presentations.count > 1
        else {
            transition(presentations[0], completion)
            return
        }
        
        transition(presentations[0], nil)
        
        for i in 1..<presentations.count {
            let presentation = presentations[i]
            UIView.animate(
                withDuration: step,
                delay: CGFloat(i) * step,
                options: [.curveLinear],
                animations: {
                    // UIKit doesn't run animations if no chages
                    self.animation.center = CGPoint(
                        x: self.animation.center.x + 1,
                        y: self.animation.center.y + 1
                    )
                },
                completion: { _ in
                    let completion = i + 1 == presentations.count ? completion : nil
                    transition(presentation, completion)
                }
            )
        }
    }
    
    // MARK: Private
    
    private func updateImageViews() {
        b.image = UIImage(named: "Letters/B/\(presentation.b.name)", in: .module, with: nil)
        l.image = UIImage(named: "Letters/I/\(presentation.i.name)", in: .module, with: nil)
        i.image = UIImage(named: "Letters/L/\(presentation.l.name)", in: .module, with: nil)
        f.image = UIImage(named: "Letters/F/\(presentation.f.name)", in: .module, with: nil)
        t.image = UIImage(named: "Letters/T/\(presentation.t.name)", in: .module, with: nil)
    }
    
    static func imageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.clipsToBounds = false
        imageView.contentMode = .center
        return imageView
    }
}

fileprivate class LogoViewTransition: CATransition, CAAnimationDelegate {
    
    var completion: ((Bool) -> Void)?
    
    override init() {
        super.init()
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        delegate = self
    }
    
    // MARK: CAAnimationDelegate
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        delegate = nil
        completion?(flag)
    }
}
